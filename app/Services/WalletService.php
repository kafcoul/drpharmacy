<?php

namespace App\Services;

use App\Models\Wallet;
use App\Models\WalletTransaction;
use App\Models\Courier;
use App\Models\Delivery;
use App\Models\Setting;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Exception;

class WalletService
{
    /**
     * Montant de la commission Dr Pharma par livraison (par défaut)
     * Utilisez getCommissionAmount() pour obtenir la valeur paramétrable
     */
    public const DEFAULT_COMMISSION_AMOUNT = 200; // FCFA

    /**
     * Récupérer le montant de la commission depuis les paramètres
     */
    public static function getCommissionAmount(): int
    {
        return (int) Setting::get('courier_commission_amount', self::DEFAULT_COMMISSION_AMOUNT);
    }

    /**
     * Récupérer le solde minimum requis depuis les paramètres
     */
    public static function getMinimumWalletBalance(): int
    {
        return (int) Setting::get('minimum_wallet_balance', self::DEFAULT_COMMISSION_AMOUNT);
    }

    /**
     * Récupérer les frais de livraison de base depuis les paramètres
     */
    public static function getDeliveryFeeBase(): int
    {
        return (int) Setting::get('delivery_fee_base', 500);
    }

    /**
     * Récupérer le montant minimum de retrait depuis les paramètres
     */
    public static function getMinimumWithdrawalAmount(): int
    {
        return (int) Setting::get('minimum_withdrawal_amount', 500);
    }

    /**
     * Récupérer ou créer le wallet d'un coursier
     */
    public function getOrCreateWallet(Courier $courier): Wallet
    {
        return Wallet::firstOrCreate(
            [
                'walletable_type' => Courier::class,
                'walletable_id' => $courier->id,
            ],
            [
                'balance' => 0,
                'currency' => 'XOF',
            ]
        );
    }

    /**
     * Récupérer le wallet de la plateforme Dr Pharma
     */
    public function getPlatformWallet(): Wallet
    {
        return Wallet::platform();
    }

    /**
     * Vérifier si le coursier peut effectuer une livraison
     */
    public function canCompleteDelivery(Courier $courier): bool
    {
        $wallet = $this->getOrCreateWallet($courier);
        return $wallet->balance >= self::getCommissionAmount();
    }

    /**
     * Recharger le wallet d'un coursier
     */
    public function topUp(
        Courier $courier,
        float $amount,
        string $paymentMethod,
        ?string $paymentReference = null
    ): WalletTransaction {
        if ($amount <= 0) {
            throw new Exception('Le montant doit être positif');
        }

        $wallet = $this->getOrCreateWallet($courier);
        $reference = 'TOP-' . strtoupper(Str::random(8));

        return DB::transaction(function () use ($wallet, $amount, $reference, $paymentMethod, $paymentReference) {
            $balanceBefore = $wallet->balance;
            
            $transaction = $wallet->credit(
                $amount,
                $reference,
                "Rechargement via {$paymentMethod}",
                [
                    'payment_method' => $paymentMethod,
                    'payment_reference' => $paymentReference,
                ]
            );

            // Mettre à jour les champs supplémentaires
            $transaction->update([
                'category' => 'topup',
                'payment_method' => $paymentMethod,
                'status' => 'completed',
            ]);

            return $transaction->fresh();
        });
    }

    /**
     * Créditer les gains de livraison au coursier
     */
    public function creditDeliveryEarning(Courier $courier, Delivery $delivery, float $amount): WalletTransaction
    {
        if ($amount <= 0) {
            throw new Exception('Le montant des gains doit être positif');
        }

        $wallet = $this->getOrCreateWallet($courier);
        $reference = $delivery->order->reference ?? 'DEL-' . $delivery->id;

        return DB::transaction(function () use ($wallet, $amount, $reference, $delivery) {
            $transaction = $wallet->credit(
                $amount,
                $reference,
                "Livraison - Commande {$reference}",
                [
                    'delivery_id' => $delivery->id,
                    'order_id' => $delivery->order_id,
                ]
            );

            // Mettre à jour les champs supplémentaires
            $transaction->update([
                'category' => 'delivery_earning',
                'delivery_id' => $delivery->id,
                'status' => 'completed',
            ]);

            return $transaction->fresh();
        });
    }

    /**
     * Créditer un bonus au coursier (challenge, promotion, etc.)
     */
    public function creditBonus(Courier $courier, float $amount, string $description, ?int $challengeId = null): WalletTransaction
    {
        if ($amount <= 0) {
            throw new Exception('Le montant du bonus doit être positif');
        }

        $wallet = $this->getOrCreateWallet($courier);
        $reference = 'BONUS-' . strtoupper(Str::random(8));

        return DB::transaction(function () use ($wallet, $amount, $reference, $description, $challengeId) {
            $transaction = $wallet->credit(
                $amount,
                $reference,
                $description,
                $challengeId ? ['challenge_id' => $challengeId] : []
            );

            // Mettre à jour les champs supplémentaires
            $transaction->update([
                'category' => 'bonus',
                'status' => 'completed',
            ]);

            return $transaction->fresh();
        });
    }

    /**
     * Prélever la commission lors de la validation d'une livraison
     */
    public function deductCommission(Courier $courier, Delivery $delivery): WalletTransaction
    {
        $wallet = $this->getOrCreateWallet($courier);
        $commissionAmount = self::getCommissionAmount();
        
        if (!$wallet->hasSufficientBalance($commissionAmount)) {
            throw new Exception('Solde insuffisant pour la commission. Veuillez recharger votre wallet.');
        }

        $reference = 'COM-' . strtoupper(Str::random(8));

        return DB::transaction(function () use ($wallet, $delivery, $reference, $commissionAmount) {
            // 1. Débiter le wallet du coursier
            $courierTransaction = $wallet->debit(
                $commissionAmount,
                $reference,
                "Commission livraison #{$delivery->id}",
                ['delivery_id' => $delivery->id]
            );

            $courierTransaction->update([
                'category' => 'commission',
                'delivery_id' => $delivery->id,
                'status' => 'completed',
            ]);

            // 2. Créditer le wallet de la plateforme
            $platformWallet = $this->getPlatformWallet();
            $platformTransaction = $platformWallet->credit(
                $commissionAmount,
                $reference . '-PLT',
                "Commission livraison #{$delivery->id} (Coursier: {$wallet->walletable->user->name})",
                [
                    'delivery_id' => $delivery->id,
                    'courier_id' => $wallet->walletable_id,
                    'source_transaction_id' => $courierTransaction->id,
                ]
            );

            $platformTransaction->update([
                'category' => 'commission',
                'delivery_id' => $delivery->id,
                'status' => 'completed',
            ]);

            return $courierTransaction->fresh();
        });
    }

    /**
     * Demander un retrait vers Mobile Money
     */
    public function requestWithdrawal(
        Courier $courier,
        float $amount,
        string $paymentMethod,
        string $phoneNumber
    ): WalletTransaction {
        $wallet = $this->getOrCreateWallet($courier);
        $minWithdrawal = self::getMinimumWithdrawalAmount();
        
        if (!$wallet->hasSufficientBalance($amount)) {
            throw new Exception('Solde insuffisant pour ce retrait');
        }

        if ($amount < $minWithdrawal) {
            throw new Exception("Le montant minimum de retrait est de {$minWithdrawal} FCFA");
        }

        $reference = 'WTH-' . strtoupper(Str::random(8));

        return DB::transaction(function () use ($wallet, $amount, $reference, $paymentMethod, $phoneNumber) {
            $transaction = $wallet->debit(
                $amount,
                $reference,
                "Retrait vers {$paymentMethod} ({$phoneNumber})",
                [
                    'payment_method' => $paymentMethod,
                    'phone_number' => $phoneNumber,
                ]
            );

            $transaction->update([
                'category' => 'withdrawal',
                'payment_method' => $paymentMethod,
                'status' => 'pending', // En attente de traitement par l'admin
            ]);

            return $transaction->fresh();
        });
    }

    /**
     * Obtenir l'historique des transactions
     */
    public function getTransactionHistory(Courier $courier, int $limit = 50): \Illuminate\Database\Eloquent\Collection
    {
        $wallet = $this->getOrCreateWallet($courier);
        
        return $wallet->transactions()
            ->with('wallet')
            ->orderByDesc('created_at')
            ->limit($limit)
            ->get();
    }

    /**
     * Obtenir le solde actuel
     */
    public function getBalance(Courier $courier): array
    {
        $wallet = $this->getOrCreateWallet($courier);
        $commissionAmount = self::getCommissionAmount();
        
        // Calculer les retraits en attente
        $pendingWithdrawals = $wallet->transactions()
            ->where('category', 'withdrawal')
            ->where('status', 'pending')
            ->sum('amount');

        return [
            'balance' => (float) $wallet->balance,
            'currency' => $wallet->currency,
            'pending_withdrawals' => (float) $pendingWithdrawals,
            'available_balance' => (float) ($wallet->balance - $pendingWithdrawals),
            'can_deliver' => $wallet->balance >= $commissionAmount,
            'commission_amount' => $commissionAmount,
            'minimum_balance' => self::getMinimumWalletBalance(),
            'delivery_fee_base' => self::getDeliveryFeeBase(),
        ];
    }

    /**
     * Obtenir les statistiques du wallet
     */
    public function getStatistics(Courier $courier): array
    {
        $wallet = $this->getOrCreateWallet($courier);
        
        $stats = $wallet->transactions()
            ->selectRaw("
                category,
                SUM(CASE WHEN type = 'CREDIT' THEN amount ELSE 0 END) as total_credits,
                SUM(CASE WHEN type = 'DEBIT' THEN amount ELSE 0 END) as total_debits,
                COUNT(*) as count
            ")
            ->groupBy('category')
            ->get()
            ->keyBy('category');

        return [
            'total_topups' => (float) ($stats->get('topup')->total_credits ?? 0),
            'total_delivery_earnings' => (float) ($stats->get('delivery_earning')->total_credits ?? 0),
            'total_commissions' => (float) ($stats->get('commission')->total_debits ?? 0),
            'total_withdrawals' => (float) ($stats->get('withdrawal')->total_debits ?? 0),
            'deliveries_count' => (int) ($stats->get('commission')->count ?? 0),
        ];
    }
}
