<?php

namespace Database\Factories;

use App\Models\Commission;
use App\Models\Order;
use App\Models\Pharmacy;
use App\Models\Courier;
use Illuminate\Database\Eloquent\Factories\Factory;

class CommissionFactory extends Factory
{
    protected $model = Commission::class;

    public function definition(): array
    {
        return [
            'order_id' => Order::factory(),
            'pharmacy_id' => Pharmacy::factory(),
            'courier_id' => Courier::factory(),
            'order_amount' => fake()->randomFloat(2, 5000, 50000),
            'delivery_fee' => fake()->randomFloat(2, 500, 2000),
            'platform_commission_rate' => 0.10,
            'pharmacy_commission_rate' => 0.05,
            'courier_commission_rate' => 0.80,
            'platform_amount' => fake()->randomFloat(2, 500, 5000),
            'pharmacy_amount' => fake()->randomFloat(2, 250, 2500),
            'courier_amount' => fake()->randomFloat(2, 400, 1600),
            'status' => fake()->randomElement(['pending', 'calculated', 'distributed', 'paid']),
            'calculated_at' => now(),
            'distributed_at' => null,
        ];
    }

    public function pending(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'pending',
            'distributed_at' => null,
        ]);
    }

    public function calculated(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'calculated',
            'calculated_at' => now(),
        ]);
    }

    public function distributed(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'distributed',
            'distributed_at' => now(),
        ]);
    }

    public function paid(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'paid',
            'distributed_at' => now()->subDay(),
        ]);
    }
}
