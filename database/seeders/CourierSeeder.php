<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Courier;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class CourierSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $couriers = [
            [
                'name' => 'Konan Anderson',
                'email' => 'konan.anderson@courier.test',
                'phone' => '+225 07 01 02 03 04',
                'vehicle_type' => 'moto',
                'vehicle_number' => 'AA-1234-CI',
                'latitude' => 5.3200,
                'longitude' => -4.0100,
                'status' => 'available',
                'is_approved' => true,
            ],
            [
                'name' => 'Yao Serge',
                'email' => 'yao.serge@courier.test',
                'phone' => '+225 07 02 03 04 05',
                'vehicle_type' => 'moto',
                'vehicle_number' => 'AB-2345-CI',
                'latitude' => 5.3250,
                'longitude' => -4.0150,
                'status' => 'available',
                'is_approved' => true,
            ],
            [
                'name' => 'Koffi Samuel',
                'email' => 'koffi.samuel@courier.test',
                'phone' => '+225 07 03 04 05 06',
                'vehicle_type' => 'moto',
                'vehicle_number' => 'AC-3456-CI',
                'latitude' => 5.3599,
                'longitude' => -4.0083,
                'status' => 'available',
                'is_approved' => true,
            ],
            [
                'name' => 'Kouassi Patrick',
                'email' => 'kouassi.patrick@courier.test',
                'phone' => '+225 07 04 05 06 07',
                'vehicle_type' => 'voiture',
                'vehicle_number' => 'AD-4567-CI',
                'latitude' => 5.2900,
                'longitude' => -3.9800,
                'status' => 'available',
                'is_approved' => true,
            ],
            [
                'name' => 'N\'Guessan Eric',
                'email' => 'nguessan.eric@courier.test',
                'phone' => '+225 07 05 06 07 08',
                'vehicle_type' => 'moto',
                'vehicle_number' => 'AE-5678-CI',
                'latitude' => 5.2833,
                'longitude' => -4.0000,
                'status' => 'busy',
                'is_approved' => true,
            ],
            [
                'name' => 'Diallo Moussa',
                'email' => 'diallo.moussa@courier.test',
                'phone' => '+225 07 06 07 08 09',
                'vehicle_type' => 'moto',
                'vehicle_number' => 'AF-6789-CI',
                'latitude' => 5.3333,
                'longitude' => -4.0833,
                'status' => 'busy',
                'is_approved' => true,
            ],
            [
                'name' => 'Traoré Mamadou',
                'email' => 'traore.mamadou@courier.test',
                'phone' => '+225 07 07 08 09 10',
                'vehicle_type' => 'voiture',
                'vehicle_number' => 'AG-7890-CI',
                'latitude' => 5.4167,
                'longitude' => -4.0167,
                'status' => 'offline',
                'is_approved' => false,
            ],
            [
                'name' => 'Bamba Christian',
                'email' => 'bamba.christian@courier.test',
                'phone' => '+225 07 08 09 10 11',
                'vehicle_type' => 'moto',
                'vehicle_number' => 'AH-8901-CI',
                'latitude' => 5.3500,
                'longitude' => -4.0300,
                'status' => 'offline',
                'is_approved' => false,
            ],
        ];

        foreach ($couriers as $courierData) {
            // Create courier user
            $user = User::create([
                'name' => $courierData['name'],
                'email' => $courierData['email'],
                'password' => Hash::make('password'),
                'phone' => $courierData['phone'],
                'role' => 'courier',
                'email_verified_at' => now(),
            ]);

            // Create courier
            Courier::create([
                'user_id' => $user->id,
                'name' => $courierData['name'],
                'phone' => $courierData['phone'],
                'vehicle_type' => $courierData['vehicle_type'],
                'vehicle_number' => $courierData['vehicle_number'],
                'latitude' => $courierData['latitude'],
                'longitude' => $courierData['longitude'],
                'status' => $courierData['status'],
            ]);
        }

        $approvedCount = User::where('role', 'courier')->whereNotNull('email_verified_at')->count();
        $availableCount = Courier::where('status', 'available')->count();
        $this->command->info("✅ Created 8 couriers ({$approvedCount} approved, {$availableCount} available)");
    }
}


