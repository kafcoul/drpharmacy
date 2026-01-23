<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Product>
 */
class ProductFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $name = $this->faker->words(3, true);
        return [
            'pharmacy_id' => \App\Models\Pharmacy::factory(),
            'name' => $name,
            'slug' => Str::slug($name),
            'description' => $this->faker->paragraph,
            'category' => $this->faker->word,
            'brand' => $this->faker->company,
            'price' => $this->faker->numberBetween(1000, 50000),
            'stock_quantity' => $this->faker->numberBetween(0, 100),
            'low_stock_threshold' => 5,
            'sku' => $this->faker->unique()->bothify('SKU-########'),
            'barcode' => $this->faker->ean13,
            'is_available' => true,
            'requires_prescription' => false,
        ];
    }
}
