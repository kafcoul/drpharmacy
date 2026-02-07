<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    /**
     * Get all notifications for authenticated user
     */
    public function index(Request $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();

        $notifications = $user->notifications()
            ->orderBy('created_at', 'desc')
            ->paginate($request->get('per_page', 20));

        return response()->json([
            'success' => true,
            'data' => [
                'notifications' => $notifications->items(),
                'unread_count' => $user->unreadNotifications()->count(),
                'pagination' => [
                    'current_page' => $notifications->currentPage(),
                    'last_page' => $notifications->lastPage(),
                    'per_page' => $notifications->perPage(),
                    'total' => $notifications->total(),
                ],
            ],
        ]);
    }

    /**
     * Get unread notifications only
     */
    public function unread(Request $request): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();

        $notifications = $user->unreadNotifications()
            ->paginate($request->get('per_page', 20));

        return response()->json([
            'success' => true,
            'data' => [
                'notifications' => $notifications->items(),
                'unread_count' => $user->unreadNotifications()->count(),
            ],
        ]);
    }

    /**
     * Mark notification as read
     */
    public function markAsRead(string $id): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();

        $notification = $user->notifications()->findOrFail($id);
        $notification->markAsRead();

        return response()->json([
            'success' => true,
            'message' => 'Notification marquée comme lue',
        ]);
    }

    /**
     * Mark all notifications as read
     */
    public function markAllAsRead(): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();
        $user->unreadNotifications->markAsRead();

        return response()->json([
            'success' => true,
            'message' => 'Toutes les notifications marquées comme lues',
        ]);
    }

    /**
     * Delete a notification
     */
    public function destroy(string $id): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();

        $notification = $user->notifications()->findOrFail($id);
        $notification->delete();

        return response()->json([
            'success' => true,
            'message' => 'Notification supprimée',
        ]);
    }

    /**
     * Update FCM token for push notifications
     */
    public function updateFcmToken(Request $request): JsonResponse
    {
        $request->validate([
            'fcm_token' => 'required|string',
        ]);

        /** @var \App\Models\User $user */
        $user = Auth::user();
        $user->update([
            'fcm_token' => $request->fcm_token,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'FCM token mis à jour',
        ]);
    }

    /**
     * Remove FCM token (logout from push notifications)
     */
    public function removeFcmToken(): JsonResponse
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();
        $user->update([
            'fcm_token' => null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'FCM token supprimé',
        ]);
    }

    /**
     * Get notification sound settings
     * Returns available sounds and current configuration for each notification type
     */
    public function getSoundSettings(): JsonResponse
    {
        $notificationSettings = app(\App\Services\NotificationSettingsService::class);
        
        // Define all notification types based on user role
        /** @var \App\Models\User $user */
        $user = Auth::user();
        
        $notificationTypes = [];
        
        // Common notification types
        $notificationTypes['delivery_timeout'] = [
            'label' => 'Annulation pour délai dépassé',
            'config' => $notificationSettings->getConfig('delivery_timeout'),
        ];
        
        // Role-specific notification types
        if ($user->role === 'client') {
            $notificationTypes['order_confirmed'] = [
                'label' => 'Commande confirmée',
                'config' => $notificationSettings->getConfig('order_confirmed'),
            ];
            $notificationTypes['courier_arrived'] = [
                'label' => 'Livreur arrivé',
                'config' => $notificationSettings->getConfig('courier_arrived'),
            ];
            $notificationTypes['delivery_completed'] = [
                'label' => 'Livraison terminée',
                'config' => $notificationSettings->getConfig('delivery_completed'),
            ];
        } elseif ($user->role === 'pharmacy') {
            $notificationTypes['new_order_received'] = [
                'label' => 'Nouvelle commande reçue',
                'config' => $notificationSettings->getConfig('new_order_received'),
            ];
            $notificationTypes['delivery_assigned'] = [
                'label' => 'Livreur assigné',
                'config' => $notificationSettings->getConfig('delivery_assigned'),
            ];
        } elseif ($user->role === 'courier') {
            $notificationTypes['delivery_assigned'] = [
                'label' => 'Nouvelle livraison assignée',
                'config' => $notificationSettings->getConfig('delivery_assigned'),
            ];
            $notificationTypes['courier_arrived'] = [
                'label' => 'Arrivée confirmée',
                'config' => $notificationSettings->getConfig('courier_arrived'),
            ];
        }
        
        return response()->json([
            'success' => true,
            'data' => [
                'available_sounds' => $notificationSettings->getAvailableSounds(),
                'notification_types' => $notificationTypes,
            ],
        ]);
    }
}
