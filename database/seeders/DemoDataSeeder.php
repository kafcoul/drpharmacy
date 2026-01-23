<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Pharmacy;
use App\Models\Courier;
use App\Models\Product;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Support\Facades\Hash;

class DemoDataSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $this->command->info('🌱 Seeding demo data...');

        // Create Admin User
        $admin = User::create([
            'name' => 'Administrateur DR-PHARMA',
            'email' => 'admin@drpharma.ci',
            'password' => Hash::make('password'),
            'role' => 'admin',
            'phone' => '+225 07 00 00 00 01',
        ]);
        $this->command->info('✅ Admin user created');

        // Create 5 Pharmacies with users and products
        $pharmacyData = [
            [
                'name' => 'Pharmacie Centrale',
                'email' => 'centrale@drpharma.ci',
                'address' => 'Plateau, Abidjan',
                'latitude' => 5.3167,
                'longitude' => -4.0167,
            ],
            [
                'name' => 'Pharmacie du Plateau',
                'email' => 'plateau@drpharma.ci',
                'address' => 'Boulevard Angoulvant, Abidjan',
                'latitude' => 5.3200,
                'longitude' => -4.0200,
            ],
            [
                'name' => 'Pharmacie de Cocody',
                'email' => 'cocody@drpharma.ci',
                'address' => 'Cocody, Abidjan',
                'latitude' => 5.3500,
                'longitude' => -3.9800,
            ],
            [
                'name' => 'Pharmacie Adjamé',
                'email' => 'adjame@drpharma.ci',
                'address' => 'Adjamé, Abidjan',
                'latitude' => 5.3600,
                'longitude' => -4.0300,
            ],
            [
                'name' => 'Pharmacie de Marcory',
                'email' => 'marcory@drpharma.ci',
                'address' => 'Marcory, Abidjan',
                'latitude' => 5.2900,
                'longitude' => -3.9900,
            ],
        ];

        $pharmacies = [];
        foreach ($pharmacyData as $index => $data) {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => Hash::make('password'),
                'role' => 'pharmacy',
                'phone' => '+225 07 01 00 00 ' . str_pad($index + 1, 2, '0', STR_PAD_LEFT),
            ]);

            $pharmacy = Pharmacy::create([
                'user_id' => $user->id,
                'name' => $data['name'],
                'license_number' => 'PH-CI-2024-' . str_pad($index + 1, 5, '0', STR_PAD_LEFT),
                'address' => $data['address'],
                'phone' => $user->phone,
                'latitude' => $data['latitude'],
                'longitude' => $data['longitude'],
                'status' => 'approved',
            ]);

            $pharmacies[] = $pharmacy;
            
            // Create wallet for pharmacy
            $pharmacy->wallet()->create([
                'balance' => 0,
                'currency' => 'XOF',
            ]);
        }
        $this->command->info('✅ 5 Pharmacies created');

        // Create Products for each pharmacy
        $productCategories = [
            'analgesics' => [
                ['name' => 'Paracétamol 500mg', 'price' => 1500, 'stock' => 200],
                ['name' => 'Ibuprofène 400mg', 'price' => 2500, 'stock' => 150],
                ['name' => 'Aspirine 500mg', 'price' => 1800, 'stock' => 180],
                ['name' => 'Doliprane 1000mg', 'price' => 3000, 'stock' => 100],
            ],
            'antibiotics' => [
                ['name' => 'Amoxicilline 500mg', 'price' => 4500, 'stock' => 80, 'prescription' => true],
                ['name' => 'Azithromycine 250mg', 'price' => 6000, 'stock' => 60, 'prescription' => true],
                ['name' => 'Ciprofloxacine 500mg', 'price' => 5500, 'stock' => 70, 'prescription' => true],
            ],
            'antihistamines' => [
                ['name' => 'Loratadine 10mg', 'price' => 2000, 'stock' => 120],
                ['name' => 'Cétirizine 10mg', 'price' => 2200, 'stock' => 110],
            ],
            'vitamins' => [
                ['name' => 'Vitamine C 500mg', 'price' => 3500, 'stock' => 200],
                ['name' => 'Vitamine D3 1000UI', 'price' => 4000, 'stock' => 150],
                ['name' => 'Complexe B', 'price' => 5000, 'stock' => 100],
            ],
            'antacids' => [
                ['name' => 'Oméprazole 20mg', 'price' => 3000, 'stock' => 90],
                ['name' => 'Gaviscon suspension', 'price' => 2500, 'stock' => 120],
            ],
        ];

        foreach ($pharmacies as $pharmacy) {
            foreach ($productCategories as $category => $products) {
                foreach ($products as $productData) {
                    Product::create([
                        'pharmacy_id' => $pharmacy->id,
                        'name' => $productData['name'],
                        'slug' => \Illuminate\Support\Str::slug($productData['name'] . '-' . $pharmacy->id),
                        'category' => $category,
                        'description' => 'Médicament de qualité disponible en pharmacie.',
                        'price' => $productData['price'],
                        'stock_quantity' => $productData['stock'],
                        'low_stock_threshold' => 20,
                        'requires_prescription' => $productData['prescription'] ?? false,
                        'is_available' => true,
                        'is_featured' => rand(0, 1) === 1,
                    ]);
                }
            }
        }
        $this->command->info('✅ Products created for all pharmacies');

        // Create 10 Couriers
        for ($i = 1; $i <= 10; $i++) {
            $user = User::create([
                'name' => "Livreur #{$i}",
                'email' => "courier{$i}@drpharma.ci",
                'password' => Hash::make('password'),
                'role' => 'courier',
                'phone' => '+225 07 02 00 00 ' . str_pad($i, 2, '0', STR_PAD_LEFT),
            ]);

            $courier = Courier::create([
                'user_id' => $user->id,
                'vehicle_type' => $i <= 6 ? 'motorcycle' : ($i <= 9 ? 'car' : 'bicycle'),
                'license_number' => 'DL-CI-2024-' . str_pad($i, 5, '0', STR_PAD_LEFT),
                'current_latitude' => 5.3000 + (rand(-50, 50) / 1000),
                'current_longitude' => -4.0000 + (rand(-50, 50) / 1000),
                'is_available' => $i <= 7,
                'status' => 'approved',
            ]);

            // Create wallet for courier
            $courier->wallet()->create([
                'balance' => 0,
                'currency' => 'XOF',
            ]);
        }
        $this->command->info('✅ 10 Couriers created');

        // Create 5 Customer Users
        $customers = [];
        for ($i = 1; $i <= 5; $i++) {
            $user = User::create([
                'name' => "Client #{$i}",
                'email' => "client{$i}@drpharma.ci",
                'password' => Hash::make('password'),
                'role' => 'customer',
                'phone' => '+225 07 03 00 00 ' . str_pad($i, 2, '0', STR_PAD_LEFT),
                'address' => "Abidjan, Quartier #{$i}",
            ]);

            // Create wallet for customer
            $user->wallet()->create([
                'balance' => 0,
                'currency' => 'XOF',
            ]);

            $customers[] = $user;
        }
        $this->command->info('✅ 5 Customers created');

        // Create some sample orders
        foreach ($customers as $index => $customer) {
            $pharmacy = $pharmacies[$index % count($pharmacies)];
            $products = Product::where('pharmacy_id', $pharmacy->id)->inRandomOrder()->take(rand(1, 3))->get();

            $order = Order::create([
                'customer_id' => $customer->id,
                'pharmacy_id' => $pharmacy->id,
                'order_number' => 'ORD-' . strtoupper(\Illuminate\Support\Str::random(8)),
                'status' => ['pending', 'confirmed', 'ready', 'in_transit', 'delivered'][rand(0, 4)],
                'total_amount' => 0,
                'delivery_address' => $customer->address,
                'delivery_latitude' => 5.3000 + (rand(-100, 100) / 1000),
                'delivery_longitude' => -4.0000 + (rand(-100, 100) / 1000),
            ]);

            $totalAmount = 0;
            foreach ($products as $product) {
                $quantity = rand(1, 3);
                $price = $product->price;

                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $product->id,
                    'quantity' => $quantity,
                    'price' => $price,
                    'subtotal' => $price * $quantity,
                ]);

                $totalAmount += $price * $quantity;
            }

            $order->update(['total_amount' => $totalAmount]);
        }
        $this->command->info('✅ Sample orders created');

        $this->command->info('');
        $this->command->info('🎉 Demo data seeding completed!');
        $this->command->info('');
        $this->command->info('📝 Login Credentials:');
        $this->command->info('   Admin: admin@drpharma.ci / password');
        $this->command->info('   Pharmacy: centrale@drpharma.ci / password');
        $this->command->info('   Courier: courier1@drpharma.ci / password');
        $this->command->info('   Customer: client1@drpharma.ci / password');
        $this->command->info('');
    }
}
