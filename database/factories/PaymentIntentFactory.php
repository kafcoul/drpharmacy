<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\PaymentIntent>
 */
class PaymentIntentFactory extends Factory
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
            'reference' => 'PI-' . $this->faker->unique()->uuid,
            'provider_reference' => $this->faker->uuid,
            'amount' => 10000,
            'currency' => 'XOF',
            'status' => 'PENDING',
        ];
    }
}
