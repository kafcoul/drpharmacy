<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Pharmacy;
use App\Models\Order;
use App\Models\Product;
use Illuminate\Support\Str;

class DemoOrderSeeder extends Seeder
{
    public function run()
    {
        // 1. Get our pharmacy (using the one you just created/logged in with if possible, or generic)
        $pharmacy = Pharmacy::first();

        if (!$pharmacy) {
            $this->command->error('No pharmacy found. Please create a pharmacy first.');
            return;
        }

        // 2. Create/Get a customer
        $customer = User::firstOrCreate(
            ['email' => 'customer_demo@app.com'],
            [
                'name' => 'Client Demo',
                'phone' => '0101010101',
                'password' => bcrypt('password'),
                'role' => 'customer'
            ]
        );

        // 3. Create a dummy product if none
        $product = Product::firstOrCreate(
            ['name' => 'Doliprane 1000mg', 'pharmacy_id' => $pharmacy->id],
            [
                'description' => 'Paracétamol pour maux de tête',
                'price' => 2000,
                'stock_quantity' => 100,
                'category' => 'Douleur',
                'requires_prescription' => false,
                'is_available' => true,
                'slug' => 'doliprane-' . Str::random(5)
            ]
        );

        // 4. Create an Order
        $order = Order::create([
            'reference' => 'CMD-' . strtoupper(Str::random(6)),
            'customer_id' => $customer->id,
            'pharmacy_id' => $pharmacy->id,
            'status' => 'pending', 
            'payment_mode' => 'platform',
            'subtotal' => 4500.00,
            'delivery_fee' => 1000.00,
            'total_amount' => 5500.00,
            'customer_phone' => $customer->phone,
            'delivery_address' => 'Cocody Centre, près de la banque',
            'delivery_latitude' => 5.3600,
            'delivery_longitude' => -4.0083
        ]);

        $order->items()->create([
            'product_id' => $product->id,
            'product_name' => $product->name,
            'quantity' => 2,
            'unit_price' => 2000,
            'total_price' => 4000
        ]);

        // Create a second one in "confirmed" state
         $order2 = Order::create([
            'reference' => 'CMD-' . strtoupper(Str::random(6)),
            'customer_id' => $customer->id,
            'pharmacy_id' => $pharmacy->id,
            'status' => 'confirmed',
            'payment_mode' => 'platform',
            'subtotal' => 2000.00,
            'delivery_fee' => 0.00,
            'total_amount' => 2000.00,
            'customer_phone' => $customer->phone,
            'delivery_address' => 'Marcory Zone 4',
            'delivery_latitude' => 5.3000,
            'delivery_longitude' => -4.0000
        ]);
        
        $order2->items()->create([
            'product_id' => $product->id,
            'product_name' => $product->name,
            'quantity' => 1,
            'unit_price' => 2000,
            'total_price' => 2000
        ]);

        $this->command->info('Demo orders created successfully for Pharmacy: ' . $pharmacy->name);
    }
}
