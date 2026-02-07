<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Admin user
        User::firstOrCreate(
            ['phone' => '+2250700000000'],
            [
                'name' => 'Admin DR-PHARMA',
                'email' => 'admin@drpharma.ci',
                'password' => Hash::make('password'),
                'role' => 'admin',
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
            ]
        );

        // Test customer
        User::firstOrCreate(
            ['phone' => '+2250700000001'],
            [
                'name' => 'Client Test',
                'email' => 'client@drpharma.ci',
                'password' => Hash::make('password'),
                'role' => 'customer',
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
            ]
        );

        // Additional test users (only if we have less than 7 customers)
        $existingCustomers = User::where('role', 'customer')->count();
        if ($existingCustomers < 6) {
            User::factory(6 - $existingCustomers)->customer()->create();
        }
    }
}
