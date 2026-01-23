<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Product;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class TestScenarioSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Create Pharmacy Entity
        $pharmacyEntity = \App\Models\Pharmacy::firstOrCreate(
            ['email' => 'pharmacy@test.com'],
            [
                'name' => 'Test Pharmacy',
                'phone' => '0102030405',
                'address' => 'Cocody Centre',
                'city' => 'Abidjan',
                'latitude' => 5.3600,
                'longitude' => -4.0083,
                'status' => 'approved',
            ]
        );

        // 2. Create Pharmacy User
        $pharmacyUser = User::firstOrCreate(
            ['email' => 'pharmacy@test.com'],
            [
                'name' => 'Test Pharmacy Owner',
                'password' => Hash::make('password'),
                'role' => 'pharmacy',
            ]
        );
        
        // Attach user to pharmacy if not already attached
        if (!$pharmacyUser->pharmacies()->where('pharmacy_id', $pharmacyEntity->id)->exists()) {
            $pharmacyUser->pharmacies()->attach($pharmacyEntity->id, ['role' => 'owner']);
        }
        
        $this->command->info('Pharmacy created: pharmacy@test.com / password');

        // 3. Create Courier User
        $courierUser = User::firstOrCreate(
            ['email' => 'courier@test.com'],
            [
                'name' => 'Test Courier',
                'password' => Hash::make('password'),
                'role' => 'courier',
            ]
        );

        // 4. Create Courier Profile
        \App\Models\Courier::firstOrCreate(
            ['user_id' => $courierUser->id],
            [
                'name' => 'Test Courier Profile',
                'phone' => '0504030201',
                'vehicle_type' => 'moto',
                'latitude' => 5.3610,
                'longitude' => -4.0090,
                'status' => 'available', // or 'online' depending on enum
            ]
        );
        
        $this->command->info('Courier created: courier@test.com / password');

        // 5. Create Product
        $product = Product::firstOrCreate(
            ['name' => 'Paracetamol 500mg'],
            [
                'pharmacy_id' => $pharmacyEntity->id, // Product usually belongs to pharmacy, not user
                'description' => 'Pain reliever',
                'price' => 1000,
                'stock_quantity' => 100,
                'requires_prescription' => false,
            ]
        );

        // 6. Create Customer
        $customer = User::firstOrCreate(
            ['email' => 'customer@test.com'],
            [
                'name' => 'Test Customer',
                'password' => Hash::make('password'),
                'role' => 'customer',
            ]
        );

        // 7. Create Order (Pending)
        $order = Order::create([
            'customer_id' => $customer->id,
            'pharmacy_id' => $pharmacyEntity->id,
            'reference' => 'ORD-' . time(),
            'customer_phone' => '0708091011',
            'subtotal' => 2000,
            'total_amount' => 2000,
            'status' => 'pending',
            'delivery_address' => 'Cocody, Abidjan',
            'delivery_latitude' => 5.3500,
            'delivery_longitude' => -4.0000,
        ]);

        OrderItem::create([
            'order_id' => $order->id,
            'product_id' => $product->id,
            'product_name' => $product->name,
            'quantity' => 2,
            'unit_price' => 1000,
            'total_price' => 2000,
        ]);

        $this->command->info("Order created: {$order->reference} (Status: pending)");
        $this->command->info("Run 'php artisan tinker' and execute:");
        $this->command->info("  \$order = App\Models\Order::find({$order->id});");
        $this->command->info("  \$order->update(['status' => 'ready_for_pickup']);");
        $this->command->info("To test courier assignment.");
    }
}
