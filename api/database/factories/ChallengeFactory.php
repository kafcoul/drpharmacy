<?php

namespace Database\Factories;

use App\Models\Challenge;
use Illuminate\Database\Eloquent\Factories\Factory;

class ChallengeFactory extends Factory
{
    protected $model = Challenge::class;

    public function definition(): array
    {
        $startDate = fake()->dateTimeBetween('now', '+1 week');
        $endDate = fake()->dateTimeBetween($startDate, '+1 month');

        return [
            'title' => fake()->randomElement([
                'Challenge 10 livraisons',
                'Challenge vitesse',
                'Challenge satisfaction',
                'Challenge distance'
            ]),
            'description' => fake()->paragraph(),
            'type' => fake()->randomElement(['deliveries', 'rating', 'speed', 'distance']),
            'target_value' => fake()->numberBetween(5, 50),
            'reward_type' => fake()->randomElement(['bonus', 'multiplier', 'badge']),
            'reward_value' => fake()->randomFloat(2, 500, 5000),
            'start_date' => $startDate,
            'end_date' => $endDate,
            'is_active' => true,
        ];
    }

    public function active(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => true,
            'start_date' => now()->subDay(),
            'end_date' => now()->addWeek(),
        ]);
    }

    public function completed(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => false,
            'start_date' => now()->subMonth(),
            'end_date' => now()->subWeek(),
        ]);
    }
}
