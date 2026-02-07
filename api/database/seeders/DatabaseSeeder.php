<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            UserSeeder::class,
            DutyZoneSeeder::class,
            PharmacySeeder::class,
            CourierSeeder::class,
            CategorySeeder::class,
            ProductSeeder::class,
            SettingsSeeder::class,
            OrderAndDeliverySeeder::class,
        ]);
    }
}
