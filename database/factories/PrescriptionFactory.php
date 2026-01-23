<?php

namespace Database\Factories;

use App\Models\Prescription;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Prescription>
 */
class PrescriptionFactory extends Factory
{
    /**
     * The name of the factory's corresponding model.
     */
    protected $model = Prescription::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'customer_id' => User::factory(),
            'images' => json_encode(['prescriptions/' . $this->faker->uuid . '.jpg']),
            'notes' => $this->faker->optional()->sentence(),
            'status' => 'pending',
            'admin_notes' => null,
            'validated_at' => null,
            'validated_by' => null,
        ];
    }

    /**
     * Indicate that the prescription is pending.
     */
    public function pending(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'pending',
            'validated_at' => null,
            'validated_by' => null,
        ]);
    }

    /**
     * Indicate that the prescription is validated.
     */
    public function validated(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'validated',
            'validated_at' => now(),
            'validated_by' => User::factory()->create(['role' => 'admin'])->id,
        ]);
    }

    /**
     * Indicate that the prescription is rejected.
     */
    public function rejected(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'rejected',
            'admin_notes' => 'Ordonnance illisible ou incomplète',
            'validated_at' => now(),
            'validated_by' => User::factory()->create(['role' => 'admin'])->id,
        ]);
    }
}
