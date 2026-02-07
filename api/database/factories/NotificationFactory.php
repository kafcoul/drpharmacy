<?php

namespace Database\Factories;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class NotificationFactory extends Factory
{
    protected $model = Notification::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'type' => fake()->randomElement(['order', 'delivery', 'payment', 'promotion', 'system']),
            'title' => fake()->randomElement([
                'Nouvelle commande',
                'Livraison en cours',
                'Paiement reçu',
                'Offre spéciale',
                'Mise à jour système'
            ]),
            'body' => fake()->sentence(),
            'data' => json_encode(['order_id' => fake()->randomNumber(5)]),
            'read_at' => null,
        ];
    }

    public function read(): static
    {
        return $this->state(fn (array $attributes) => [
            'read_at' => now(),
        ]);
    }

    public function unread(): static
    {
        return $this->state(fn (array $attributes) => [
            'read_at' => null,
        ]);
    }

    public function order(): static
    {
        return $this->state(fn (array $attributes) => [
            'type' => 'order',
            'title' => 'Nouvelle commande',
        ]);
    }

    public function delivery(): static
    {
        return $this->state(fn (array $attributes) => [
            'type' => 'delivery',
            'title' => 'Livraison en cours',
        ]);
    }
}
