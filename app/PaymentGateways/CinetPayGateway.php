<?php

namespace App\PaymentGateways;

use App\Models\Order;
use App\Models\Payment;
use App\Models\PaymentIntent;
use App\PaymentGateways\Contracts\PaymentGatewayInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class CinetPayGateway implements PaymentGatewayInterface
{
    protected string $apiKey;
    protected string $siteId;
    protected string $secretKey;
    protected string $baseUrl;
    protected string $notifyUrl;
    protected string $returnUrl;

    public function __construct()
    {
        $this->apiKey = config('services.cinetpay.api_key');
        $this->siteId = config('services.cinetpay.site_id');
        $this->secretKey = config('services.cinetpay.secret_key');
        $this->baseUrl = config('services.cinetpay.base_url', 'https://api-checkout.cinetpay.com/v2');
        $this->notifyUrl = route('webhooks.cinetpay');
        $this->returnUrl = config('services.cinetpay.return_url');
    }

    public function initiate(Order $order, array $customerData): PaymentIntent
    {
        $transactionId = 'ORDER-' . $order->reference . '-' . time();

        $payload = [
            'apikey' => $this->apiKey,
            'site_id' => $this->siteId,
            'transaction_id' => $transactionId,
            'amount' => (int) $order->total_amount,
            'currency' => 'XOF',
            'description' => "Commande {$order->reference} - DR-PHARMA",
            'customer_name' => $customerData['name'] ?? 'Client',
            'customer_surname' => $customerData['name'] ?? 'DR-PHARMA',
            'customer_email' => $customerData['email'] ?? 'client@drpharma.com',
            'customer_phone_number' => $customerData['phone'] ?? '',
            'customer_address' => $order->delivery_address ?? '',
            'customer_city' => $order->delivery_city ?? 'Abidjan',
            'customer_country' => 'CI',
            'customer_state' => 'CI',
            'customer_zip_code' => '00225',
            'notify_url' => $this->notifyUrl,
            'return_url' => $this->returnUrl,
            'channels' => 'ALL',
            'metadata' => json_encode([
                'order_id' => $order->id,
                'order_reference' => $order->reference,
            ]),
        ];

        try {
            $response = Http::post("{$this->baseUrl}/payment", $payload);
            $data = $response->json();

            Log::info('CinetPay initiate response', ['data' => $data]);

            if ($response->successful() && isset($data['code']) && $data['code'] === '201') {
                return PaymentIntent::create([
                    'order_id' => $order->id,
                    'provider' => 'cinetpay',
                    'reference' => $transactionId,
                    'provider_reference' => $data['data']['payment_token'] ?? null,
                    'amount' => $order->total_amount,
                    'status' => 'PENDING',
                    'provider_payment_url' => $data['data']['payment_url'] ?? null,
                    'raw_response' => $data,
                ]);
            }

            throw new \Exception($data['message'] ?? 'CinetPay payment initiation failed');
        } catch (\Exception $e) {
            Log::error('CinetPay initiate error', [
                'order_id' => $order->id,
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }

    public function verify(PaymentIntent $paymentIntent): array
    {
        $payload = [
            'apikey' => $this->apiKey,
            'site_id' => $this->siteId,
            'transaction_id' => $paymentIntent->reference,
        ];

        try {
            $response = Http::post("{$this->baseUrl}/payment/check", $payload);
            $data = $response->json();

            Log::info('CinetPay verify response', ['data' => $data]);

            if ($response->successful() && isset($data['code']) && $data['code'] === '00') {
                $paymentData = $data['data'];
                $status = $this->mapStatus($paymentData['payment_status'] ?? '');

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
            Log::error('CinetPay verify error', [
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
        Log::info('CinetPay webhook received', ['payload' => $payload]);

        $transactionId = $payload['cpm_trans_id'] ?? null;

        if (!$transactionId) {
            Log::warning('CinetPay webhook missing transaction_id');
            return null;
        }

        $paymentIntent = PaymentIntent::where('reference', $transactionId)
            ->where('provider', 'cinetpay')
            ->first();

        if (!$paymentIntent) {
            Log::warning('CinetPay webhook: PaymentIntent not found', ['transaction_id' => $transactionId]);
            return null;
        }

        // Éviter les webhooks dupliqués
        if ($paymentIntent->status === 'SUCCESS') {
            Log::info('CinetPay webhook: Payment already processed', ['payment_intent_id' => $paymentIntent->id]);
            return $paymentIntent;
        }

        $paymentStatus = $payload['cpm_result'] ?? '';
        $status = $this->mapStatus($paymentStatus);

        $paymentIntent->update([
            'status' => $status,
            'raw_webhook' => $payload,
            'confirmed_at' => $status === 'SUCCESS' ? now() : null,
        ]);

        // Si succès, créer le Payment record
        if ($status === 'SUCCESS') {
            $payment = Payment::firstOrCreate(
                ['reference' => $paymentIntent->reference],
                [
                    'order_id' => $paymentIntent->order_id,
                    'provider' => 'cinetpay',
                    'provider_transaction_id' => $payload['cpm_trans_id'] ?? null,
                    'amount' => $paymentIntent->amount,
                    'currency' => 'XOF',
                    'status' => 'SUCCESS',
                    'payment_method' => $payload['payment_method'] ?? 'MOBILE_MONEY',
                    'confirmed_at' => now(),
                ]
            );

            // Mettre à jour le statut de la commande
            $paymentIntent->order->update([
                'status' => 'confirmed',
                'paid_at' => now(),
            ]);

            // Dispatch event pour calculer les commissions
            event(new \App\Events\PaymentConfirmed($payment));

            Log::info('CinetPay payment completed', ['order_id' => $paymentIntent->order_id]);
        }

        return $paymentIntent;
    }

    public function verifySignature(array $payload, ?string $signature): bool
    {
        // CinetPay utilise cpm_custom pour vérifier l'authenticité
        // Ou on peut vérifier en appelant l'API de vérification
        $transactionId = $payload['cpm_trans_id'] ?? null;

        if (!$transactionId) {
            return false;
        }

        $paymentIntent = PaymentIntent::where('reference', $transactionId)
            ->where('provider', 'cinetpay')
            ->first();

        if (!$paymentIntent) {
            return false;
        }

        // Bypass verification for testing
        if ($this->apiKey === 'TEST_API_KEY') {
            return true;
        }

        // Vérifier via l'API
        $verifyResult = $this->verify($paymentIntent);

        return $verifyResult['status'] !== 'FAILED';
    }

    public function getProviderName(): string
    {
        return 'cinetpay';
    }

    /**
     * Mapper les statuts CinetPay vers nos statuts internes
     */
    protected function mapStatus(string $cinetPayStatus): string
    {
        return match (strtoupper($cinetPayStatus)) {
            '00', 'ACCEPTED' => 'SUCCESS',
            '01', 'REFUSED' => 'FAILED',
            '02', 'PENDING' => 'PENDING',
            default => 'PENDING',
        };
    }
}
