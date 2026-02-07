<?php

namespace Database\Factories;

use App\Models\CourierChallenge;
use App\Models\Courier;
use App\Models\Challenge;
use Illuminate\Database\Eloquent\Factories\Factory;

class CourierChallengeFactory extends Factory
{
    protected $model = CourierChallenge::class;

    public function definition(): array
    {
        return [
            'courier_id' => Courier::factory(),
            'challenge_id' => Challenge::factory(),
            'current_value' => fake()->numberBetween(0, 30),
            'completed_at' => null,
            'reward_claimed' => false,
        ];
    }

    public function completed(): static
    {
        return $this->state(fn (array $attributes) => [
            'current_value' => 50,
            'completed_at' => now(),
            'reward_claimed' => false,
        ]);
    }

    public function rewardClaimed(): static
    {
        return $this->state(fn (array $attributes) => [
            'current_value' => 50,
            'completed_at' => now()->subDay(),
            'reward_claimed' => true,
        ]);
    }
}
