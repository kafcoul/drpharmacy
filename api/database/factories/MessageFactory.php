<?php

namespace Database\Factories;

use App\Models\Message;
use App\Models\Order;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class MessageFactory extends Factory
{
    protected $model = Message::class;

    public function definition(): array
    {
        return [
            'order_id' => Order::factory(),
            'sender_id' => User::factory(),
            'receiver_id' => User::factory(),
            'content' => fake()->sentence(),
            'type' => fake()->randomElement(['text', 'image', 'location']),
            'read_at' => null,
            'metadata' => null,
        ];
    }

    public function text(): static
    {
        return $this->state(fn (array $attributes) => [
            'type' => 'text',
            'content' => fake()->sentence(),
        ]);
    }

    public function image(): static
    {
        return $this->state(fn (array $attributes) => [
            'type' => 'image',
            'content' => 'images/messages/' . fake()->uuid() . '.jpg',
        ]);
    }

    public function location(): static
    {
        return $this->state(fn (array $attributes) => [
            'type' => 'location',
            'content' => 'Localisation partagée',
            'metadata' => json_encode([
                'latitude' => fake()->latitude(5.2, 5.5),
                'longitude' => fake()->longitude(-4.1, -3.8),
            ]),
        ]);
    }

    public function read(): static
    {
        return $this->state(fn (array $attributes) => [
            'read_at' => now(),
        ]);
    }
}
