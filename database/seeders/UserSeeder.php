<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Admin user
        User::firstOrCreate(
            ['email' => 'admin@drpharma.ci'],
            [
                'name' => 'Admin DR-PHARMA',
                'password' => Hash::make('password'),
                'phone' => '+225 27 22 00 00 00',
                'role' => 'admin',
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
            ]
        );

        // Test customers
        $customerNames = [
            'Kouassi Jean',
            'Koné Fatou',
            'Yao Marie',
            'Diallo Ibrahim',
            'Touré Aminata',
            'N\'Guessan Paul',
            'Kouakou Sarah',
            'Traoré Mohamed',
            'Bamba Aïcha',
            'Koffi David',
        ];

        foreach ($customerNames as $name) {
            User::create([
                'name' => $name,
                'email' => strtolower(str_replace(' ', '.', $name)) . '@customer.test',
                'password' => Hash::make('password'),
                'phone' => '+225 0' . rand(1, 7) . ' ' . rand(10, 99) . ' ' . rand(10, 99) . ' ' . rand(10, 99) . ' ' . rand(10, 99),
                'role' => 'customer',
                'email_verified_at' => now(),
            ]);
        }

        $this->command->info('✅ Created 1 admin + 10 customers');
    }
}

