<?php

namespace App\PaymentGateways\Contracts;

use App\Models\Order;
use App\Models\PaymentIntent;

interface PaymentGatewayInterface
{
    /**
     * Initialiser un paiement
     *
     * @param Order $order
     * @param array $customerData ['name' => string, 'phone' => string, 'email' => string]
     * @return PaymentIntent
     */
    public function initiate(Order $order, array $customerData): PaymentIntent;

    /**
     * Vérifier le statut d'un paiement
     *
     * @param PaymentIntent $paymentIntent
     * @return array ['status' => string, 'data' => array]
     */
    public function verify(PaymentIntent $paymentIntent): array;

    /**
     * Traiter un webhook de paiement
     *
     * @param array $payload
     * @return PaymentIntent|null
     */
    public function handleWebhook(array $payload): ?PaymentIntent;

    /**
     * Vérifier la signature du webhook
     *
     * @param array $payload
     * @param string|null $signature
     * @return bool
     */
    public function verifySignature(array $payload, ?string $signature): bool;

    /**
     * Nom du provider
     *
     * @return string
     */
    public function getProviderName(): string;
}
