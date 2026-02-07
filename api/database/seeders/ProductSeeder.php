<?php

namespace Database\Seeders;

use App\Models\Product;
use App\Models\Category;
use App\Models\Pharmacy;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $pharmacies = Pharmacy::all();
        $categories = Category::all();

        if ($pharmacies->isEmpty() || $categories->isEmpty()) {
            return;
        }

        $products = [
            ['name' => 'Paracétamol 500mg', 'price' => 1500, 'category' => 'medicaments'],
            ['name' => 'Ibuprofène 400mg', 'price' => 2500, 'category' => 'medicaments'],
            ['name' => 'Amoxicilline 500mg', 'price' => 3500, 'category' => 'medicaments'],
            ['name' => 'Vitamine C 1000mg', 'price' => 5000, 'category' => 'vitamines-supplements'],
            ['name' => 'Vitamine D3', 'price' => 7500, 'category' => 'vitamines-supplements'],
            ['name' => 'Multivitamines', 'price' => 12000, 'category' => 'vitamines-supplements'],
            ['name' => 'Pansements adhésifs', 'price' => 1000, 'category' => 'premiers-soins'],
            ['name' => 'Bétadine 125ml', 'price' => 3500, 'category' => 'premiers-soins'],
            ['name' => 'Alcool 70° 250ml', 'price' => 1500, 'category' => 'premiers-soins'],
            ['name' => 'Dentifrice Sensodyne', 'price' => 4500, 'category' => 'hygiene'],
            ['name' => 'Savon antiseptique', 'price' => 2000, 'category' => 'hygiene'],
            ['name' => 'Couches bébé (paquet)', 'price' => 8500, 'category' => 'bebe-maman'],
            ['name' => 'Lait infantile', 'price' => 15000, 'category' => 'bebe-maman'],
            ['name' => 'Crème hydratante', 'price' => 6500, 'category' => 'cosmetiques'],
            ['name' => 'Thermomètre digital', 'price' => 5000, 'category' => 'materiel-medical'],
            ['name' => 'Tensiomètre', 'price' => 25000, 'category' => 'materiel-medical'],
        ];

        foreach ($pharmacies as $pharmacy) {
            foreach ($products as $productData) {
                $category = $categories->where('slug', $productData['category'])->first();
                
                if ($category) {
                    Product::create([
                        'pharmacy_id' => $pharmacy->id,
                        'category_id' => $category->id,
                        'name' => $productData['name'],
                        'slug' => \Illuminate\Support\Str::slug($productData['name']) . '-' . $pharmacy->id,
                        'description' => 'Description de ' . $productData['name'],
                        'price' => $productData['price'],
                        'stock_quantity' => rand(10, 100),
                        'is_available' => true,
                        'requires_prescription' => str_contains($productData['name'], 'Amoxicilline'),
                    ]);
                }
            }
        }
    }
}
