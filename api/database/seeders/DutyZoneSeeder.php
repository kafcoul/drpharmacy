<?php

namespace Database\Seeders;

use App\Models\DutyZone;
use Illuminate\Database\Seeder;

class DutyZoneSeeder extends Seeder
{
    public function run(): void
    {
        $zones = [
            [
                'name' => 'Cocody',
                'city' => 'Abidjan',
                'description' => 'Zone de Cocody - Riviera, Angré, 2 Plateaux',
                'is_active' => true,
                'latitude' => 5.3599,
                'longitude' => -3.9833,
                'radius' => 10.0,
            ],
            [
                'name' => 'Plateau',
                'city' => 'Abidjan',
                'description' => 'Zone du Plateau - Centre administratif',
                'is_active' => true,
                'latitude' => 5.3167,
                'longitude' => -4.0167,
                'radius' => 5.0,
            ],
            [
                'name' => 'Yopougon',
                'city' => 'Abidjan',
                'description' => 'Zone de Yopougon',
                'is_active' => true,
                'latitude' => 5.3500,
                'longitude' => -4.0833,
                'radius' => 15.0,
            ],
            [
                'name' => 'Marcory',
                'city' => 'Abidjan',
                'description' => 'Zone de Marcory - Zone 4',
                'is_active' => true,
                'latitude' => 5.3000,
                'longitude' => -3.9833,
                'radius' => 8.0,
            ],
            [
                'name' => 'Treichville',
                'city' => 'Abidjan',
                'description' => 'Zone de Treichville',
                'is_active' => true,
                'latitude' => 5.2833,
                'longitude' => -4.0000,
                'radius' => 6.0,
            ],
        ];

        foreach ($zones as $zone) {
            DutyZone::create($zone);
        }
    }
}
