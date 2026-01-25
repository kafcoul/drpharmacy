<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->command->info('🚀 Starting DR-PHARMA database seeding...');
        $this->command->newLine();

        // 1. Users (admin + customers)
        $this->command->info('👥 Seeding users...');
        $this->call(UserSeeder::class);
        $this->command->newLine();

        // 2. Duty Zones
        $this->command->info('🌍 Seeding duty zones...');
        $this->call(DutyZoneSeeder::class);
        $this->command->newLine();

        // 3. Pharmacies
        $this->command->info('💊 Seeding pharmacies...');
        $this->call(PharmacySeeder::class);
        $this->command->newLine();

        // 4. Couriers
        $this->command->info('🏍️  Seeding couriers...');
        $this->call(CourierSeeder::class);
        $this->command->newLine();

        // 5. Products
        $this->command->info('📦 Seeding products...');
        $this->call(ProductSeeder::class);
        $this->command->newLine();

        // 6. Challenges (Défis)
        $this->command->info('🏆 Seeding challenges...');
        $this->call(ChallengeSeeder::class);
        $this->command->newLine();

        // 7. Test Data for Courier App
        $this->command->info('📱 Seeding courier test data (deliveries, wallet, challenges progress)...');
        $this->call(CourierTestDataSeeder::class);
        $this->command->newLine();

        $this->command->info('✅ Database seeding completed successfully!');
        $this->command->newLine();
        $this->command->info('📊 Summary:');
        $this->command->info('   - Users: 11 (1 admin + 10 customers)');
        $this->command->info('   - Pharmacies: 10 (8 approved + 2 pending)');
        $this->command->info('   - Couriers: 8 (6 approved + 2 pending)');
        $this->command->info('   - Products: ~100+ across all pharmacies');
        $this->command->info('   - Challenges: 10+ (daily, weekly, monthly)');
        $this->command->info('   - Test Courier: 25+ deliveries, wallet with transactions');
        $this->command->newLine();
        $this->command->info('🔑 Admin credentials:');
        $this->command->info('   Email: admin@drpharma.ci');
        $this->command->info('   Password: password');
        $this->command->newLine();
        $this->command->info('📱 Test Courier credentials:');
        $this->command->info('   Email: test.courier@drpharma.ci');
        $this->command->info('   Password: password123');
    }
}
