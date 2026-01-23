<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Courier>
 */
class CourierFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => \App\Models\User::factory(),
            'name' => $this->faker->name,
            'phone' => $this->faker->phoneNumber,
            'vehicle_type' => $this->faker->randomElement(['moto', 'bike', 'car']),
            'vehicle_number' => $this->faker->bothify('??-###-??'),
            'license_number' => $this->faker->bothify('LIC-#####'),
            'latitude' => $this->faker->latitude,
            'longitude' => $this->faker->longitude,
            'status' => 'available',
            'rating' => $this->faker->randomFloat(2, 3, 5),
            'completed_deliveries' => $this->faker->numberBetween(0, 100),
            'last_location_update' => now(),
        ];
    }
}
