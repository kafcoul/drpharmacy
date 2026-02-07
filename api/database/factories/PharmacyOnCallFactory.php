<?php

namespace Database\Factories;

use App\Models\PharmacyOnCall;
use App\Models\Pharmacy;
use App\Models\DutyZone;
use Illuminate\Database\Eloquent\Factories\Factory;

class PharmacyOnCallFactory extends Factory
{
    protected $model = PharmacyOnCall::class;

    public function definition(): array
    {
        $startDate = fake()->dateTimeBetween('now', '+1 week');
        $endDate = fake()->dateTimeBetween($startDate, '+2 weeks');

        return [
            'pharmacy_id' => Pharmacy::factory(),
            'duty_zone_id' => DutyZone::factory(),
            'start_date' => $startDate,
            'end_date' => $endDate,
            'is_active' => true,
            'notes' => fake()->optional()->sentence(),
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

    public function past(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => false,
            'start_date' => now()->subMonth(),
            'end_date' => now()->subWeek(),
        ]);
    }

    public function future(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => true,
            'start_date' => now()->addWeek(),
            'end_date' => now()->addMonth(),
        ]);
    }
}
