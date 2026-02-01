<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\WalletService;
use Illuminate\Http\Request;

/**
 * Controller pour récupérer les paramètres de tarification
 * Permet au client mobile de calculer les frais avant de passer commande
 */
class PricingController extends Controller
{
    /**
     * Récupérer tous les paramètres de tarification
     * 
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'delivery' => WalletService::getDeliveryPricing(),
                'service' => WalletService::getServicePricing(),
            ],
        ]);
    }

    /**
     * Calculer les frais pour un panier donné
     * 
     * Permet au client de voir le détail des frais avant de confirmer la commande
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function calculate(Request $request)
    {
        $validated = $request->validate([
            'subtotal' => 'required|numeric|min:0',
            'delivery_fee' => 'required|numeric|min:0',
            'payment_mode' => 'required|in:cash,mobile_money,card,platform,on_delivery',
        ]);

        // Normaliser le payment_mode
        $paymentMode = match($validated['payment_mode']) {
            'platform' => 'mobile_money',
            'on_delivery' => 'cash',
            default => $validated['payment_mode'],
        };

        $subtotal = (int) $validated['subtotal'];
        $deliveryFee = (int) $validated['delivery_fee'];

        $fees = WalletService::calculateAllFees($subtotal, $deliveryFee, $paymentMode);

        return response()->json([
            'success' => true,
            'data' => [
                'subtotal' => $fees['subtotal'],
                'delivery_fee' => $fees['delivery_fee'],
                'service_fee' => $fees['service_fee'],
                'payment_fee' => $fees['payment_fee'],
                'total_amount' => $fees['total_amount'],
                'pharmacy_amount' => $fees['pharmacy_amount'],
                'breakdown' => [
                    'medications' => $fees['subtotal'],
                    'delivery' => $fees['delivery_fee'],
                    'service' => $fees['service_fee'],
                    'payment_processing' => $fees['payment_fee'],
                ],
                'note' => 'La pharmacie reçoit ' . number_format($fees['pharmacy_amount']) . ' FCFA (prix exact des médicaments)',
            ],
        ]);
    }

    /**
     * Estimer les frais de livraison selon la distance
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function estimateDelivery(Request $request)
    {
        $validated = $request->validate([
            'distance_km' => 'required|numeric|min:0',
        ]);

        $distanceKm = (float) $validated['distance_km'];
        $deliveryFee = WalletService::calculateDeliveryFee($distanceKm);

        return response()->json([
            'success' => true,
            'data' => [
                'distance_km' => $distanceKm,
                'delivery_fee' => $deliveryFee,
                'pricing' => WalletService::getDeliveryPricing(),
            ],
        ]);
    }
}
