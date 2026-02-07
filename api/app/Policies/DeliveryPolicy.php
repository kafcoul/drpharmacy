<?php

namespace App\Policies;

use App\Models\Delivery;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class DeliveryPolicy
{
    use HandlesAuthorization;

    /**
     * Determine if the user can view any deliveries.
     */
    public function viewAny(User $user): bool
    {
        return in_array($user->role, ['admin', 'courier']);
    }

    /**
     * Determine if the user can view the delivery.
     */
    public function view(User $user, Delivery $delivery): bool
    {
        if ($user->isAdmin()) {
            return true;
        }

        // Courier can view their own deliveries
        if ($user->role === 'courier') {
            $courier = $user->courier;
            return $courier && $delivery->courier_id === $courier->id;
        }

        // Customer can view delivery of their order
        if ($user->role === 'customer') {
            return $delivery->order && $delivery->order->customer_id === $user->id;
        }

        // Pharmacy can view delivery of their orders
        if ($user->role === 'pharmacy') {
            $pharmacyIds = $user->pharmacies()->pluck('pharmacies.id')->toArray();
            return $delivery->order && in_array($delivery->order->pharmacy_id, $pharmacyIds);
        }

        return false;
    }

    /**
     * Determine if the user can accept the delivery.
     */
    public function accept(User $user, Delivery $delivery): bool
    {
        if ($user->role !== 'courier') {
            return false;
        }

        $courier = $user->courier;
        if (!$courier || $courier->status !== 'available') {
            return false;
        }

        // Delivery must be pending and either unassigned or assigned to this courier
        return $delivery->status === 'pending' && 
               (is_null($delivery->courier_id) || $delivery->courier_id === $courier->id);
    }

    /**
     * Determine if the user can update the delivery status.
     */
    public function updateStatus(User $user, Delivery $delivery): bool
    {
        if ($user->isAdmin()) {
            return true;
        }

        if ($user->role !== 'courier') {
            return false;
        }

        $courier = $user->courier;
        return $courier && $delivery->courier_id === $courier->id;
    }

    /**
     * Determine if the user can mark arrival (waiting timer).
     */
    public function markArrived(User $user, Delivery $delivery): bool
    {
        if ($user->role !== 'courier') {
            return false;
        }

        $courier = $user->courier;
        if (!$courier || $delivery->courier_id !== $courier->id) {
            return false;
        }

        return in_array($delivery->status, ['picked_up', 'in_transit']);
    }

    /**
     * Determine if the user can complete the delivery.
     */
    public function complete(User $user, Delivery $delivery): bool
    {
        if ($user->isAdmin()) {
            return true;
        }

        if ($user->role !== 'courier') {
            return false;
        }

        $courier = $user->courier;
        return $courier && 
               $delivery->courier_id === $courier->id && 
               in_array($delivery->status, ['in_transit', 'arrived']);
    }
}
