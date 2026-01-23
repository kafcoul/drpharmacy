<?php

namespace App\Actions;

use App\Models\Commission;
use App\Models\CommissionLine;
use App\Models\Order;
use App\Models\Wallet;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class CalculateCommissionAction
{
    /**
     * Calculer et distribuer les commissions pour une commande
     */
    public function execute(Order $order): Commission
    {
        return DB::transaction(function () use ($order) {
            // Vérifier si la commande a déjà des commissions
            if ($order->commission) {
                Log::info('Commission already calculated', ['order_id' => $order->id]);
                return $order->commission;
            }

            // Obtenir les taux de commission
            $platformRate = config('commission.platform_rate', 0.10); // 10%
            $pharmacyRate = $order->pharmacy->commission_rate_pharmacy ?? config('commission.pharmacy_rate', 0.85); // 85%
            $courierRate = config('commission.courier_rate', 0.05); // 5%

            // Calculer les montants
            $totalAmount = $order->total_amount;
            $platformAmount = $totalAmount * $platformRate;
            $pharmacyAmount = $totalAmount * $pharmacyRate;
            $courierAmount = $totalAmount * $courierRate;

            // Créer le record Commission
            $commission = Commission::create([
                'order_id' => $order->id,
                'total_amount' => $totalAmount,
                'calculated_at' => now(),
            ]);

            // Créer les lignes de commission
            $commissionLines = [
                // Platform
                [
                    'commission_id' => $commission->id,
                    'actor_type' => 'platform',
                    'actor_id' => null,
                    'rate' => $platformRate,
                    'amount' => $platformAmount,
                ],
                // Pharmacy
                [
                    'commission_id' => $commission->id,
                    'actor_type' => 'App\Models\Pharmacy',
                    'actor_id' => $order->pharmacy_id,
                    'rate' => $pharmacyRate,
                    'amount' => $pharmacyAmount,
                ],
                // Courier (si delivery existe)
                [
                    'commission_id' => $commission->id,
                    'actor_type' => 'App\Models\Courier',
                    'actor_id' => $order->delivery?->courier_id,
                    'rate' => $courierRate,
                    'amount' => $courierAmount,
                ],
            ];

            foreach ($commissionLines as $lineData) {
                CommissionLine::create($lineData);
            }

            // Créditer les wallets
            $this->creditWallets($commission);

            Log::info('Commission calculated and distributed', [
                'order_id' => $order->id,
                'commission_id' => $commission->id,
                'platform_amount' => $platformAmount,
                'pharmacy_amount' => $pharmacyAmount,
                'courier_amount' => $courierAmount,
            ]);

            return $commission;
        });
    }

    /**
     * Créditer les wallets de chaque acteur
     */
    protected function creditWallets(Commission $commission): void
    {
        foreach ($commission->lines as $line) {
            // Wallet de la plateforme
            if ($line->actor_type === 'platform') {
                $wallet = Wallet::platform();
                $wallet->credit(
                    $line->amount,
                    "COMMISSION-{$commission->id}",
                    "Commission plateforme pour commande #{$commission->order->reference}",
                    ['commission_id' => $commission->id]
                );
                continue;
            }

            // Wallet de la pharmacie ou du livreur
            if ($line->actor && $line->actor_id) {
                $wallet = $line->actor->wallet ?? $line->actor->wallet()->create([
                    'balance' => 0,
                    'currency' => 'XOF',
                ]);

                $wallet->credit(
                    $line->amount,
                    "COMMISSION-{$commission->id}",
                    "Commission pour commande #{$commission->order->reference}",
                    ['commission_id' => $commission->id]
                );
            }
        }
    }
}
