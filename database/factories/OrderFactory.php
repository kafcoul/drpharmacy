<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Order>
 */
class OrderFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'reference' => 'ORD-' . $this->faker->unique()->numberBetween(10000, 99999),
            'pharmacy_id' => \App\Models\Pharmacy::factory(),
            'customer_id' => \App\Models\User::factory(),
            'status' => 'pending',
            'payment_mode' => 'cash',
            'subtotal' => $this->faker->numberBetween(1000, 10000),
            'delivery_fee' => 1000,
            'total_amount' => function (array $attributes) {
                return $attributes['subtotal'] + $attributes['delivery_fee'];
            },
            'delivery_address' => $this->faker->address,
            'delivery_latitude' => $this->faker->latitude,
            'delivery_longitude' => $this->faker->longitude,
            'customer_phone' => $this->faker->phoneNumber,
            'delivery_code' => str_pad(mt_rand(0, 9999), 4, '0', STR_PAD_LEFT),
        ];
    }

    /**
     * Indicate that the order is confirmed.
     */
    public function confirmed(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'confirmed',
        ]);
    }

    /**
     * Indicate that the order is ready for pickup.
     */
    public function ready(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'ready',
        ]);
    }

    /**
     * Indicate that the order is assigned to a courier.
     */
    public function assigned(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'assigned',
        ]);
    }

    /**
     * Indicate that the order is in delivery.
     */
    public function inDelivery(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'in_delivery',
        ]);
    }

    /**
     * Indicate that the order is preparing.
     */
    public function preparing(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'preparing',
        ]);
    }

    /**
     * Indicate that the order is delivered.
     */
    public function delivered(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'delivered',
            'delivered_at' => now(),
        ]);
    }

    /**
     * Indicate that the order is cancelled.
     */
    public function cancelled(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'cancelled',
            'cancelled_at' => now(),
        ]);
    }
}
