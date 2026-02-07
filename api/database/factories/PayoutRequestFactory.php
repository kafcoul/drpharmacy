<?php

namespace Database\Factories;

use App\Models\PayoutRequest;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Database\Eloquent\Factories\Factory;

class PayoutRequestFactory extends Factory
{
    protected $model = PayoutRequest::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'wallet_id' => Wallet::factory(),
            'amount' => fake()->randomFloat(2, 5000, 100000),
            'payment_method' => fake()->randomElement(['mobile_money', 'bank_transfer']),
            'payment_details' => json_encode([
                'phone' => fake()->phoneNumber(),
                'provider' => 'Orange Money',
            ]),
            'status' => fake()->randomElement(['pending', 'approved', 'processing', 'completed', 'rejected']),
            'reference' => 'PAY-' . fake()->unique()->randomNumber(8),
            'processed_at' => null,
            'notes' => null,
        ];
    }

    public function pending(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'pending',
        ]);
    }

    public function approved(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'approved',
        ]);
    }

    public function completed(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'completed',
            'processed_at' => now(),
        ]);
    }

    public function rejected(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'rejected',
            'notes' => 'Demande rejetée - informations incorrectes',
        ]);
    }
}
