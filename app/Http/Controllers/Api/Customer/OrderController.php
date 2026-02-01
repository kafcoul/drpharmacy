<?php

namespace App\Http\Controllers\Api\Customer;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Pharmacy;
use App\Notifications\NewOrderReceivedNotification;
use App\Services\PaymentService;
use App\Services\WalletService;
use App\Services\WaitingFeeService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class OrderController extends Controller
{
    protected PaymentService $paymentService;
    protected WaitingFeeService $waitingFeeService;

    public function __construct(PaymentService $paymentService, WaitingFeeService $waitingFeeService)
    {
        $this->paymentService = $paymentService;
        $this->waitingFeeService = $waitingFeeService;
    }

    /**
     * Get customer orders
     */
    public function index(Request $request)
    {
        $perPage = min($request->input('per_page', 15), 50); // Max 50 par page
        
        $orders = $request->user()->orders()
            ->with(['pharmacy:id,name,phone', 'delivery', 'payments'])
            ->latest()
            ->paginate($perPage);

        $formattedOrders = $orders->getCollection()->map(function ($order) {
            return [
                'id' => $order->id,
                'reference' => $order->reference,
                'pharmacy' => [
                    'id' => $order->pharmacy->id,
                    'name' => $order->pharmacy->name,
                    'phone' => $order->pharmacy->phone,
                ],
                'status' => $order->status,
                'payment_status' => $order->payment_status ?? 'pending',
                'delivery_code' => $order->delivery_code,
                'payment_mode' => $order->payment_mode,
                'total_amount' => $order->total_amount,
                'currency' => $order->currency,
                'delivery_address' => $order->delivery_address,
                'created_at' => $order->created_at,
                'paid_at' => $order->paid_at,
                'delivered_at' => $order->delivered_at,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $formattedOrders,
            'meta' => [
                'current_page' => $orders->currentPage(),
                'last_page' => $orders->lastPage(),
                'per_page' => $orders->perPage(),
                'total' => $orders->total(),
            ],
        ]);
    }

    /**
     * Create a new order
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'pharmacy_id' => 'required|exists:pharmacies,id',
            'items' => 'required|array|min:1',
            'items.*.id' => 'nullable|exists:products,id',
            'items.*.name' => 'required|string',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.price' => 'required|numeric|min:0',
            'prescription_image' => 'nullable|string',
            'customer_notes' => 'nullable|string',
            'delivery_address' => 'required|string',
            'delivery_city' => 'nullable|string',
            'delivery_latitude' => 'nullable|numeric',
            'delivery_longitude' => 'nullable|numeric',
            'customer_phone' => 'required|string',
            'payment_mode' => 'required|in:cash,mobile_money,card,platform,on_delivery',
        ]);

        // Normaliser le payment_mode pour la compatibilité avec l'ancien format
        $paymentMode = match($validated['payment_mode']) {
            'platform' => 'mobile_money',
            'on_delivery' => 'cash',
            default => $validated['payment_mode'],
        };
        $validated['payment_mode'] = $paymentMode;

        try {
            DB::beginTransaction();

            // Validate products availability and stock
            foreach ($validated['items'] as $item) {
                if (isset($item['id'])) {
                    $product = \App\Models\Product::find($item['id']);
                    if ($product) {
                        if (!$product->is_available) {
                            DB::rollBack();
                            return response()->json([
                                'success' => false,
                                'message' => "Le produit {$product->name} n'est pas disponible",
                                'errors' => ['items' => ["Le produit {$product->name} n'est pas disponible"]]
                            ], 422);
                        }
                        if ($product->stock_quantity < $item['quantity'] ) {
                            DB::rollBack();
                            return response()->json([
                                'success' => false,
                                'message' => "Stock insuffisant pour le produit {$product->name}",
                                'errors' => ['items' => ["Stock insuffisant pour le produit {$product->name}"]]
                            ], 422);
                        }
                    }
                }
            }

            // Calculate totals
            $subtotal = 0;
            foreach ($validated['items'] as $item) {
                $price = $item['price'];
                if (isset($item['id'])) {
                    $product = \App\Models\Product::find($item['id']);
                    if ($product) {
                        $price = $product->price;
                    }
                }
                $subtotal += $item['quantity'] * $price;
            }

            // Récupérer les frais de livraison depuis les paramètres
            $deliveryFee = WalletService::getDeliveryFeeBase();
            $totalAmount = $subtotal + $deliveryFee;

            // Create order
            $order = Order::create([
                'reference' => Order::generateReference(),
                'pharmacy_id' => $validated['pharmacy_id'],
                'customer_id' => $request->user()->id,
                'status' => 'pending',
                'payment_mode' => $validated['payment_mode'],
                'subtotal' => $subtotal,
                'delivery_fee' => $deliveryFee,
                'total_amount' => $totalAmount,
                'currency' => 'XOF',
                'customer_notes' => $validated['customer_notes'] ?? null,
                'prescription_image' => $validated['prescription_image'] ?? null,
                'delivery_address' => $validated['delivery_address'],
                'delivery_city' => $validated['delivery_city'] ?? null,
                'delivery_latitude' => $validated['delivery_latitude'] ?? null,
                'delivery_longitude' => $validated['delivery_longitude'] ?? null,
                'customer_phone' => $validated['customer_phone'],
            ]);

            // Create order items
            foreach ($validated['items'] as $item) {
                $price = $item['price'];
                if (isset($item['id'])) {
                    $product = \App\Models\Product::find($item['id']);
                    if ($product) {
                        $price = $product->price;
                    }
                }
                $order->items()->create([
                    'product_id' => $item['id'] ?? null, // Assuming frontend sends 'id'
                    'product_name' => $item['name'],
                    'quantity' => $item['quantity'],
                    'unit_price' => $price,
                    'total_price' => $item['quantity'] * $price,
                ]);
            }

            DB::commit();

            // === NOTIFIER LA PHARMACIE POUR PAIEMENT CASH ===
            // Pour les paiements en ligne, la notification est envoyée après confirmation du paiement
            // Pour les paiements cash, on notifie immédiatement car la commande est valide
            if ($order->payment_mode === 'cash') {
                $order->load(['items', 'customer', 'pharmacy.users']);
                
                // Notifier tous les utilisateurs de la pharmacie
                foreach ($order->pharmacy?->users ?? [] as $pharmacyUser) {
                    $pharmacyUser->notify(new NewOrderReceivedNotification($order));
                }
                
                Log::info('Notification nouvelle commande cash envoyée à la pharmacie', [
                    'order_id' => $order->id,
                    'order_reference' => $order->reference,
                    'pharmacy_id' => $order->pharmacy_id,
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Commande créée avec succès',
                'data' => [
                    'order_id' => $order->id,
                    'reference' => $order->reference,
                    'total_amount' => $order->total_amount,
                    'status' => $order->status,
                    'delivery_code' => $order->delivery_code,
                ],
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Order creation failed', [
                'error' => $e->getMessage(),
                'user_id' => $request->user()->id,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la création de la commande',
            ], 500);
        }
    }

    /**
     * Get order details
     */
    public function show(Request $request, $id)
    {
        $order = $request->user()->orders()
            ->with(['pharmacy', 'items', 'delivery.courier.user', 'payments'])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $order->id,
                'reference' => $order->reference,
                'status' => $order->status,
                'payment_status' => $order->payment_status ?? 'pending',
                'delivery_code' => $order->delivery_code,
                'payment_mode' => $order->payment_mode,
                'pharmacy' => [
                    'id' => $order->pharmacy->id,
                    'name' => $order->pharmacy->name,
                    'phone' => $order->pharmacy->phone,
                    'address' => $order->pharmacy->address,
                ],
                'items' => $order->items->map(fn($item) => [
                    'product_name' => $item->product_name,
                    'quantity' => $item->quantity,
                    'unit_price' => $item->unit_price,
                    'total_price' => $item->total_price,
                ]),
                'subtotal' => $order->subtotal,
                'delivery_fee' => $order->delivery_fee,
                'total_amount' => $order->total_amount,
                'currency' => $order->currency,
                'delivery_address' => $order->delivery_address,
                'customer_phone' => $order->customer_phone,
                'customer_notes' => $order->customer_notes,
                'prescription_image' => $order->prescription_image,
                'delivery' => $order->delivery ? [
                    'id' => $order->delivery->id,
                    'status' => $order->delivery->status,
                    'estimated_distance' => (float) $order->delivery->estimated_distance,
                    'estimated_duration' => $order->delivery->estimated_duration, // e.g., "15 min" or integer
                    'courier' => $order->delivery->courier ? [
                        'name' => $order->delivery->courier->user->name,
                        'phone' => $order->delivery->courier->user->phone, 
                        'phone_courier' => $order->delivery->courier->phone,
                        'avatar' => $order->delivery->courier->user->avatar, 
                        'vehicle_type' => $order->delivery->courier->vehicle_type,
                        'vehicle_number' => $order->delivery->courier->vehicle_number,
                        'rating' => (float) $order->delivery->courier->rating,
                        'completed_deliveries' => (int) $order->delivery->courier->completed_deliveries,
                        'latitude' => (float) $order->delivery->courier->latitude,
                        'longitude' => (float) $order->delivery->courier->longitude,
                    ] : null,
                ] : null,
                'created_at' => $order->created_at,
                'confirmed_at' => $order->confirmed_at,
                'paid_at' => $order->paid_at,
                'delivered_at' => $order->delivered_at,
            ],
        ]);
    }

    /**
     * Initiate payment for an order
     */
    public function initiatePayment(Request $request, $id)
    {
        $validated = $request->validate([
            'provider' => 'required|in:cinetpay,jeko',
        ]);

        $order = $request->user()->orders()->findOrFail($id);

        // Check if order is already paid
        if ($order->isPaid()) {
            return response()->json([
                'success' => false,
                'message' => 'Cette commande est déjà payée',
            ], 400);
        }

        try {
            $paymentIntent = $this->paymentService->initiatePayment(
                $order,
                $validated['provider'],
                [
                    'name' => $request->user()->name,
                    'phone' => $request->user()->phone,
                    'email' => $request->user()->email,
                ]
            );

            return response()->json([
                'success' => true,
                'message' => 'Paiement initié',
                'data' => [
                    'payment_url' => $paymentIntent->provider_payment_url,
                    'provider' => $paymentIntent->provider,
                    'amount' => $paymentIntent->amount,
                    'reference' => $paymentIntent->reference,
                ],
            ]);

        } catch (\Exception $e) {
            Log::error('Payment initiation failed', [
                'order_id' => $order->id,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'initialisation du paiement',
            ], 500);
        }
    }

    /**
     * Cancel an order
     */
    public function cancel(Request $request, $id)
    {
        $validated = $request->validate([
            'reason' => 'required|string|max:500',
        ]);

        $order = Order::findOrFail($id);
        
        // SECURITY: Vérifier l'autorisation via Policy
        $this->authorize('cancel', $order);

        if (!in_array($order->status, ['pending', 'processing'])) {
            return response()->json([
                'success' => false,
                'message' => 'Cette commande ne peut pas être annulée',
            ], 400);
        }

        $order->update([
            'status' => 'cancelled',
            'cancellation_reason' => $validated['reason'],
            'cancelled_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Commande annulée avec succès',
        ]);
    }

    /**
     * Obtenir le statut de la minuterie d'attente pour une commande
     * 
     * GET /api/customer/orders/{id}/waiting-status
     * 
     * Permet au client de voir le décompte en temps réel quand le livreur est arrivé
     */
    public function waitingStatus(Request $request, $id)
    {
        $order = $request->user()->orders()->with('delivery')->findOrFail($id);

        if (!$order->delivery) {
            return response()->json([
                'success' => false,
                'message' => 'Aucune livraison associée à cette commande',
            ], 404);
        }

        $waitingInfo = $this->waitingFeeService->getWaitingInfo($order->delivery);

        // Message d'avertissement pour le client
        $warningMessage = null;
        if ($waitingInfo['is_waiting']) {
            $freeMinutes = $waitingInfo['free_minutes'];
            $feePerMinute = $waitingInfo['fee_per_minute'];
            $remainingFree = max(0, $freeMinutes - $waitingInfo['waiting_minutes']);
            
            if ($remainingFree > 0) {
                $warningMessage = "⏱️ Il vous reste {$remainingFree} minute(s) gratuite(s). Après cela, des frais de {$feePerMinute} FCFA/min seront facturés.";
            } else {
                $currentFee = $waitingInfo['waiting_fee'];
                $warningMessage = "⚠️ Frais d'attente en cours: {$currentFee} FCFA (+{$feePerMinute} FCFA/min)";
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'order_id' => $order->id,
                'delivery_id' => $order->delivery->id,
                'status' => $order->delivery->status,
                'waiting_info' => $waitingInfo,
                'warning_message' => $warningMessage,
            ],
        ]);
    }
}
