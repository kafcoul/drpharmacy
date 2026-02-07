<?php

namespace Database\Factories;

use App\Models\WithdrawalRequest;
use App\Models\Wallet;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class WithdrawalRequestFactory extends Factory
{
    protected $model = WithdrawalRequest::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'wallet_id' => Wallet::factory(),
            'amount' => fake()->randomFloat(2, 1000, 50000),
            'payment_method' => fake()->randomElement(['mobile_money', 'bank_transfer']),
            'payment_details' => json_encode([
                'phone' => fake()->phoneNumber(),
                'provider' => fake()->randomElement(['Orange Money', 'MTN Mobile Money', 'Wave']),
            ]),
            'status' => fake()->randomElement(['pending', 'processing', 'completed', 'rejected']),
            'processed_at' => null,
            'processed_by' => null,
            'rejection_reason' => null,
            'reference' => 'WDR-' . fake()->unique()->randomNumber(8),
        ];
    }

    public function pending(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'pending',
            'processed_at' => null,
        ]);
    }

    public function processing(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'processing',
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
            'processed_at' => now(),
            'rejection_reason' => 'Solde insuffisant',
        ]);
    }

    public function mobileMoney(): static
    {
        return $this->state(fn (array $attributes) => [
            'payment_method' => 'mobile_money',
            'payment_details' => json_encode([
                'phone' => fake()->phoneNumber(),
                'provider' => fake()->randomElement(['Orange Money', 'MTN Mobile Money', 'Wave']),
            ]),
        ]);
    }

    public function bankTransfer(): static
    {
        return $this->state(fn (array $attributes) => [
            'payment_method' => 'bank_transfer',
            'payment_details' => json_encode([
                'bank_name' => 'SGBCI',
                'account_number' => fake()->bankAccountNumber(),
                'account_name' => fake()->name(),
            ]),
        ]);
    }
}
