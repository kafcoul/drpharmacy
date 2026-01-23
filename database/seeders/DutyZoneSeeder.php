<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\DutyZone;

class DutyZoneSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $zones = [
            // Abidjan Nord
            ['name' => 'Abobo', 'city' => 'Abidjan', 'description' => 'Secteur Abidjan Nord'],
            ['name' => 'Anyama', 'city' => 'Abidjan', 'description' => 'Secteur Abidjan Nord'],
            ['name' => 'Yopougon', 'city' => 'Abidjan', 'description' => 'Secteur Abidjan Ouest'],
            
            // Abidjan Sud
            ['name' => 'Marcory', 'city' => 'Abidjan', 'description' => 'Secteur Abidjan Sud'],
            ['name' => 'Koumassi', 'city' => 'Abidjan', 'description' => 'Secteur Abidjan Sud'],
            ['name' => 'Port-Bouët', 'city' => 'Abidjan', 'description' => 'Secteur Abidjan Sud'],
            ['name' => 'Treichville', 'city' => 'Abidjan', 'description' => 'Secteur Abidjan Sud'],

            // Abidjan Centre/Est
            ['name' => 'Cocody', 'city' => 'Abidjan', 'description' => 'Secteur Abidjan Est'],
            ['name' => 'Plateau', 'city' => 'Abidjan', 'description' => 'Secteur Abidjan Centre'],
            ['name' => 'Adjamé', 'city' => 'Abidjan', 'description' => 'Secteur Abidjan Centre'],
            ['name' => 'Bingerville', 'city' => 'Abidjan', 'description' => 'Secteur Abidjan Est'],

            // Intérieur
            ['name' => 'Yamoussoukro Centre', 'city' => 'Yamoussoukro', 'description' => 'Capitale Politique'],
            ['name' => 'Bouaké Centre', 'city' => 'Bouaké', 'description' => 'Région de Gbêkê'],
            ['name' => 'San-Pédro', 'city' => 'San-Pédro', 'description' => 'Zone Portuaire'],
            ['name' => 'Daloa', 'city' => 'Daloa', 'description' => 'Haut-Sassandra'],
            ['name' => 'Korhogo', 'city' => 'Korhogo', 'description' => 'Région du Poro'],
        ];

        foreach ($zones as $zone) {
            DutyZone::firstOrCreate(
                ['name' => $zone['name']],
                $zone
            );
        }
    }
}
