<?php

namespace App\Http\Controllers\Api\Courier;

use App\Http\Controllers\Controller;
use App\Models\Delivery;
use App\Services\WalletService;
use App\Services\WaitingFeeService;
use App\Actions\CalculateCommissionAction;
use App\Notifications\CourierArrivedNotification;
use App\Notifications\OrderDeliveredToPharmacyNotification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class DeliveryController extends Controller
{
    public function __construct(
        private WalletService $walletService,
        private WaitingFeeService $waitingFeeService,
        private CalculateCommissionAction $calculateCommission
    ) {}

    /**
     * Get courier's deliveries
     */
    public function index(Request $request)
    {
        $courier = $request->user()->courier;

        if (!$courier) {
            return response()->json([
                'success' => false,
                'message' => 'Profil livreur non trouvé',
            ], 403);
        }

        $status = $request->query('status');
        $perPage = min($request->input('per_page', 20), 50); // Max 50 par page

        if ($status === 'pending') {
             // For pending deliveries, show ALL unassigned deliveries (Marketplace mode)
             $query = Delivery::where('status', 'pending')
                ->whereNull('courier_id')
                ->with(['order.pharmacy', 'order.customer'])
                ->latest();
        } else {
             // For accepted/active/history, show only MY deliveries
             $query = $courier->deliveries()->with(['order.pharmacy', 'order.customer']);
             
             if ($status) {
                 if ($status === 'active') {
                     $query->whereIn('status', ['assigned', 'accepted', 'picked_up', 'in_transit']);
                 } elseif ($status === 'history') {
                     $query->whereIn('status', ['delivered', 'cancelled']);
                 } else {
                     $query->where('status', $status);
                 }
             }
             $query->latest();
        }
        
        $deliveries = $query->paginate($perPage);

        // Get commission rate for calculating estimated earnings
        $commissionAmount = WalletService::getCommissionAmount();

        $formattedDeliveries = $deliveries->getCollection()->map(function ($delivery) use ($commissionAmount) {
            $deliveryFee = (float) ($delivery->order->delivery_fee ?? WalletService::getDeliveryFeeBase());
            $estimatedEarnings = max(0, $deliveryFee - $commissionAmount);
            
            return [
                'id' => $delivery->id,
                'reference' => $delivery->order->reference ?? 'REF-UNKNOWN',
                'order_reference' => $delivery->order->reference ?? 'REF-UNKNOWN',
                'status' => $delivery->status,
                'pharmacy_name' => $delivery->order->pharmacy->name ?? 'Pharmacie Inconnue',
                'pharmacy_address' => $delivery->order->pharmacy->address ?? '',
                'pharmacy_phone' => $delivery->order->pharmacy->phone ?? '',
                'customer_name' => $delivery->order->customer->name ?? 'Client',
                'customer_phone' => $delivery->order->customer->phone ?? '',
                'pharmacy' => [
                    'name' => $delivery->order->pharmacy->name ?? 'Pharmacie',
                    'phone' => $delivery->order->pharmacy->phone ?? '',
                    'address' => $delivery->order->pharmacy->address ?? '',
                ],
                'customer' => [
                    'name' => $delivery->order->customer->name,
                    'phone' => $delivery->order->customer->phone,
                ],
                'delivery_address' => $delivery->order->delivery_address ?? 'Adresse inconnue',
                'pharmacy_latitude' => $delivery->pickup_latitude ? (float) $delivery->pickup_latitude : null,
                'pharmacy_longitude' => $delivery->pickup_longitude ? (float) $delivery->pickup_longitude : null,
                'delivery_latitude' => $delivery->dropoff_latitude ? (float) $delivery->dropoff_latitude : null,
                'delivery_longitude' => $delivery->dropoff_longitude ? (float) $delivery->dropoff_longitude : null,
                'total_amount' => (float) $delivery->order->total_amount,
                'delivery_fee' => $deliveryFee,
                'commission' => $commissionAmount,
                'estimated_earnings' => $estimatedEarnings,
                'distance_km' => $delivery->estimated_distance ? (float) $delivery->estimated_distance : null,
                'estimated_distance' => (float) $delivery->estimated_distance,
                'created_at' => $delivery->created_at->toIso8601String(),
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $formattedDeliveries,
            'meta' => [
                'current_page' => $deliveries->currentPage(),
                'last_page' => $deliveries->lastPage(),
                'per_page' => $deliveries->perPage(),
                'total' => $deliveries->total(),
            ],
        ]);
    }

    /**
     * Get delivery details
     */
    public function show(Request $request, $id)
    {
        $courier = $request->user()->courier;

        if (!$courier) {
            return response()->json([
                'success' => false,
                'message' => 'Profil livreur non trouvé',
            ], 403);
        }

        $delivery = $courier->deliveries()->with(['order.pharmacy', 'order.customer', 'order.items'])->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $delivery->id,
                'status' => $delivery->status,
                'order' => [
                    'reference' => $delivery->order->reference,
                    'total_amount' => (float) $delivery->order->total_amount,
                    'items_count' => $delivery->order->items->count(),
                ],
                'pharmacy' => [
                    'name' => $delivery->order->pharmacy->name,
                    'phone' => $delivery->order->pharmacy->phone,
                    'address' => $delivery->order->pharmacy->address,
                    'latitude' => $delivery->pickup_latitude ? (float) $delivery->pickup_latitude : null,
                    'longitude' => $delivery->pickup_longitude ? (float) $delivery->pickup_longitude : null,
                ],
                'customer' => [
                    'name' => $delivery->order->customer->name,
                    'phone' => $delivery->order->customer->phone,
                ],
                'delivery_address' => $delivery->order->delivery_address,
                'delivery_latitude' => $delivery->dropoff_latitude ? (float) $delivery->dropoff_latitude : null,
                'delivery_longitude' => $delivery->dropoff_longitude ? (float) $delivery->dropoff_longitude : null,
                'estimated_distance' => (float) $delivery->estimated_distance,
                'estimated_duration' => $delivery->estimated_duration,
                'picked_up_at' => $delivery->picked_up_at,
                'delivered_at' => $delivery->delivered_at,
            ],
        ]);
    }

    /**
     * Accept a delivery
     */
    public function accept(Request $request, $id)
    {
        $courier = $request->user()->courier;

        if (!$courier) {
            return response()->json([
                'success' => false,
                'message' => 'Profil livreur non trouvé',
            ], 403);
        }

        $delivery = Delivery::where('status', 'pending')->findOrFail($id);

        $delivery->update([
            'courier_id' => $courier->id,
            'status' => 'assigned',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Livraison acceptée',
        ]);
    }

    /**
     * Accept multiple deliveries in batch
     * POST /api/courier/deliveries/batch-accept
     */
    public function batchAccept(Request $request)
    {
        $request->validate([
            'delivery_ids' => 'required|array|min:1|max:5',
            'delivery_ids.*' => 'required|integer|exists:deliveries,id',
        ]);

        $courier = $request->user()->courier;

        if (!$courier) {
            return response()->json([
                'success' => false,
                'message' => 'Profil livreur non trouvé',
            ], 403);
        }

        // Check courier's active deliveries count (max 5 at once)
        $activeCount = $courier->deliveries()
            ->whereIn('status', ['assigned', 'picked_up'])
            ->count();
        
        $requestedCount = count($request->delivery_ids);
        
        if ($activeCount + $requestedCount > 5) {
            return response()->json([
                'success' => false,
                'message' => "Vous ne pouvez pas avoir plus de 5 livraisons actives. Actuellement: $activeCount",
            ], 400);
        }

        // Get available deliveries
        $deliveries = Delivery::whereIn('id', $request->delivery_ids)
            ->where('status', 'pending')
            ->whereNull('courier_id')
            ->get();

        if ($deliveries->count() !== $requestedCount) {
            $unavailable = $requestedCount - $deliveries->count();
            return response()->json([
                'success' => false,
                'message' => "$unavailable livraison(s) n'est/ne sont plus disponible(s)",
                'available_count' => $deliveries->count(),
            ], 400);
        }

        // Accept all deliveries in a transaction
        DB::transaction(function () use ($deliveries, $courier) {
            foreach ($deliveries as $delivery) {
                $delivery->update([
                    'courier_id' => $courier->id,
                    'status' => 'assigned',
                ]);
            }
        });

        // Calculate total estimated earnings
        $commissionAmount = WalletService::getCommissionAmount();
        $totalEarnings = $deliveries->sum(function ($d) use ($commissionAmount) {
            $fee = $d->order->delivery_fee ?? WalletService::getDeliveryFeeBase();
            return max(0, $fee - $commissionAmount);
        });

        return response()->json([
            'success' => true,
            'message' => "{$deliveries->count()} livraison(s) acceptée(s)",
            'data' => [
                'accepted_count' => $deliveries->count(),
                'delivery_ids' => $deliveries->pluck('id'),
                'total_estimated_earnings' => $totalEarnings,
            ],
        ]);
    }

    /**
     * Get optimized route for multiple active deliveries
     * GET /api/courier/deliveries/route
     */
    public function getOptimizedRoute(Request $request)
    {
        $courier = $request->user()->courier;

        if (!$courier) {
            return response()->json([
                'success' => false,
                'message' => 'Profil livreur non trouvé',
            ], 403);
        }

        $activeDeliveries = $courier->deliveries()
            ->whereIn('status', ['assigned', 'picked_up'])
            ->with(['order.pharmacy', 'order.customer'])
            ->get();

        if ($activeDeliveries->isEmpty()) {
            return response()->json([
                'success' => true,
                'data' => [
                    'stops' => [],
                    'total_distance_km' => 0,
                    'total_estimated_earnings' => 0,
                ],
            ]);
        }

        // Build stops list (pickup first, then dropoff)
        $stops = [];
        $commissionAmount = WalletService::getCommissionAmount();
        $totalEarnings = 0;

        // Group by status - pickups first for "assigned", then deliveries for "picked_up"
        $toPickup = $activeDeliveries->where('status', 'assigned');
        $toDeliver = $activeDeliveries->where('status', 'picked_up');

        foreach ($toPickup as $delivery) {
            $stops[] = [
                'delivery_id' => $delivery->id,
                'type' => 'pickup',
                'name' => $delivery->order->pharmacy->name ?? 'Pharmacie',
                'address' => $delivery->order->pharmacy->address ?? '',
                'phone' => $delivery->order->pharmacy->phone,
                'latitude' => (float) $delivery->pickup_latitude,
                'longitude' => (float) $delivery->pickup_longitude,
                'order_reference' => $delivery->order->reference,
            ];
        }

        foreach ($toDeliver as $delivery) {
            $fee = $delivery->order->delivery_fee ?? WalletService::getDeliveryFeeBase();
            $earnings = max(0, $fee - $commissionAmount);
            $totalEarnings += $earnings;

            $stops[] = [
                'delivery_id' => $delivery->id,
                'type' => 'dropoff',
                'name' => $delivery->order->customer->name ?? 'Client',
                'address' => $delivery->order->delivery_address ?? '',
                'phone' => $delivery->order->customer->phone,
                'latitude' => (float) $delivery->dropoff_latitude,
                'longitude' => (float) $delivery->dropoff_longitude,
                'order_reference' => $delivery->order->reference,
                'total_amount' => (float) $delivery->order->total_amount,
                'estimated_earnings' => $earnings,
            ];
        }

        // Calculate total distance (simple sum)
        $totalDistance = $activeDeliveries->sum('estimated_distance');

        return response()->json([
            'success' => true,
            'data' => [
                'stops' => $stops,
                'pickup_count' => $toPickup->count(),
                'delivery_count' => $toDeliver->count(),
                'total_distance_km' => round($totalDistance, 1),
                'total_estimated_earnings' => $totalEarnings,
            ],
        ]);
    }

    /**
     * Mark as picked up from pharmacy
     */
    public function pickup(Request $request, $id)
    {
        $courier = $request->user()->courier;

        if (!$courier) {
            return response()->json([
                'success' => false,
                'message' => 'Profil livreur non trouvé',
            ], 403);
        }

        $delivery = $courier->deliveries()->findOrFail($id);

        // Allow pickup from both 'assigned' and 'accepted' statuses
        if (!in_array($delivery->status, ['assigned', 'accepted'])) {
            return response()->json([
                'success' => false,
                'message' => 'Cette livraison ne peut pas être récupérée. Statut actuel: ' . $delivery->status,
            ], 400);
        }

        $delivery->update([
            'status' => 'picked_up',
            'picked_up_at' => now(),
        ]);

        $delivery->order->update(['status' => 'in_delivery']);

        return response()->json([
            'success' => true,
            'message' => 'Commande récupérée',
        ]);
    }

    /**
     * Mark as delivered to customer
     */
    public function deliver(Request $request, $id)
    {
        $validated = $request->validate([
            'delivery_proof_image' => 'nullable|string',
            'confirmation_code' => 'required|string|size:4',
        ], [
            'confirmation_code.required' => 'Le code de confirmation est requis',
            'confirmation_code.size' => 'Le code de confirmation doit contenir 4 chiffres',
        ]);

        $courier = $request->user()->courier;

        if (!$courier) {
            return response()->json([
                'success' => false,
                'message' => 'Profil livreur non trouvé',
            ], 403);
        }

        $courier = $request->user()->courier;

        if (!$courier) {
            return response()->json([
                'success' => false,
                'message' => 'Profil livreur non trouvé',
            ], 403);
        }

        try {
            // === TRANSACTION START ===
            // On utilise lockForUpdate pour empêcher que deux requêtes simultanées valident la même livraison
            $result = DB::transaction(function () use ($id, $validated, $courier) {
                
                // 1. Récupérer et VERROUILLER la livraison
                $delivery = $courier->deliveries()->with('order')->lockForUpdate()->find($id);

                if (!$delivery) {
                    throw new \Exception('Livraison introuvable', 404);
                }

                // 2. Vérifications d'état (Atomic)
                if ($delivery->status === 'delivered') {
                    throw new \Exception('Cette livraison a déjà été validée', 409); // 409 Conflict
                }

                if ($delivery->status !== 'picked_up') {
                    throw new \Exception('Cette livraison ne peut pas être marquée comme livrée (Statut: ' . $delivery->status . ')', 400);
                }

                if ($delivery->order->delivery_code !== $validated['confirmation_code']) {
                    throw new \Exception('Code de confirmation incorrect', 400);
                }

                // 3. Vérification du solde (Atomic)
                // Note: Idéalement on devrait aussi lock le wallet, mais walletService gère ses propres transactions.
                // Ici on vérifie juste la condition métier avant d'engager les changements d'état.
                if (!$this->walletService->canCompleteDelivery($courier)) {
                    throw new \Exception('Solde insuffisant pour la commission (' . WalletService::getCommissionAmount() . ' FCFA). Veuillez recharger.', 402);
                }

                // 4. Mise à jour des états
                $delivery->update([
                    'status' => 'delivered',
                    'delivered_at' => now(),
                    'delivery_proof_image' => $validated['delivery_proof_image'] ?? null,
                ]);

                $delivery->order->update([
                    'status' => 'delivered',
                    'delivered_at' => now(),
                ]);

                // 5. Mouvements financiers
                $deliveryFee = $delivery->order->delivery_fee ?? 0;
                $earningTransaction = null;
                
                if ($deliveryFee > 0) {
                    $earningTransaction = $this->walletService->creditDeliveryEarning($courier, $delivery, $deliveryFee);
                }

                $commissionTransaction = $this->walletService->deductCommission($courier, $delivery);

                // 6. Notifier la pharmacie que la livraison est terminée
                $pharmacy = $delivery->order->pharmacy;
                if ($pharmacy && $pharmacy->user) {
                    $pharmacy->user->notify(new OrderDeliveredToPharmacyNotification(
                        $delivery->order,
                        $delivery
                    ));
                    Log::info('Notification de livraison envoyée à la pharmacie', [
                        'pharmacy_id' => $pharmacy->id,
                        'order_id' => $delivery->order->id,
                    ]);
                }

                // 7. Calculer et distribuer les commissions pour la pharmacie (paiement cash)
                // Pour les paiements cash, le paiement est confirmé à la livraison
                // skipCourier=true car le coursier a déjà reçu ses gains via creditDeliveryEarning
                if (in_array($delivery->order->payment_mode, ['cash', 'on_delivery'])) {
                    try {
                        $this->calculateCommission->execute($delivery->order, skipCourier: true);
                        Log::info('Commissions calculées pour commande cash', [
                            'order_id' => $delivery->order->id,
                            'pharmacy_id' => $pharmacy?->id,
                        ]);
                    } catch (\Exception $e) {
                        Log::error('Erreur calcul commissions cash', [
                            'order_id' => $delivery->order->id,
                            'error' => $e->getMessage(),
                        ]);
                    }
                }

                Log::info('Livraison validée avec succès', [
                    'delivery_id' => $delivery->id,
                    'courier_id' => $courier->id,
                ]);

                return [
                    'commission' => $commissionTransaction,
                    'earning' => $earningTransaction,
                    'delivery_fee' => $deliveryFee,
                    'delivery' => $delivery
                ];
            });
            // === TRANSACTION END ===

            $balance = $this->walletService->getBalance($courier);

            $message = 'Livraison effectuée avec succès.';
            if ($result['delivery_fee'] > 0) {
                $message .= " Gains: +{$result['delivery_fee']} FCFA.";
            }
            $message .= ' Commission: -' . WalletService::getCommissionAmount() . ' FCFA.';

            return response()->json([
                'success' => true,
                'message' => $message,
                'data' => [
                    'earning' => [
                        'amount' => $result['delivery_fee'],
                        'reference' => $result['earning']?->reference,
                    ],
                    'commission' => [
                        'amount' => WalletService::getCommissionAmount(),
                        'reference' => $result['commission']->reference,
                    ],
                    'net_earning' => $result['delivery_fee'] - WalletService::getCommissionAmount(),
                    'wallet' => [
                        'balance' => $balance['balance'],
                        'currency' => $balance['currency'],
                    ],
                ],
            ]);

        } catch (\Exception $e) {
            // Gestion propre des erreurs HTTP
            $code = $e->getCode();
            if ($code < 100 || $code > 599) $code = 400;

            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], $code);
        }
    }

    /**
     * Update courier's current location
     */
    public function updateLocation(Request $request)
    {
        $validated = $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        $courier = $request->user()->courier;

        if (!$courier) {
            return response()->json([
                'success' => false,
                'message' => 'Profil livreur non trouvé',
            ], 403);
        }

        $courier->updateLocation($validated['latitude'], $validated['longitude']);

        return response()->json([
            'success' => true,
            'message' => 'Position mise à jour',
        ]);
    }

    /**
     * Toggle courier availability
     * 
     * Si 'status' est fourni dans la requête, définit ce statut explicitement.
     * Sinon, fait un toggle entre 'available' et 'offline'.
     */
    public function toggleAvailability(Request $request)
    {
        $courier = $request->user()->courier;

        if (!$courier) {
            return response()->json([
                'success' => false,
                'message' => 'Profil livreur non trouvé',
            ], 403);
        }

        // Si un statut explicite est fourni, l'utiliser
        // Sinon, faire un toggle classique
        if ($request->has('status') && in_array($request->status, ['available', 'offline'])) {
            $newStatus = $request->status;
        } else {
            $newStatus = $courier->status === 'available' ? 'offline' : 'available';
        }

        $courier->update(['status' => $newStatus]);

        return response()->json([
            'success' => true,
            'message' => $newStatus === 'available' ? 'Vous êtes maintenant disponible' : 'Vous êtes maintenant hors ligne',
            'data' => [
                'status' => $newStatus,
                'is_online' => $newStatus === 'available',
            ],
        ]);
    }

    /**
     * Get courier profile and stats
     */
    public function profile(Request $request)
    {
        $courier = $request->user()->courier;

        if (!$courier) {
            return response()->json([
                'success' => false,
                'message' => 'Profil livreur non trouvé',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $courier->id,
                'name' => $request->user()->name,
                'email' => $request->user()->email,
                'avatar' => $request->user()->avatar,
                'status' => $courier->status,
                'vehicle_type' => $courier->vehicle_type,
                'plate_number' => $courier->plate_number,
                'rating' => $courier->rating,
                'completed_deliveries' => $courier->deliveries()->where('status', 'delivered')->count(),
                'earnings' => $courier->commissionLines()->sum('amount'),
            ],
        ]);
    }

    /**
     * Rate a customer after delivery
     * 
     * POST /api/courier/deliveries/{id}/rate-customer
     */
    public function rateCustomer(Request $request, $id)
    {
        $courier = $request->user()->courier;

        if (!$courier) {
            return response()->json([
                'success' => false,
                'message' => 'Profil livreur non trouvé',
            ], 403);
        }

        $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:500',
            'tags' => 'nullable|array',
            'tags.*' => 'string|max:50',
        ]);

        $delivery = $courier->deliveries()
            ->where('status', 'delivered')
            ->findOrFail($id);

        // Check if already rated
        if ($delivery->customer_rating) {
            return response()->json([
                'success' => false,
                'message' => 'Ce client a déjà été noté pour cette livraison',
            ], 422);
        }

        // Save rating
        $delivery->update([
            'customer_rating' => $request->rating,
            'customer_rating_comment' => $request->comment,
            'customer_rating_tags' => $request->tags ? json_encode($request->tags) : null,
            'customer_rated_at' => now(),
        ]);

        // Update customer's average rating
        $customer = $delivery->order->customer;
        if ($customer) {
            $avgRating = Delivery::whereHas('order', function ($q) use ($customer) {
                    $q->where('customer_id', $customer->id);
                })
                ->whereNotNull('customer_rating')
                ->avg('customer_rating');
            
            $customer->update(['courier_rating' => round($avgRating, 2)]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Merci pour votre évaluation !',
            'data' => [
                'rating' => $request->rating,
            ],
        ]);
    }

    /**
     * Signaler l'arrivée et démarrer le compteur d'attente
     * 
     * POST /api/courier/deliveries/{id}/arrived
     * 
     * Le livreur signale qu'il est arrivé chez le client.
     * Démarre la minuterie d'attente avec frais (100 FCFA/min après les minutes gratuites).
     * Après le délai max configuré (ex: 10 min), la livraison est automatiquement annulée.
     * 
     * Envoie une notification aux 3 acteurs (client, livreur, pharmacie) avec le décompte.
     */
    public function arrived(Request $request, $id)
    {
        $courier = $request->user()->courier;

        if (!$courier) {
            return response()->json([
                'success' => false,
                'message' => 'Profil livreur non trouvé',
            ], 403);
        }

        $delivery = $courier->deliveries()->with(['order.user', 'order.pharmacy.user'])->findOrFail($id);

        // Vérifier que la livraison est en transit (picked_up)
        if ($delivery->status !== 'picked_up') {
            return response()->json([
                'success' => false,
                'message' => 'La livraison doit être en transit pour signaler votre arrivée',
            ], 400);
        }

        // Vérifier si le compteur n'est pas déjà démarré
        if ($delivery->waiting_started_at) {
            $waitingInfo = $this->waitingFeeService->getWaitingInfo($delivery);
            return response()->json([
                'success' => false,
                'message' => 'Le compteur d\'attente est déjà démarré',
                'data' => [
                    'waiting_info' => $waitingInfo,
                ],
            ], 400);
        }

        // Démarrer le compteur d'attente
        $delivery->update([
            'status' => 'in_transit', // Reste en transit, mais attente démarrée
            'waiting_started_at' => now(),
        ]);

        $delivery = $delivery->fresh();
        $waitingInfo = $this->waitingFeeService->getWaitingInfo($delivery);

        // === NOTIFIER LES 3 ACTEURS ===
        
        // 1. Notifier le CLIENT (avec avertissement des frais après minutes gratuites)
        if ($delivery->order->user) {
            $delivery->order->user->notify(new CourierArrivedNotification(
                $delivery,
                $waitingInfo['timeout_minutes'],
                $waitingInfo['free_minutes'],
                $waitingInfo['fee_per_minute'],
                'customer'
            ));
        }

        // 2. Notifier le LIVREUR (confirmation avec infos décompte)
        if ($courier->user) {
            $courier->user->notify(new CourierArrivedNotification(
                $delivery,
                $waitingInfo['timeout_minutes'],
                $waitingInfo['free_minutes'],
                $waitingInfo['fee_per_minute'],
                'courier'
            ));
        }

        // 3. Notifier la PHARMACIE (info que le livreur est arrivé)
        if ($delivery->order->pharmacy?->user) {
            $delivery->order->pharmacy->user->notify(new CourierArrivedNotification(
                $delivery,
                $waitingInfo['timeout_minutes'],
                $waitingInfo['free_minutes'],
                $waitingInfo['fee_per_minute'],
                'pharmacy'
            ));
        }

        Log::info('Livreur arrivé - Minuterie démarrée - 3 acteurs notifiés', [
            'delivery_id' => $delivery->id,
            'courier_id' => $courier->id,
            'timeout_minutes' => $waitingInfo['timeout_minutes'],
            'free_minutes' => $waitingInfo['free_minutes'],
            'fee_per_minute' => $waitingInfo['fee_per_minute'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Arrivée signalée. Minuterie d\'attente démarrée. Client, livreur et pharmacie notifiés.',
            'data' => [
                'waiting_info' => $waitingInfo,
            ],
        ]);
    }

    /**
     * Obtenir le statut de la minuterie d'attente
     * 
     * GET /api/courier/deliveries/{id}/waiting-status
     */
    public function waitingStatus(Request $request, $id)
    {
        $courier = $request->user()->courier;

        if (!$courier) {
            return response()->json([
                'success' => false,
                'message' => 'Profil livreur non trouvé',
            ], 403);
        }

        $delivery = $courier->deliveries()->findOrFail($id);
        $waitingInfo = $this->waitingFeeService->getWaitingInfo($delivery);

        return response()->json([
            'success' => true,
            'data' => [
                'delivery_id' => $delivery->id,
                'status' => $delivery->status,
                'waiting_info' => $waitingInfo,
            ],
        ]);
    }

    /**
     * Obtenir les paramètres de minuterie (pour l'UI du livreur)
     * 
     * GET /api/courier/waiting-settings
     */
    public function getWaitingSettings(Request $request)
    {
        $settings = $this->waitingFeeService->getSettings();

        return response()->json([
            'success' => true,
            'data' => [
                'timeout_minutes' => $settings['timeout_minutes'],
                'fee_per_minute' => $settings['fee_per_minute'],
                'free_minutes' => $settings['free_minutes'],
                'currency' => 'FCFA',
            ],
        ]);
    }

    /**
     * Reject a delivery
     */
    public function reject(Request $request, $id)
    {
        $courier = $request->user()->courier;

        if (!$courier) {
            return response()->json([
                'success' => false,
                'message' => 'Profil livreur non trouvé',
            ], 403);
        }

        // We can only reject pending deliveries (not yet assigned) 
        // OR deliveries assigned to this courier but handled as a "cancellation" before pickup
        // This flow specifically handles "Refusing a PENDING offer"
        $delivery = Delivery::findOrFail($id);

        if ($delivery->status !== 'pending') {
             return response()->json([
                'success' => false,
                'message' => 'Cette livraison ne peut plus être refusée (déjà assignée ou annulée)',
            ], 400);
        }

        // Logic: Add courier to a "rejected_by" list so they don't see it again
        // For simple implementation, we might just do nothing on the delivery itself 
        // but adding an entry to a pivot table `delivery_rejections` would be best.
        // For MVP: We return success so the mobile app hides it locally.
        
        // TODO: Implement proper "rejected_by" logic in future to prevent reappearing
        // $delivery->rejectedCouriers()->attach($courier->id);

        return response()->json([
            'success' => true,
            'message' => 'Livraison ignorée',
        ]);
    }
}
