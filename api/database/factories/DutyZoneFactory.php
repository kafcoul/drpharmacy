<?php

namespace Database\Factories;

use App\Models\DutyZone;
use Illuminate\Database\Eloquent\Factories\Factory;

class DutyZoneFactory extends Factory
{
    protected $model = DutyZone::class;

    public function definition(): array
    {
        return [
            'name' => fake()->randomElement(['Zone Nord', 'Zone Sud', 'Zone Est', 'Zone Ouest', 'Centre-ville']),
            'city' => fake()->randomElement(['Abidjan', 'Bouaké', 'Yamoussoukro']),
            'description' => fake()->sentence(),
            'is_active' => true,
            'latitude' => fake()->latitude(5.0, 7.5),
            'longitude' => fake()->longitude(-8.0, -3.0),
            'radius' => fake()->randomFloat(2, 5, 20),
        ];
    }

    public function active(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => true,
        ]);
    }

    public function inactive(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => false,
        ]);
    }
}
