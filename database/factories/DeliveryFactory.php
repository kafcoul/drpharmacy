<?php

namespace Database\Factories;

use App\Models\Courier;
use App\Models\Delivery;
use App\Models\Order;
use Illuminate\Database\Eloquent\Factories\Factory;

class DeliveryFactory extends Factory
{
    protected $model = Delivery::class;

    public function definition(): array
    {
        return [
            'order_id' => Order::factory(),
            'courier_id' => null,
            'status' => 'pending',
            'pickup_latitude' => $this->faker->latitude,
            'pickup_longitude' => $this->faker->longitude,
            'dropoff_latitude' => $this->faker->latitude,
            'dropoff_longitude' => $this->faker->longitude,
            'assigned_at' => null,
            'picked_up_at' => null,
            'delivered_at' => null,
            'delivery_notes' => $this->faker->sentence,
        ];
    }

    public function assigned()
    {
        return $this->state(function (array $attributes) {
            return [
                'courier_id' => Courier::factory(),
                'status' => 'assigned',
                'assigned_at' => now(),
            ];
        });
    }

    public function pickedUp()
    {
        return $this->state(function (array $attributes) {
            return [
                'courier_id' => Courier::factory(),
                'status' => 'picked_up',
                'assigned_at' => now()->subMinutes(30),
                'picked_up_at' => now(),
            ];
        });
    }

    public function delivered()
    {
        return $this->state(function (array $attributes) {
            return [
                'courier_id' => Courier::factory(),
                'status' => 'delivered',
                'assigned_at' => now()->subMinutes(60),
                'picked_up_at' => now()->subMinutes(30),
                'delivered_at' => now(),
            ];
        });
    }
}
