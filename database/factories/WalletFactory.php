<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Wallet>
 */
class WalletFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'walletable_type' => \App\Models\User::class,
            'walletable_id' => \App\Models\User::factory(),
            'balance' => 0,
            'currency' => 'XOF',
        ];
    }
}
