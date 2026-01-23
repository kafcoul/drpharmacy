<?php

namespace App\Policies;

use App\Models\Prescription;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class PrescriptionPolicy
{
    use HandlesAuthorization;

    /**
     * Determine if the user can view any prescriptions.
     */
    public function viewAny(User $user): bool
    {
        return in_array($user->role, ['admin', 'customer', 'pharmacy']);
    }

    /**
     * Determine if the user can view the prescription.
     */
    public function view(User $user, Prescription $prescription): bool
    {
        if ($user->isAdmin()) {
            return true;
        }

        // Customer can view their own prescriptions
        if ($user->role === 'customer') {
            return $prescription->customer_id === $user->id;
        }

        // Pharmacy can view prescriptions assigned to them or pending
        if ($user->role === 'pharmacy') {
            $pharmacyIds = $user->pharmacies()->pluck('pharmacies.id')->toArray();
            return in_array($prescription->pharmacy_id, $pharmacyIds) || 
                   $prescription->status === 'pending';
        }

        return false;
    }

    /**
     * Determine if the user can create prescriptions.
     */
    public function create(User $user): bool
    {
        return $user->role === 'customer';
    }

    /**
     * Determine if the user can update the prescription status.
     */
    public function updateStatus(User $user, Prescription $prescription): bool
    {
        if ($user->isAdmin()) {
            return true;
        }

        // Only pharmacy can update prescription status
        if ($user->role === 'pharmacy') {
            $pharmacyIds = $user->pharmacies()->pluck('pharmacies.id')->toArray();
            return in_array($prescription->pharmacy_id, $pharmacyIds) || 
                   is_null($prescription->pharmacy_id); // Can claim pending prescriptions
        }

        return false;
    }

    /**
     * Determine if the user can delete the prescription.
     */
    public function delete(User $user, Prescription $prescription): bool
    {
        if ($user->isAdmin()) {
            return true;
        }

        // Customer can delete their own pending prescriptions
        return $user->role === 'customer' && 
               $prescription->customer_id === $user->id && 
               $prescription->status === 'pending';
    }
}
