<?php

namespace Database\Factories;

use App\Models\Product;
use App\Models\Pharmacy;
use App\Models\Category;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

class ProductFactory extends Factory
{
    protected $model = Product::class;

    public function definition(): array
    {
        $name = fake()->randomElement([
            'Paracetamol 500mg', 'Doliprane 1000mg', 'Ibuprofène 400mg',
            'Amoxicilline 500mg', 'Vitamine C 1000mg', 'Aspirine 500mg',
            'Oméprazole 20mg', 'Metformine 500mg', 'Losartan 50mg',
            'Atorvastatine 10mg', 'Ciprofloxacine 500mg', 'Azithromycine 250mg',
        ]);

        return [
            'pharmacy_id' => Pharmacy::factory(),
            'name' => $name,
            'slug' => Str::slug($name) . '-' . Str::random(5),
            'description' => fake()->paragraph(),
            'category' => fake()->randomElement(['Médicaments', 'Vitamines', 'Soins', 'Hygiène']),
            'brand' => fake()->company(),
            'price' => fake()->randomFloat(2, 500, 25000),
            'discount_price' => fake()->optional(0.3)->randomFloat(2, 300, 20000),
            'stock_quantity' => fake()->numberBetween(0, 500),
            'low_stock_threshold' => 10,
            'sku' => fake()->unique()->numerify('SKU-####'),
            'requires_prescription' => fake()->boolean(20),
            'is_available' => true,
            'is_featured' => fake()->boolean(10),
            'unit' => fake()->randomElement(['pièce', 'boîte', 'flacon', 'tube']),
            'units_per_pack' => fake()->randomElement([1, 10, 20, 30]),
            'manufacturer' => fake()->company(),
        ];
    }

    public function available(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_available' => true,
            'stock_quantity' => fake()->numberBetween(10, 500),
        ]);
    }

    public function unavailable(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_available' => false,
        ]);
    }

    public function outOfStock(): static
    {
        return $this->state(fn (array $attributes) => [
            'stock_quantity' => 0,
        ]);
    }

    public function featured(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_featured' => true,
        ]);
    }

    public function requiresPrescription(): static
    {
        return $this->state(fn (array $attributes) => [
            'requires_prescription' => true,
        ]);
    }

    public function withDiscount(): static
    {
        return $this->state(function (array $attributes) {
            $price = $attributes['price'] ?? 10000;
            return [
                'discount_price' => round($price * 0.8, 2),
            ];
        });
    }
}
