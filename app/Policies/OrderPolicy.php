<?php

namespace App\Policies;

use App\Models\Order;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class OrderPolicy
{
    use HandlesAuthorization;

    /**
     * Determine if the user can view any orders.
     */
    public function viewAny(User $user): bool
    {
        // Admins can view all orders
        if ($user->isAdmin()) {
            return true;
        }

        // Users can view their own orders list
        return true;
    }

    /**
     * Determine if the user can view the order.
     */
    public function view(User $user, Order $order): bool
    {
        // Admins can view any order
        if ($user->isAdmin()) {
            return true;
        }

        // Customer can view their own orders
        if ($user->role === 'customer' && $order->customer_id === $user->id) {
            return true;
        }

        // Pharmacy can view orders made to their pharmacy
        if ($user->role === 'pharmacy') {
            $pharmacyIds = $user->pharmacies()->pluck('pharmacies.id')->toArray();
            if (in_array($order->pharmacy_id, $pharmacyIds)) {
                return true;
            }
        }

        // Courier can view orders assigned to them via delivery
        if ($user->role === 'courier') {
            $courier = $user->courier;
            if ($courier && $order->delivery && $order->delivery->courier_id === $courier->id) {
                return true;
            }
        }

        return false;
    }

    /**
     * Determine if the user can create orders.
     */
    public function create(User $user): bool
    {
        // Only customers can create orders
        return $user->role === 'customer';
    }

    /**
     * Determine if the user can update the order.
     */
    public function update(User $user, Order $order): bool
    {
        // Admins can update any order
        if ($user->isAdmin()) {
            return true;
        }

        // Customer can only cancel their own orders (if pending)
        if ($user->role === 'customer' && $order->customer_id === $user->id) {
            return in_array($order->status, ['pending', 'processing']);
        }

        // Pharmacy can update their orders status
        if ($user->role === 'pharmacy') {
            $pharmacyIds = $user->pharmacies()->pluck('pharmacies.id')->toArray();
            if (in_array($order->pharmacy_id, $pharmacyIds)) {
                return true;
            }
        }

        // Courier can update delivery status for their assigned orders
        if ($user->role === 'courier') {
            $courier = $user->courier;
            if ($courier && $order->delivery && $order->delivery->courier_id === $courier->id) {
                return true;
            }
        }

        return false;
    }

    /**
     * Determine if the user can delete the order.
     */
    public function delete(User $user, Order $order): bool
    {
        // Only admins can delete orders
        return $user->isAdmin();
    }

    /**
     * Determine if the user can cancel the order.
     */
    public function cancel(User $user, Order $order): bool
    {
        // Admins can cancel any order
        if ($user->isAdmin()) {
            return true;
        }

        // Customer can cancel their own orders if still pending or confirmed
        if ($user->role === 'customer' && $order->customer_id === $user->id) {
            return in_array($order->status, ['pending', 'confirmed']);
        }

        // Pharmacy can cancel orders for their pharmacy
        if ($user->role === 'pharmacy') {
            $pharmacyIds = $user->pharmacies()->pluck('pharmacies.id')->toArray();
            if (in_array($order->pharmacy_id, $pharmacyIds)) {
                return in_array($order->status, ['pending', 'confirmed', 'preparing', 'ready']);
            }
        }

        return false;
    }

    /**
     * Determine if the user can update the delivery status.
     */
    public function updateDeliveryStatus(User $user, Order $order): bool
    {
        // Only the assigned courier or admin can update delivery status
        if ($user->isAdmin()) {
            return true;
        }

        if ($user->role === 'courier') {
            $courier = $user->courier;
            if ($courier && $order->courier_id === $courier->id) {
                return in_array($order->status, ['ready', 'assigned', 'in_delivery']);
            }
        }

        return false;
    }

    /**
     * Determine if the user can assign a courier to the order.
     */
    public function assignCourier(User $user, Order $order): bool
    {
        // Admins can always assign couriers
        if ($user->isAdmin()) {
            return true;
        }

        // Pharmacy can also request courier assignment for their orders
        if ($user->role === 'pharmacy') {
            $pharmacyIds = $user->pharmacies()->pluck('pharmacies.id')->toArray();
            if (in_array($order->pharmacy_id, $pharmacyIds)) {
                // Order must be ready and no delivery assigned yet
                return $order->status === 'ready' && 
                       (!$order->delivery || is_null($order->delivery->courier_id));
            }
        }

        return false;
    }

    /**
     * Determine if the pharmacy can accept the order.
     */
    public function accept(User $user, Order $order): bool
    {
        // Admins can accept any order
        if ($user->isAdmin()) {
            return true;
        }

        // Only pharmacy users can accept orders
        if ($user->role !== 'pharmacy') {
            return false;
        }

        // Pharmacy can only accept orders for their pharmacy
        $pharmacyIds = $user->pharmacies()->pluck('pharmacies.id')->toArray();
        if (!in_array($order->pharmacy_id, $pharmacyIds)) {
            return false;
        }

        // Order must be pending to be accepted
        return $order->status === 'pending';
    }
}
