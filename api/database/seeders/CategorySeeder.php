<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            [
                'name' => 'Médicaments',
                'slug' => 'medicaments',
                'description' => 'Médicaments sur ordonnance et sans ordonnance',
                'icon' => 'pill',
                'order' => 1,
            ],
            [
                'name' => 'Vitamines & Suppléments',
                'slug' => 'vitamines-supplements',
                'description' => 'Vitamines, minéraux et compléments alimentaires',
                'icon' => 'vitamin',
                'order' => 2,
            ],
            [
                'name' => 'Premiers Soins',
                'slug' => 'premiers-soins',
                'description' => 'Pansements, antiseptiques et soins d\'urgence',
                'icon' => 'first-aid',
                'order' => 3,
            ],
            [
                'name' => 'Hygiène',
                'slug' => 'hygiene',
                'description' => 'Produits d\'hygiène personnelle',
                'icon' => 'hygiene',
                'order' => 4,
            ],
            [
                'name' => 'Bébé & Maman',
                'slug' => 'bebe-maman',
                'description' => 'Produits pour bébés et mamans',
                'icon' => 'baby',
                'order' => 5,
            ],
            [
                'name' => 'Cosmétiques',
                'slug' => 'cosmetiques',
                'description' => 'Produits de beauté et soins de la peau',
                'icon' => 'cosmetics',
                'order' => 6,
            ],
            [
                'name' => 'Matériel Médical',
                'slug' => 'materiel-medical',
                'description' => 'Équipements et matériel médical',
                'icon' => 'medical-equipment',
                'order' => 7,
            ],
        ];

        foreach ($categories as $category) {
            Category::create(array_merge($category, ['is_active' => true]));
        }
    }
}
