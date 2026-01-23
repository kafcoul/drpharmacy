<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Courier;
use App\Models\Delivery;
use App\Models\Order;
use App\Services\CourierAssignmentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CourierAssignmentController extends Controller
{
    protected CourierAssignmentService $assignmentService;

    public function __construct(CourierAssignmentService $assignmentService)
    {
        $this->assignmentService = $assignmentService;
    }

    /**
     * Obtenir les livreurs disponibles pour une commande
     */
    public function getAvailableCouriers(Order $order): JsonResponse
    {
        $pharmacy = $order->pharmacy;

        if (!$pharmacy->latitude || !$pharmacy->longitude) {
            return response()->json([
                'success' => false,
                'message' => 'La pharmacie n\'a pas de coordonnées GPS',
            ], 400);
        }

        $couriers = $this->assignmentService->getAvailableCouriersInRadius(
            $pharmacy->latitude,
            $pharmacy->longitude,
            15
        );

        return response()->json([
            'success' => true,
            'data' => [
                'couriers' => $couriers->map(function ($courier) use ($order) {
                    $estimatedTime = $this->assignmentService->estimateDeliveryTime(
                        $order->pharmacy->latitude,
                        $order->pharmacy->longitude,
                        $order->delivery_latitude,
                        $order->delivery_longitude,
                        $courier->vehicle_type
                    );

                    return [
                        'id' => $courier->id,
                        'name' => $courier->name,
                        'phone' => $courier->phone,
                        'vehicle_type' => $courier->vehicle_type,
                        'rating' => $courier->rating,
                        'completed_deliveries' => $courier->completed_deliveries,
                        'distance' => round($courier->distance, 2),
                        'estimated_delivery_time' => $estimatedTime,
                    ];
                }),
            ],
        ]);
    }

    /**
     * Assigner automatiquement un livreur
     */
    public function autoAssign(Order $order): JsonResponse
    {
        if ($order->delivery()->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Cette commande a déjà une livraison assignée',
            ], 400);
        }

        $delivery = $this->assignmentService->assignCourier($order);

        if (!$delivery) {
            return response()->json([
                'success' => false,
                'message' => 'Aucun livreur disponible trouvé',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Livreur assigné automatiquement',
            'data' => [
                'delivery' => $delivery->load('courier'),
            ],
        ]);
    }

    /**
     * Assigner manuellement un livreur spécifique
     */
    public function manualAssign(Request $request, Order $order): JsonResponse
    {
        $request->validate([
            'courier_id' => 'required|exists:couriers,id',
        ]);

        $courier = Courier::findOrFail($request->courier_id);

        $delivery = $this->assignmentService->assignSpecificCourier($order, $courier);

        if (!$delivery) {
            return response()->json([
                'success' => false,
                'message' => 'Impossible d\'assigner ce livreur',
            ], 400);
        }

        return response()->json([
            'success' => true,
            'message' => 'Livreur assigné manuellement',
            'data' => [
                'delivery' => $delivery->load('courier'),
            ],
        ]);
    }

    /**
     * Réassigner une livraison à un autre livreur
     */
    public function reassign(Delivery $delivery): JsonResponse
    {
        $newCourier = $this->assignmentService->reassignDelivery($delivery);

        if (!$newCourier) {
            return response()->json([
                'success' => false,
                'message' => 'Impossible de réassigner cette livraison',
            ], 400);
        }

        return response()->json([
            'success' => true,
            'message' => 'Livraison réassignée avec succès',
            'data' => [
                'delivery' => $delivery->fresh()->load('courier'),
                'new_courier' => $newCourier,
            ],
        ]);
    }

    /**
     * Calculer le temps de livraison estimé
     */
    public function estimateDeliveryTime(Order $order, Request $request): JsonResponse
    {
        $request->validate([
            'vehicle_type' => 'required|in:motorcycle,bicycle,car,walking',
        ]);

        $estimatedTime = $this->assignmentService->estimateDeliveryTime(
            $order->pharmacy->latitude,
            $order->pharmacy->longitude,
            $order->delivery_latitude,
            $order->delivery_longitude,
            $request->vehicle_type
        );

        return response()->json([
            'success' => true,
            'data' => [
                'estimated_time_minutes' => $estimatedTime,
                'vehicle_type' => $request->vehicle_type,
            ],
        ]);
    }
}
