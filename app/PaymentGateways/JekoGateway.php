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
    protected string $merchantId;
    protected string $secretKey;
    protected string $baseUrl;
    protected string $notifyUrl;
    protected string $returnUrl;

    public function __construct()
    {
        $this->apiKey = config('services.jeko.api_key');
        $this->merchantId = config('services.jeko.merchant_id');
        $this->secretKey = config('services.jeko.secret_key');
        $this->baseUrl = config('services.jeko.base_url', 'https://api.jeko.ci/v1');
        $this->notifyUrl = route('webhooks.jeko');
        $this->returnUrl = config('services.jeko.return_url');
    }

    public function initiate(Order $order, array $customerData): PaymentIntent
    {
        $reference = 'ORDER-' . $order->reference . '-' . time();

        $payload = [
            'merchant_id' => $this->merchantId,
            'reference' => $reference,
            'amount' => (int) $order->total_amount,
            'currency' => 'XOF',
            'description' => "Commande {$order->reference} - DR-PHARMA",
            'customer' => [
                'name' => $customerData['name'] ?? 'Client DR-PHARMA',
                'email' => $customerData['email'] ?? 'client@drpharma.com',
                'phone' => $customerData['phone'] ?? '',
            ],
            'callback_url' => $this->notifyUrl,
            'return_url' => $this->returnUrl,
            'metadata' => [
                'order_id' => $order->id,
                'order_reference' => $order->reference,
            ],
        ];

        try {
            /** @var \Illuminate\Http\Client\Response $response */
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/payments/initialize", $payload);

            $data = $response->json();

            Log::info('Jeko initiate response', ['data' => $data]);

            if ($response->successful() && isset($data['status']) && $data['status'] === 'success') {
                return PaymentIntent::create([
                    'order_id' => $order->id,
                    'provider' => 'jeko',
                    'reference' => $reference,
                    'provider_reference' => $data['data']['payment_id'] ?? null,
                    'amount' => $order->total_amount,
                    'status' => 'PENDING',
                    'provider_payment_url' => $data['data']['payment_url'] ?? null,
                    'raw_response' => $data,
                ]);
            }

            throw new \Exception($data['message'] ?? 'Jeko payment initiation failed');
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
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->get("{$this->baseUrl}/payments/{$paymentIntent->provider_reference}");

            $data = $response->json();

            Log::info('Jeko verify response', ['data' => $data]);

            if ($response->successful() && isset($data['status']) && $data['status'] === 'success') {
                $paymentData = $data['data'];
                $status = $this->mapStatus($paymentData['status'] ?? '');

                return [
                    'status' => $status,
                    'data' => $paymentData,
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
        if (!$signature) {
            return false;
        }

        // Jeko utilise HMAC-SHA256 pour signer les webhooks
        $data = json_encode($payload, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
        $expectedSignature = hash_hmac('sha256', $data, $this->secretKey);

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
}
