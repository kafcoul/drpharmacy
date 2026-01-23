<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Payment>
 */
class PaymentFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'order_id' => \App\Models\Order::factory(),
            'provider' => 'cinetpay',
            'reference' => 'PAY-' . $this->faker->unique()->uuid,
            'provider_transaction_id' => $this->faker->uuid,
            'amount' => 10000,
            'currency' => 'XOF',
            'status' => 'SUCCESS',
            'payment_method' => 'mobile_money',
            'confirmed_at' => now(),
        ];
    }
}
