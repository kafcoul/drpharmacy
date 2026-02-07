<?php

namespace Database\Factories;

use App\Models\Prescription;
use App\Models\User;
use App\Models\Order;
use Illuminate\Database\Eloquent\Factories\Factory;

class PrescriptionFactory extends Factory
{
    protected $model = Prescription::class;

    public function definition(): array
    {
        return [
            'customer_id' => User::factory()->customer(),
            'images' => json_encode([fake()->imageUrl()]),
            'notes' => fake()->optional()->sentence(),
            'status' => 'pending',
            'source' => 'upload',
        ];
    }

    public function pending(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'pending',
        ]);
    }

    public function validated(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'validated',
            'validated_at' => now(),
            'validated_by' => User::factory()->admin(),
        ]);
    }

    public function quoted(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'quoted',
            'quote_amount' => fake()->randomFloat(2, 5000, 50000),
        ]);
    }

    public function rejected(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'rejected',
            'admin_notes' => 'Ordonnance illisible',
        ]);
    }

    public function fromCheckout(): static
    {
        return $this->state(fn (array $attributes) => [
            'source' => 'checkout',
            'order_id' => Order::factory(),
        ]);
    }
}
