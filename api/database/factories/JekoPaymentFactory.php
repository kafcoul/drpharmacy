<?php

namespace Database\Factories;

use App\Models\JekoPayment;
use App\Models\Order;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

class JekoPaymentFactory extends Factory
{
    protected $model = JekoPayment::class;

    public function definition(): array
    {
        return [
            'uuid' => Str::uuid(),
            'reference' => 'JEKO-' . strtoupper(Str::random(10)),
            'jeko_payment_request_id' => Str::random(20),
            'payable_type' => 'App\Models\Order',
            'payable_id' => Order::factory(),
            'user_id' => User::factory(),
            'amount_cents' => fake()->numberBetween(100000, 5000000), // 1000 - 50000 XOF
            'currency' => 'XOF',
            'payment_method' => fake()->randomElement(['wave', 'orange', 'mtn', 'moov']),
            'status' => 'pending',
            'initiated_at' => now(),
            'is_payout' => false,
        ];
    }

    public function pending(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'pending',
        ]);
    }

    public function processing(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'processing',
        ]);
    }

    public function success(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'success',
            'completed_at' => now(),
            'webhook_processed' => true,
        ]);
    }

    public function failed(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'failed',
            'error_message' => 'Transaction échouée',
        ]);
    }

    public function expired(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'expired',
            'initiated_at' => now()->subMinutes(30),
        ]);
    }

    public function payout(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_payout' => true,
            'recipient_phone' => fake()->numerify('+225##########'),
            'description' => 'Retrait wallet',
        ]);
    }
}
