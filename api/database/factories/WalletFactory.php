<?php

namespace Database\Factories;

use App\Models\Wallet;
use Illuminate\Database\Eloquent\Factories\Factory;

class WalletFactory extends Factory
{
    protected $model = Wallet::class;

    public function definition(): array
    {
        return [
            'walletable_type' => 'App\Models\Courier',
            'walletable_id' => null,
            'balance' => fake()->randomFloat(2, 0, 100000),
            'currency' => 'XOF',
        ];
    }

    public function forCourier(): static
    {
        return $this->state(fn (array $attributes) => [
            'walletable_type' => 'App\Models\Courier',
        ]);
    }

    public function forPharmacy(): static
    {
        return $this->state(fn (array $attributes) => [
            'walletable_type' => 'App\Models\Pharmacy',
        ]);
    }

    public function platform(): static
    {
        return $this->state(fn (array $attributes) => [
            'walletable_type' => 'platform',
            'walletable_id' => null,
        ]);
    }

    public function withBalance(float $amount): static
    {
        return $this->state(fn (array $attributes) => [
            'balance' => $amount,
        ]);
    }

    public function empty(): static
    {
        return $this->state(fn (array $attributes) => [
            'balance' => 0,
        ]);
    }
}
