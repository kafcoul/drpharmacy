<?php

namespace Database\Seeders;

use App\Models\Pharmacy;
use Illuminate\Database\Seeder;

class PharmacySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $pharmacies = [
            [
                'name' => 'Pharmacie Centrale d\'Abidjan',
                'address' => 'Boulevard de la République, Plateau',
                'city' => 'Abidjan',
                'region' => 'Plateau',
                'phone' => '+225 27 22 00 11 22',
                'email' => 'contact@pharmaciecentrale.ci',
                'license_number' => 'PHARM-CI-2024-001',
                'owner_name' => 'Dr. Koné Adjoua',
                'latitude' => 5.3200,
                'longitude' => -4.0100,
                'status' => 'approved',
                'approved_at' => now()->subDays(rand(1, 30)),
            ],
            [
                'name' => 'Pharmacie du Plateau',
                'address' => 'Avenue Chardy, Plateau',
                'city' => 'Abidjan',
                'region' => 'Plateau',
                'phone' => '+225 27 22 00 22 33',
                'email' => 'pharmacieplateau@gmail.com',
                'license_number' => 'PHARM-CI-2024-002',
                'owner_name' => 'Dr. Yao Michel',
                'latitude' => 5.3250,
                'longitude' => -4.0150,
                'status' => 'approved',
                'approved_at' => now()->subDays(rand(1, 30)),
            ],
            [
                'name' => 'Pharmacie Cocody',
                'address' => 'Boulevard Latrille, Cocody',
                'city' => 'Abidjan',
                'region' => 'Cocody',
                'phone' => '+225 27 22 00 33 44',
                'email' => 'pharmaciecocody@yahoo.fr',
                'license_number' => 'PHARM-CI-2024-003',
                'owner_name' => 'Dr. Touré Fatoumata',
                'latitude' => 5.3599,
                'longitude' => -4.0083,
                'status' => 'approved',
                'approved_at' => now()->subDays(rand(1, 30)),
            ],
            [
                'name' => 'Pharmacie de Marcory',
                'address' => 'Zone 4, Marcory',
                'city' => 'Abidjan',
                'region' => 'Marcory',
                'phone' => '+225 27 22 00 44 55',
                'email' => 'pharmacie.marcory@hotmail.com',
                'license_number' => 'PHARM-CI-2024-004',
                'owner_name' => 'Dr. Diabaté Sékou',
                'latitude' => 5.2900,
                'longitude' => -3.9800,
                'status' => 'approved',
                'approved_at' => now()->subDays(rand(1, 30)),
            ],
            [
                'name' => 'Pharmacie Treichville',
                'address' => 'Avenue 7, Treichville',
                'city' => 'Abidjan',
                'region' => 'Treichville',
                'phone' => '+225 27 22 00 55 66',
                'email' => 'pharmacietreichville@gmail.com',
                'license_number' => 'PHARM-CI-2024-005',
                'owner_name' => 'Dr. Coulibaly Awa',
                'latitude' => 5.2833,
                'longitude' => -4.0000,
                'status' => 'approved',
                'approved_at' => now()->subDays(rand(1, 30)),
            ],
            [
                'name' => 'Pharmacie Yopougon',
                'address' => 'Rue Princesse, Yopougon',
                'city' => 'Abidjan',
                'region' => 'Yopougon',
                'phone' => '+225 27 22 00 66 77',
                'email' => 'pharmayop@gmail.com',
                'license_number' => 'PHARM-CI-2024-006',
                'owner_name' => 'Dr. Bamba Moussa',
                'latitude' => 5.3333,
                'longitude' => -4.0833,
                'status' => 'approved',
                'approved_at' => now()->subDays(rand(1, 30)),
            ],
            [
                'name' => 'Pharmacie Abobo',
                'address' => 'Carrefour Abobo Doumé',
                'city' => 'Abidjan',
                'region' => 'Abobo',
                'phone' => '+225 27 22 00 77 88',
                'email' => 'pharmacieabobo@yahoo.com',
                'license_number' => 'PHARM-CI-2024-007',
                'owner_name' => 'Dr. Konaté Mariam',
                'latitude' => 5.4167,
                'longitude' => -4.0167,
                'status' => 'approved',
                'approved_at' => now()->subDays(rand(1, 30)),
            ],
            [
                'name' => 'Pharmacie Adjamé',
                'address' => 'Avenue 13, Adjamé',
                'city' => 'Abidjan',
                'region' => 'Adjamé',
                'phone' => '+225 27 22 00 88 99',
                'email' => 'pharmacieadjame@hotmail.fr',
                'license_number' => 'PHARM-CI-2024-008',
                'owner_name' => 'Dr. Soro Abou',
                'latitude' => 5.3500,
                'longitude' => -4.0300,
                'status' => 'approved',
                'approved_at' => now()->subDays(rand(1, 30)),
            ],
            [
                'name' => 'Pharmacie de la Santé',
                'address' => 'Riviera 3, Cocody',
                'city' => 'Abidjan',
                'region' => 'Cocody',
                'phone' => '+225 27 22 00 99 00',
                'email' => 'pharmaciesante@gmail.com',
                'license_number' => 'PHARM-CI-2024-009',
                'owner_name' => 'Dr. Ouattara Aminata',
                'latitude' => 5.3650,
                'longitude' => -4.0000,
                'status' => 'pending',
                'approved_at' => null,
            ],
            [
                'name' => 'Pharmacie du Port',
                'address' => 'Zone Portuaire, Vridi',
                'city' => 'Abidjan',
                'region' => 'Vridi',
                'phone' => '+225 27 22 01 00 11',
                'email' => 'pharmacieduport@yahoo.fr',
                'license_number' => 'PHARM-CI-2024-010',
                'owner_name' => 'Dr. Traoré Ibrahima',
                'latitude' => 5.2667,
                'longitude' => -3.9667,
                'status' => 'pending',
                'approved_at' => null,
            ],
        ];

        foreach ($pharmacies as $pharmacyData) {
            Pharmacy::create($pharmacyData);
        }

        $approvedCount = Pharmacy::where('status', 'approved')->count();
        $pendingCount = Pharmacy::where('status', 'pending')->count();
        $this->command->info("✅ Created 10 pharmacies ({$approvedCount} approved, {$pendingCount} pending)");
    }
}


