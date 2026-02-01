<?php

namespace App\PaymentGateways;

use App\Models\Order;
use App\Models\Payment;
use App\Models\PaymentIntent;
use App\PaymentGateways\Contracts\PaymentGatewayInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class JekoGateway implements PaymentGatewayInterface
{
    protected string $apiKey;
    protected string $apiKeyId;
    protected string $storeId;
    protected string $baseUrl;
    protected string $notifyUrl;
    protected ?string $returnUrl;
    protected ?string $webhookSecret;

    public function __construct()
    {
        $this->apiKey = config('services.jeko.api_key') ?? '';
        $this->apiKeyId = config('services.jeko.api_key_id') ?? '';
        $this->storeId = config('services.jeko.store_id') ?? '';
        $this->baseUrl = config('services.jeko.api_url', 'https://api.jeko.africa');
        $this->notifyUrl = route('webhooks.jeko');
        $this->returnUrl = config('services.jeko.return_url');
        $this->webhookSecret = config('services.jeko.webhook_secret');
    }

    public function initiate(Order $order, array $customerData): PaymentIntent
    {
        // Vérifier que les credentials sont configurés
        if (empty($this->apiKey) || empty($this->storeId)) {
            throw new \Exception('Jeko payment gateway is not properly configured. Please set JEKO_API_KEY and JEKO_STORE_ID in .env');
        }

        $reference = 'ORDER-' . $order->reference . '-' . time();
        
        // MODE SANDBOX: En développement local, simuler le paiement
        if ($this->isSandboxMode()) {
            return $this->handleSandboxPayment($order, $reference);
        }
        
        // URLs de callback (inclure la référence pour identifier le paiement)
        $baseSuccessUrl = config('services.jeko.return_url') ?? url('/api/payments/callback/success');
        $baseErrorUrl = config('services.jeko.error_url') ?? url('/api/payments/callback/error');
        
        $successUrl = $baseSuccessUrl . '?reference=' . urlencode($reference) . '&order_id=' . $order->id;
        $errorUrl = $baseErrorUrl . '?reference=' . urlencode($reference) . '&order_id=' . $order->id;

        // Montant en centimes (JEKO attend des centimes, minimum 100)
        $amountCents = max(100, (int) ($order->total_amount * 100));
        
        // Méthode de paiement par défaut (peut être passé dans customerData)
        $paymentMethod = $customerData['payment_method'] ?? 'wave';

        $payload = [
            'storeId' => $this->storeId,
            'amountCents' => $amountCents,
            'currency' => 'XOF',
            'reference' => $reference,
            'paymentDetails' => [
                'type' => 'redirect',
                'data' => [
                    'paymentMethod' => $paymentMethod, // wave, orange, mtn, moov, djamo
                    'successUrl' => $successUrl,
                    'errorUrl' => $errorUrl,
                ],
            ],
        ];

        try {
            /** @var \Illuminate\Http\Client\Response $response */
            $response = Http::withHeaders([
                'X-API-KEY' => $this->apiKey,
                'X-API-KEY-ID' => $this->apiKeyId,
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/partner_api/payment_requests", $payload);

            $data = $response->json();

            Log::info('Jeko initiate response', ['data' => $data, 'payload' => $payload]);

            // Jeko retourne directement l'objet avec id et redirectUrl si succès
            if ($response->successful() && isset($data['id'])) {
                return PaymentIntent::create([
                    'order_id' => $order->id,
                    'provider' => 'jeko',
                    'reference' => $reference,
                    'provider_reference' => $data['id'],
                    'amount' => $order->total_amount,
                    'status' => 'PENDING',
                    'provider_payment_url' => $data['redirectUrl'] ?? null,
                    'raw_response' => $data,
                ]);
            }

            throw new \Exception($data['message'] ?? $data['error'] ?? 'Jeko payment initiation failed');
        } catch (\Exception $e) {
            Log::error('Jeko initiate error', [
                'order_id' => $order->id,
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }

    public function verify(PaymentIntent $paymentIntent): array
    {
        try {
            /** @var \Illuminate\Http\Client\Response $response */
            $response = Http::withHeaders([
                'X-API-KEY' => $this->apiKey,
                'X-API-KEY-ID' => $this->apiKeyId,
                'Content-Type' => 'application/json',
            ])->get("{$this->baseUrl}/partner_api/payment_requests/{$paymentIntent->provider_reference}");

            $data = $response->json();

            Log::info('Jeko verify response', ['data' => $data]);

            if ($response->successful() && isset($data['status'])) {
                $status = $this->mapStatus($data['status'] ?? '');

                return [
                    'status' => $status,
                    'data' => $data,
                ];
            }

            return [
                'status' => 'FAILED',
                'data' => $data,
            ];
        } catch (\Exception $e) {
            Log::error('Jeko verify error', [
                'payment_intent_id' => $paymentIntent->id,
                'error' => $e->getMessage(),
            ]);

            return [
                'status' => 'FAILED',
                'data' => ['error' => $e->getMessage()],
            ];
        }
    }

    public function handleWebhook(array $payload): ?PaymentIntent
    {
        Log::info('Jeko webhook received', ['payload' => $payload]);

        // According to official Jeko docs, reference is in apiTransactionableDetails
        $apiDetails = $payload['apiTransactionableDetails'] ?? [];
        $reference = $apiDetails['reference'] ?? $payload['reference'] ?? null;

        if (!$reference) {
            Log::warning('Jeko webhook missing reference (apiTransactionableDetails.reference)');
            return null;
        }

        $paymentIntent = PaymentIntent::where('reference', $reference)
            ->where('provider', 'jeko')
            ->first();

        if (!$paymentIntent) {
            Log::warning('Jeko webhook: PaymentIntent not found', ['reference' => $reference]);
            return null;
        }

        // Éviter les webhooks dupliqués
        if ($paymentIntent->status === 'SUCCESS') {
            Log::info('Jeko webhook: Payment already processed', ['payment_intent_id' => $paymentIntent->id]);
            return $paymentIntent;
        }

        // According to Jeko docs, status can be: 'pending', 'success', 'error'
        $paymentStatus = strtolower($payload['status'] ?? '');
        $status = $this->mapStatus($paymentStatus);

        $paymentIntent->update([
            'status' => $status,
            'raw_webhook' => $payload,
            'confirmed_at' => $status === 'SUCCESS' ? now() : null,
        ]);

        // Si succès, créer le Payment record
        if ($status === 'SUCCESS') {
            $payment = Payment::firstOrCreate(
                ['payment_intent_id' => $paymentIntent->id],
                [
                    'order_id' => $paymentIntent->order_id,
                    'provider' => 'jeko',
                    'provider_reference' => $apiDetails['id'] ?? $payload['id'] ?? null,
                    'amount' => $paymentIntent->amount,
                    'currency' => 'XOF',
                    'status' => 'COMPLETED',
                    'payment_method' => $payload['paymentMethod'] ?? 'MOBILE_MONEY', // Jeko uses camelCase
                    'raw_response' => $payload,
                    'paid_at' => now(),
                ]
            );

            // Mettre à jour le statut de la commande
            $paymentIntent->order->update([
                'status' => 'confirmed',
                'paid_at' => now(),
            ]);

            // Dispatch event pour calculer les commissions
            event(new \App\Events\PaymentConfirmed($payment));

            Log::info('Jeko payment completed', ['order_id' => $paymentIntent->order_id]);
        }

        return $paymentIntent;
    }

    public function verifySignature(array $payload, ?string $signature): bool
    {
        if (!$signature || !$this->webhookSecret) {
            return false;
        }

        // Jeko utilise HMAC-SHA256 pour signer les webhooks
        $data = json_encode($payload, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
        $expectedSignature = hash_hmac('sha256', $data, $this->webhookSecret);

        return hash_equals($expectedSignature, $signature);
    }

    public function getProviderName(): string
    {
        return 'jeko';
    }

    /**
     * Mapper les statuts Jeko vers nos statuts internes
     * 
     * According to official Jeko documentation, status can be:
     * - 'pending': Payment is being processed
     * - 'success': Payment completed successfully
     * - 'error': Payment failed
     */
    protected function mapStatus(string $jekoStatus): string
    {
        return match (strtolower($jekoStatus)) {
            'success' => 'SUCCESS',
            'error', 'failed', 'declined', 'rejected' => 'FAILED', // 'error' is official
            'cancelled', 'canceled' => 'CANCELLED',
            'pending', 'processing' => 'PENDING',
            default => 'PENDING',
        };
    }

    /**
     * Vérifier si on est en mode sandbox (développement local)
     * Le mode sandbox est activé quand APP_ENV=local ou APP_DEBUG=true
     * et qu'aucune URL de retour HTTPS n'est configurée
     */
    protected function isSandboxMode(): bool
    {
        $appEnv = config('app.env', 'production');
        $returnUrl = config('services.jeko.return_url');
        
        // Mode sandbox si on est en local et pas d'URL HTTPS configurée
        return $appEnv === 'local' && (empty($returnUrl) || !str_starts_with($returnUrl, 'https://'));
    }

    /**
     * Gérer le paiement en mode sandbox
     * Crée un PaymentIntent avec une URL de confirmation sandbox
     */
    protected function handleSandboxPayment(Order $order, string $reference): PaymentIntent
    {
        $sandboxId = 'sandbox_' . uniqid();
        
        // URL sandbox pour confirmer le paiement manuellement
        $sandboxUrl = url("/api/payments/sandbox/confirm?reference={$reference}&order_id={$order->id}");
        
        Log::info('Jeko SANDBOX mode - payment simulated', [
            'order_id' => $order->id,
            'reference' => $reference,
            'sandbox_url' => $sandboxUrl,
        ]);

        return PaymentIntent::create([
            'order_id' => $order->id,
            'provider' => 'jeko',
            'reference' => $reference,
            'provider_reference' => $sandboxId,
            'amount' => $order->total_amount,
            'status' => 'PENDING',
            'provider_payment_url' => $sandboxUrl,
            'raw_response' => [
                'sandbox' => true,
                'message' => 'Mode sandbox - Cliquez sur le lien pour simuler le paiement',
            ],
        ]);
    }
}
