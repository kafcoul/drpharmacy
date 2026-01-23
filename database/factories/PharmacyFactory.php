<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Pharmacy>
 */
class PharmacyFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => $this->faker->company . ' Pharmacy',
            'phone' => $this->faker->phoneNumber,
            'email' => $this->faker->unique()->safeEmail,
            'address' => $this->faker->streetAddress,
            'city' => $this->faker->city,
            'region' => $this->faker->state,
            'latitude' => $this->faker->latitude,
            'longitude' => $this->faker->longitude,
            'status' => 'approved',
            'commission_rate_platform' => 10,
            'commission_rate_pharmacy' => 85,
            'commission_rate_courier' => 5,
            'license_number' => $this->faker->bothify('PHARM-##-####'),
            'owner_name' => $this->faker->name,
            'approved_at' => now(),
        ];
    }
}
