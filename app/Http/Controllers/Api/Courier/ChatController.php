<?php

namespace App\Http\Controllers\Api\Courier;

use App\Http\Controllers\Controller;
use App\Models\Message;
use App\Models\Order;
use App\Models\Pharmacy;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ChatController extends Controller
{
    /**
     * Get messages for a specific order
     */
    public function index(Request $request, $orderId)
    {
        $user = $request->user();
        
        // Ensure courier has access to this order
        $order = Order::with(['delivery'])->findOrFail($orderId);
        
        // SECURITY: Strict check if this courier is assigned to the order
        if (!$this->courierHasAccessToOrder($user, $order)) {
            return response()->json([
                'success' => false,
                'message' => 'Vous n\'êtes pas autorisé à accéder aux messages de cette commande.',
            ], 403);
        }

        $messages = Message::where('order_id', $orderId)
            ->with(['sender', 'receiver'])
            ->orderBy('created_at', 'asc')
            ->get()
            ->map(function ($message) use ($user) {
                return [
                    'id' => $message->id,
                    'content' => $message->content,
                    'is_me' => $message->sender_id === $user->id && $message->sender_type === User::class,
                    'created_at' => $message->created_at->toIso8601String(),
                    'sender_name' => $this->getSenderName($message),
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $messages,
        ]);
    }

    /**
     * Send a message
     */
    public function store(Request $request, $orderId)
    {
        $validator = Validator::make($request->all(), [
            'content' => 'required|string|max:1000',
            'target' => 'required|in:pharmacy,customer',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $user = $request->user();
        $order = Order::findOrFail($orderId);
        
        // SECURITY: Strict check if this courier is assigned to the order
        if (!$this->courierHasAccessToOrder($user, $order)) {
            return response()->json([
                'success' => false,
                'message' => 'Vous n\'êtes pas autorisé à envoyer des messages pour cette commande.',
            ], 403);
        }
        
        // Determine Receiver
        $receiverType = null;
        $receiverId = null;

        if ($request->target === 'pharmacy') {
            $receiverType = Pharmacy::class;
            $receiverId = $order->pharmacy_id;
        } else {
            $receiverType = User::class;
            $receiverId = $order->customer_id;
        }

        $message = Message::create([
            'order_id' => $orderId,
            'sender_type' => User::class,
            'sender_id' => $user->id,
            'receiver_type' => $receiverType,
            'receiver_id' => $receiverId,
            'content' => $request->content,
            'read_at' => null,
        ]);

        // Send Notification (FCM) here if implemented

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $message->id,
                'content' => $message->content,
                'is_me' => true,
                'created_at' => $message->created_at->toIso8601String(),
            ]
        ]);
    }

    /**
     * Check if courier has access to the order
     */
    private function courierHasAccessToOrder($user, Order $order): bool
    {
        // User must have a courier profile
        if (!$user->courier) {
            return false;
        }
        
        // Order must have a delivery assigned to this courier
        if (!$order->delivery) {
            return false;
        }
        
        return $order->delivery->courier_id === $user->courier->id;
    }

    private function getSenderName($message)
    {
        if ($message->sender_type === Pharmacy::class) {
            return $message->sender->name ?? 'Pharmacie';
        }
        return $message->sender->name ?? 'Utilisateur';
    }
}
