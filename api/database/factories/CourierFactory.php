<?php

namespace Database\Factories;

use App\Models\Courier;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class CourierFactory extends Factory
{
    protected $model = Courier::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory()->courier(),
            'name' => fake()->name(),
            'phone' => fake()->unique()->numerify('+225##########'),
            'vehicle_type' => fake()->randomElement(['motorcycle', 'bicycle', 'car', 'scooter']),
            'vehicle_number' => fake()->bothify('??-####-??'),
            'license_number' => fake()->numerify('DL-####-####'),
            'latitude' => fake()->latitude(5.0, 7.5),
            'longitude' => fake()->longitude(-8.0, -3.0),
            'status' => 'offline',
            'rating' => fake()->randomFloat(2, 3.5, 5.0),
            'completed_deliveries' => fake()->numberBetween(0, 500),
            'kyc_status' => 'incomplete',
        ];
    }

    public function available(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'available',
            'last_location_update' => now(),
        ]);
    }

    public function busy(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'busy',
        ]);
    }

    public function offline(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'offline',
        ]);
    }

    public function suspended(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'suspended',
        ]);
    }

    public function pendingApproval(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'pending_approval',
        ]);
    }

    public function kycApproved(): static
    {
        return $this->state(fn (array $attributes) => [
            'kyc_status' => 'approved',
            'kyc_verified_at' => now(),
        ]);
    }

    public function kycPending(): static
    {
        return $this->state(fn (array $attributes) => [
            'kyc_status' => 'pending_review',
        ]);
    }
}
