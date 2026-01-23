<?php

namespace App\Services;

use App\Enums\JekoPaymentMethod;
use App\Enums\JekoPaymentStatus;
use App\Models\JekoPayment;
use App\Models\User;
use App\Notifications\NewOrderReceivedNotification;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class JekoPaymentService
{
    private string $apiUrl;
    private string $apiKey;
    private string $apiKeyId;
    private string $storeId;
    private string $webhookSecret;

    public function __construct()
    {
        $this->apiUrl = config('services.jeko.api_url', 'https://api.jeko.africa');
        $this->apiKey = config('services.jeko.api_key');
        $this->apiKeyId = config('services.jeko.api_key_id');
        $this->storeId = config('services.jeko.store_id');
        $this->webhookSecret = config('services.jeko.webhook_secret');
    }

    /**
     * Créer une demande de paiement redirect JEKO
     *
     * @param Model $payable Entité payable (Order, Wallet, etc.)
     * @param int $amountCents Montant en centimes
     * @param JekoPaymentMethod $method Méthode de paiement
     * @param User|null $user Utilisateur qui initie le paiement
     * @param string|null $description Description du paiement
     * @return JekoPayment
     * @throws \Exception
     */
    public function createRedirectPayment(
        Model $payable,
        int $amountCents,
        JekoPaymentMethod $method,
        ?User $user = null,
        ?string $description = null
    ): JekoPayment {
        // Validation du montant minimum (100 centimes = 1 XOF)
        if ($amountCents < 100) {
            throw new \InvalidArgumentException('Le montant minimum est de 100 centimes (1 XOF)');
        }

        // Créer l'enregistrement local d'abord
        $payment = JekoPayment::create([
            'payable_type' => get_class($payable),
            'payable_id' => $payable->id,
            'user_id' => $user?->id,
            'amount_cents' => $amountCents,
            'currency' => 'XOF',
            'payment_method' => $method,
            'status' => JekoPaymentStatus::PENDING,
            'initiated_at' => now(),
        ]);

        // Construire les URLs de callback
        $baseUrl = config('app.url');
        $successUrl = "{$baseUrl}/api/payments/callback/success?reference={$payment->reference}";
        $errorUrl = "{$baseUrl}/api/payments/callback/error?reference={$payment->reference}";

        $payment->update([
            'success_url' => $successUrl,
            'error_url' => $errorUrl,
        ]);

        // MODE SANDBOX: Si les clés JEKO ne sont pas configurées, simuler le paiement
        if ($this->isSandboxMode()) {
            return $this->handleSandboxPayment($payment, $payable);
        }

        try {
            // Appel API JEKO
            $response = Http::withHeaders([
                'X-API-KEY' => $this->apiKey,
                'X-API-KEY-ID' => $this->apiKeyId,
                'Content-Type' => 'application/json',
            ])->post("{$this->apiUrl}/partner_api/payment_requests", [
                'storeId' => $this->storeId,
                'amountCents' => $amountCents,
                'currency' => 'XOF',
                'reference' => $payment->reference,
                'paymentDetails' => [
                    'type' => 'redirect',
                    'data' => [
                        'paymentMethod' => $method->value,
                        'successUrl' => $successUrl,
                        'errorUrl' => $errorUrl,
                    ],
                ],
            ]);

            if (!$response->successful()) {
                $errorBody = $response->json();
                Log::error('JEKO API Error', [
                    'reference' => $payment->reference,
                    'status' => $response->status(),
                    'body' => $errorBody,
                ]);

                $payment->markAsFailed($errorBody['message'] ?? 'Erreur API JEKO');
                throw new \Exception($errorBody['message'] ?? 'Erreur lors de la création du paiement JEKO');
            }

            $data = $response->json();

            // Mettre à jour avec les données JEKO
            $payment->update([
                'jeko_payment_request_id' => $data['id'],
                'redirect_url' => $data['redirectUrl'],
                'status' => JekoPaymentStatus::PROCESSING,
            ]);

            Log::info('JEKO Payment Created', [
                'reference' => $payment->reference,
                'jeko_id' => $data['id'],
                'redirect_url' => $data['redirectUrl'],
            ]);

            return $payment->fresh();

        } catch (\Illuminate\Http\Client\RequestException $e) {
            Log::error('JEKO API Request Exception', [
                'reference' => $payment->reference,
                'message' => $e->getMessage(),
            ]);

            $payment->markAsFailed('Erreur de connexion à JEKO: ' . $e->getMessage());
            throw new \Exception('Impossible de contacter le service de paiement');
        }
    }

    /**
     * Vérifier le statut d'un paiement via l'API JEKO
     */
    public function checkPaymentStatus(JekoPayment $payment): JekoPayment
    {
        if (!$payment->jeko_payment_request_id) {
            return $payment;
        }

        // Ne pas vérifier si déjà finalisé
        if ($payment->isFinal()) {
            return $payment;
        }

        try {
            $response = Http::withHeaders([
                'X-API-KEY' => $this->apiKey,
                'X-API-KEY-ID' => $this->apiKeyId,
            ])->get("{$this->apiUrl}/partner_api/payment_requests/{$payment->jeko_payment_request_id}");

            if (!$response->successful()) {
                Log::warning('JEKO Status Check Failed', [
                    'reference' => $payment->reference,
                    'status' => $response->status(),
                ]);
                return $payment;
            }

            $data = $response->json();
            
            return $this->updatePaymentFromJekoResponse($payment, $data);

        } catch (\Exception $e) {
            Log::error('JEKO Status Check Exception', [
                'reference' => $payment->reference,
                'message' => $e->getMessage(),
            ]);
            return $payment;
        }
    }

    /**
     * Traiter un webhook JEKO
     * 
     * SECURITY: V-005 (anti-replay), V-006 (idempotency lock), V-008 (amount check)
     */
    public function handleWebhook(array $payload, string $signature): bool
    {
        // SÉCURITÉ V-004: Valider la signature HMAC
        if (!$this->validateWebhookSignature($payload, $signature)) {
            return false;
        }

        // SÉCURITÉ V-005: Protection anti-replay via timestamp
        if (!$this->validateWebhookTimestamp($payload)) {
            return false;
        }

        $reference = $payload['reference'] ?? null;
        $jekoId = $payload['id'] ?? null;

        if (!$reference && !$jekoId) {
            Log::warning('JEKO Webhook: Référence manquante', [
                'payload_keys' => array_keys($payload),
            ]);
            return false;
        }

        // Trouver le paiement
        $payment = JekoPayment::byReference($reference)->first()
            ?? JekoPayment::byJekoId($jekoId)->first();

        if (!$payment) {
            Log::warning('JEKO Webhook: Paiement non trouvé', [
                'reference' => $reference,
                'jeko_id' => $jekoId,
            ]);
            return false;
        }

        // SÉCURITÉ V-006: Lock atomique pour éviter race condition
        $lockKey = "jeko_webhook_{$payment->id}";
        
        return \Illuminate\Support\Facades\Cache::lock($lockKey, 30)->block(5, function () use ($payment, $payload) {
            // Recharger le paiement pour avoir l'état le plus récent
            $payment = $payment->fresh();
            
            // Idempotency: ne pas traiter deux fois
            if ($payment->webhook_processed) {
                Log::info('JEKO Webhook: Déjà traité (idempotent)', ['reference' => $payment->reference]);
                return true;
            }

            // SÉCURITÉ V-008: Vérifier cohérence du montant
            if (!$this->validateWebhookAmount($payment, $payload)) {
                return false;
            }

            // Utiliser une transaction DB pour atomicité
            return \Illuminate\Support\Facades\DB::transaction(function () use ($payment, $payload) {
                // Mettre à jour le paiement
                $this->updatePaymentFromJekoResponse($payment, $payload);
                
                // Recharger pour avoir le nouveau statut
                $payment = $payment->fresh();

                // Si succès, exécuter la logique métier
                if ($payment->isSuccess()) {
                    $this->handleSuccessfulPayment($payment);
                }

                return true;
            });
        });
    }

    /**
     * SECURITY V-005: Valider le timestamp du webhook pour éviter replay attacks
     */
    private function validateWebhookTimestamp(array $payload): bool
    {
        $timestamp = $payload['timestamp'] ?? $payload['created_at'] ?? null;
        
        if (!$timestamp) {
            // Si JEKO n'envoie pas de timestamp, on log mais on accepte (à adapter selon leur API)
            Log::info('JEKO Webhook: Pas de timestamp dans le payload');
            return true;
        }

        // Convertir en timestamp Unix si c'est une date string
        if (is_string($timestamp) && !is_numeric($timestamp)) {
            $timestamp = strtotime($timestamp);
        }
        
        $maxAgeSeconds = 300; // 5 minutes
        $age = abs(time() - (int)$timestamp);
        
        if ($age > $maxAgeSeconds) {
            Log::warning('JEKO Webhook: Timestamp expiré (possible replay attack)', [
                'webhook_timestamp' => $timestamp,
                'current_timestamp' => time(),
                'age_seconds' => $age,
                'max_age_seconds' => $maxAgeSeconds,
            ]);
            return false;
        }

        return true;
    }

    /**
     * SECURITY V-008: Vérifier que le montant du webhook correspond au montant attendu
     */
    private function validateWebhookAmount(JekoPayment $payment, array $payload): bool
    {
        $receivedAmountCents = $payload['amountCents'] ?? $payload['amount_cents'] ?? null;
        
        if ($receivedAmountCents === null) {
            // Si pas de montant dans le webhook, on accepte (vérification via API si nécessaire)
            return true;
        }

        $receivedAmountCents = (int) $receivedAmountCents;
        
        if ($receivedAmountCents !== $payment->amount_cents) {
            Log::critical('JEKO Webhook: INCOHÉRENCE MONTANT - FRAUDE POTENTIELLE', [
                'reference' => $payment->reference,
                'expected_amount_cents' => $payment->amount_cents,
                'received_amount_cents' => $receivedAmountCents,
                'difference' => $receivedAmountCents - $payment->amount_cents,
            ]);
            
            // Marquer le paiement comme suspect
            $payment->update([
                'status' => JekoPaymentStatus::FAILED,
                'error_message' => 'Montant incohérent détecté - paiement bloqué',
                'webhook_processed' => true,
            ]);
            
            return false;
        }

        return true;
    }

    /**
     * Valider la signature HMAC du webhook
     * 
     * SECURITY: V-004 - TOUJOURS valider la signature, jamais de bypass
     */
    public function validateWebhookSignature(array $payload, string $signature): bool
    {
        // SÉCURITÉ CRITIQUE: Ne JAMAIS accepter sans secret configuré
        if (empty($this->webhookSecret)) {
            Log::critical('JEKO_WEBHOOK_SECRET non configuré - TOUTES les requêtes webhook sont REJETÉES', [
                'environment' => app()->environment(),
            ]);
            return false;
        }

        // SÉCURITÉ: Rejeter si signature manquante
        if (empty($signature)) {
            Log::warning('JEKO Webhook: Signature manquante dans la requête');
            return false;
        }

        // Calculer la signature attendue
        $computedSignature = hash_hmac('sha256', json_encode($payload), $this->webhookSecret);
        
        // Comparaison timing-safe pour éviter timing attacks
        $isValid = hash_equals($computedSignature, $signature);
        
        if (!$isValid) {
            Log::warning('JEKO Webhook: Signature invalide', [
                'received_signature_prefix' => substr($signature, 0, 10) . '...',
            ]);
        }
        
        return $isValid;
    }

    /**
     * Mettre à jour un paiement depuis la réponse JEKO
     */
    private function updatePaymentFromJekoResponse(JekoPayment $payment, array $data): JekoPayment
    {
        $jekoStatus = $data['status'] ?? 'pending';

        $status = match ($jekoStatus) {
            'success' => JekoPaymentStatus::SUCCESS,
            'failed', 'error', 'cancelled' => JekoPaymentStatus::FAILED,
            'expired' => JekoPaymentStatus::EXPIRED,
            default => JekoPaymentStatus::PROCESSING,
        };

        $updateData = [
            'status' => $status,
            'webhook_received_at' => now(),
        ];

        if (isset($data['transaction'])) {
            $updateData['transaction_data'] = $data['transaction'];
        }

        if ($status->isFinal()) {
            $updateData['completed_at'] = now();
            $updateData['webhook_processed'] = true;
        }

        if ($status === JekoPaymentStatus::FAILED && isset($data['error'])) {
            $updateData['error_message'] = $data['error']['message'] ?? 'Paiement échoué';
        }

        $payment->update($updateData);

        Log::info('JEKO Payment Updated', [
            'reference' => $payment->reference,
            'old_status' => $payment->getOriginal('status'),
            'new_status' => $status->value,
        ]);

        return $payment->fresh();
    }

    /**
     * Exécuter la logique métier après un paiement réussi
     */
    private function handleSuccessfulPayment(JekoPayment $payment): void
    {
        $payable = $payment->payable;

        if (!$payable) {
            Log::warning('JEKO Payment Success - No Payable', ['reference' => $payment->reference]);
            return;
        }

        // Dispatch un event pour permettre aux listeners de réagir
        // event(new PaymentSucceeded($payment));

        // Logique spécifique selon le type de payable
        $payableClass = get_class($payable);

        switch ($payableClass) {
            case \App\Models\Order::class:
                $this->handleOrderPayment($payable, $payment);
                break;
            
            case \App\Models\Wallet::class:
                $this->handleWalletTopup($payable, $payment);
                break;
            
            default:
                Log::info('JEKO Payment Success - Unknown Payable Type', [
                    'reference' => $payment->reference,
                    'type' => $payableClass,
                ]);
        }
    }

    /**
     * Traiter le paiement d'une commande
     */
    private function handleOrderPayment($order, JekoPayment $payment): void
    {
        if (method_exists($order, 'markAsPaid')) {
            $order->markAsPaid($payment->reference);
        } else {
            $order->update([
                'payment_status' => 'paid',
                'payment_reference' => $payment->reference,
                'paid_at' => now(),
            ]);
        }

        Log::info('Order Marked as Paid', [
            'order_id' => $order->id,
            'payment_reference' => $payment->reference,
        ]);

        // === NOTIFIER LA PHARMACIE DE LA NOUVELLE COMMANDE PAYÉE ===
        $order->load(['items', 'customer', 'pharmacy.user']);
        
        if ($order->pharmacy?->user) {
            $order->pharmacy->user->notify(new NewOrderReceivedNotification($order));
            
            Log::info('Notification nouvelle commande payée envoyée à la pharmacie', [
                'order_id' => $order->id,
                'order_reference' => $order->reference ?? $order->id,
                'pharmacy_id' => $order->pharmacy_id,
                'pharmacy_user_id' => $order->pharmacy->user->id,
            ]);
        }
    }

    /**
     * Traiter le rechargement d'un wallet
     */
    private function handleWalletTopup($wallet, JekoPayment $payment): void
    {
        // Créditer le wallet
        $walletService = app(\App\Services\WalletService::class);
        
        $walletService->topUp(
            $wallet->walletable,
            $payment->amount,
            $payment->payment_method->value,
            $payment->reference
        );

        Log::info('Wallet Topped Up', [
            'wallet_id' => $wallet->id,
            'amount' => $payment->amount,
            'payment_reference' => $payment->reference,
        ]);
    }

    /**
     * Obtenir les méthodes de paiement disponibles
     */
    public function getAvailableMethods(): array
    {
        return collect(JekoPaymentMethod::cases())->map(fn($method) => [
            'value' => $method->value,
            'label' => $method->label(),
            'icon' => $method->icon(),
        ])->toArray();
    }

    /**
     * Vérifier si on est en mode sandbox (clés JEKO non configurées)
     */
    private function isSandboxMode(): bool
    {
        // En mode sandbox si les clés contiennent "your_" ou sont vides
        $placeholders = ['your_', 'xxx', 'test', 'placeholder'];
        
        foreach ($placeholders as $placeholder) {
            if (str_contains(strtolower($this->apiKey), $placeholder) ||
                str_contains(strtolower($this->storeId), $placeholder)) {
                return true;
            }
        }
        
        return empty($this->apiKey) || empty($this->storeId);
    }

    /**
     * Gérer un paiement en mode sandbox (développement)
     * Simule un paiement réussi et crédite directement le wallet
     */
    private function handleSandboxPayment(JekoPayment $payment, Model $payable): JekoPayment
    {
        Log::info('JEKO SANDBOX MODE: Simulation de paiement', [
            'reference' => $payment->reference,
            'amount' => $payment->amount,
            'payable_type' => get_class($payable),
        ]);

        // Simuler un ID JEKO
        $fakeJekoId = 'SANDBOX-' . uniqid();
        
        // URL de redirection fictive qui redirige vers success callback
        $sandboxRedirectUrl = config('app.url') . '/api/payments/sandbox/confirm?reference=' . $payment->reference;

        // Mettre à jour le paiement
        $payment->update([
            'jeko_payment_request_id' => $fakeJekoId,
            'redirect_url' => $sandboxRedirectUrl,
            'status' => JekoPaymentStatus::PROCESSING,
        ]);

        return $payment->fresh();
    }

    /**
     * Confirmer un paiement sandbox (appelé depuis l'écran de confirmation)
     */
    public function confirmSandboxPayment(string $reference): JekoPayment
    {
        $payment = JekoPayment::byReference($reference)->first();
        
        if (!$payment) {
            throw new \Exception('Paiement non trouvé');
        }

        if ($payment->isFinal()) {
            return $payment;
        }

        // Marquer comme succès
        $payment->update([
            'status' => JekoPaymentStatus::SUCCESS,
            'completed_at' => now(),
            'webhook_processed' => true,
            'webhook_received_at' => now(),
        ]);

        // Exécuter la logique métier (crédit wallet, etc.)
        $this->handleSuccessfulPayment($payment);

        Log::info('JEKO SANDBOX: Paiement confirmé', [
            'reference' => $payment->reference,
            'amount' => $payment->amount,
        ]);

        return $payment->fresh();
    }
}
