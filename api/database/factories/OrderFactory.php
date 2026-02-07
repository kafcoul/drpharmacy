<?php

namespace Database\Factories;

use App\Models\Order;
use App\Models\Pharmacy;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

class OrderFactory extends Factory
{
    protected $model = Order::class;

    public function definition(): array
    {
        $subtotal = fake()->randomFloat(2, 1000, 50000);
        $deliveryFee = fake()->randomFloat(2, 500, 3000);
        $serviceFee = round($subtotal * 0.05, 2);

        return [
            'reference' => 'CMD-' . strtoupper(Str::random(8)),
            'pharmacy_id' => Pharmacy::factory(),
            'customer_id' => User::factory()->customer(),
            'status' => 'pending',
            'payment_mode' => 'platform',
            'subtotal' => $subtotal,
            'delivery_fee' => $deliveryFee,
            'service_fee' => $serviceFee,
            'payment_fee' => 0,
            'total_amount' => $subtotal + $deliveryFee + $serviceFee,
            'currency' => 'XOF',
            'customer_notes' => fake()->optional()->sentence(),
            'delivery_address' => fake()->address(),
            'delivery_city' => fake()->city(),
            'delivery_latitude' => fake()->latitude(5.0, 7.5),
            'delivery_longitude' => fake()->longitude(-8.0, -3.0),
            'customer_phone' => fake()->numerify('+225##########'),
            'payment_status' => 'pending',
        ];
    }

    public function pending(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'pending',
        ]);
    }

    public function confirmed(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'confirmed',
            'confirmed_at' => now(),
        ]);
    }

    public function paid(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'paid',
            'payment_status' => 'completed',
            'paid_at' => now(),
        ]);
    }

    public function delivered(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'delivered',
            'payment_status' => 'completed',
            'delivered_at' => now(),
        ]);
    }

    public function cancelled(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'cancelled',
            'cancelled_at' => now(),
            'cancellation_reason' => fake()->sentence(),
        ]);
    }

    public function cashPayment(): static
    {
        return $this->state(fn (array $attributes) => [
            'payment_mode' => 'cash',
        ]);
    }

    public function mobileMoneyPayment(): static
    {
        return $this->state(fn (array $attributes) => [
            'payment_mode' => 'mobile_money',
        ]);
    }
}
