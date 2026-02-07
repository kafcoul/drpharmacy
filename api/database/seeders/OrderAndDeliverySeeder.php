<?php

namespace Database\Seeders;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Delivery;
use App\Models\User;
use App\Models\Pharmacy;
use App\Models\Courier;
use App\Models\Product;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class OrderAndDeliverySeeder extends Seeder
{
    public function run(): void
    {
        $customers = User::where('role', 'customer')->get();
        $pharmacies = Pharmacy::all();
        $couriers = Courier::all();

        if ($customers->isEmpty() || $pharmacies->isEmpty()) {
            $this->command->warn('Aucun client ou pharmacie trouvé. Exécutez d\'abord UserSeeder et PharmacySeeder.');
            return;
        }

        // Créer différents types de commandes
        $this->createDeliveredOrders($customers, $pharmacies, $couriers);
        $this->createInProgressOrders($customers, $pharmacies, $couriers);
        $this->createPendingOrders($customers, $pharmacies);
        $this->createCancelledOrders($customers, $pharmacies);

        $this->command->info('Commandes et livraisons créées avec succès !');
    }

    /**
     * Commandes livrées (historique)
     */
    private function createDeliveredOrders($customers, $pharmacies, $couriers): void
    {
        for ($i = 0; $i < 5; $i++) {
            $customer = $customers->random();
            $pharmacy = $pharmacies->random();
            $courier = $couriers->isNotEmpty() ? $couriers->random() : null;
            $products = Product::where('pharmacy_id', $pharmacy->id)->inRandomOrder()->limit(rand(1, 3))->get();

            if ($products->isEmpty()) continue;

            $subtotal = 0;
            $items = [];

            foreach ($products as $product) {
                $quantity = rand(1, 3);
                $unitPrice = $product->price;
                $totalPrice = $unitPrice * $quantity;
                $subtotal += $totalPrice;

                $items[] = [
                    'product_id' => $product->id,
                    'product_name' => $product->name,
                    'product_sku' => $product->sku,
                    'quantity' => $quantity,
                    'unit_price' => $unitPrice,
                    'total_price' => $totalPrice,
                ];
            }

            $deliveryFee = 1000;
            $serviceFee = round($subtotal * 0.05);
            $totalAmount = $subtotal + $deliveryFee + $serviceFee;

            $deliveredAt = now()->subDays(rand(1, 30))->subHours(rand(1, 12));

            $order = Order::create([
                'reference' => 'ORD-' . strtoupper(Str::random(8)),
                'pharmacy_id' => $pharmacy->id,
                'customer_id' => $customer->id,
                'status' => 'delivered',
                'payment_mode' => fake()->randomElement(['mobile_money', 'cash', 'platform']),
                'subtotal' => $subtotal,
                'delivery_fee' => $deliveryFee,
                'service_fee' => $serviceFee,
                'total_amount' => $totalAmount,
                'delivery_address' => fake()->address(),
                'delivery_city' => 'Abidjan',
                'delivery_latitude' => 5.3600 + (rand(-100, 100) / 10000),
                'delivery_longitude' => -4.0083 + (rand(-100, 100) / 10000),
                'customer_phone' => $customer->phone,
                'delivery_code' => rand(1000, 9999),
                'payment_status' => 'paid',
                'confirmed_at' => $deliveredAt->copy()->subHours(3),
                'paid_at' => $deliveredAt->copy()->subHours(2),
                'delivered_at' => $deliveredAt,
            ]);

            foreach ($items as $item) {
                OrderItem::create(array_merge($item, ['order_id' => $order->id]));
            }

            if ($courier) {
                Delivery::create([
                    'order_id' => $order->id,
                    'courier_id' => $courier->id,
                    'status' => 'delivered',
                    'pickup_latitude' => $pharmacy->latitude,
                    'pickup_longitude' => $pharmacy->longitude,
                    'pickup_address' => $pharmacy->address,
                    'delivery_latitude' => $order->delivery_latitude,
                    'delivery_longitude' => $order->delivery_longitude,
                    'delivery_address' => $order->delivery_address,
                    'estimated_distance' => rand(2, 15),
                    'estimated_duration' => rand(15, 45),
                    'delivery_fee' => $deliveryFee,
                    'assigned_at' => $deliveredAt->copy()->subHours(2),
                    'accepted_at' => $deliveredAt->copy()->subHours(2)->addMinutes(5),
                    'picked_up_at' => $deliveredAt->copy()->subHour(),
                    'delivered_at' => $deliveredAt,
                ]);
            }
        }
    }

    /**
     * Commandes en cours de livraison
     */
    private function createInProgressOrders($customers, $pharmacies, $couriers): void
    {
        if ($couriers->isEmpty()) return;

        for ($i = 0; $i < 3; $i++) {
            $customer = $customers->random();
            $pharmacy = $pharmacies->random();
            $courier = $couriers->random();
            $products = Product::where('pharmacy_id', $pharmacy->id)->inRandomOrder()->limit(rand(1, 2))->get();

            if ($products->isEmpty()) continue;

            $subtotal = 0;
            $items = [];

            foreach ($products as $product) {
                $quantity = rand(1, 2);
                $unitPrice = $product->price;
                $totalPrice = $unitPrice * $quantity;
                $subtotal += $totalPrice;

                $items[] = [
                    'product_id' => $product->id,
                    'product_name' => $product->name,
                    'product_sku' => $product->sku,
                    'quantity' => $quantity,
                    'unit_price' => $unitPrice,
                    'total_price' => $totalPrice,
                ];
            }

            $deliveryFee = 1000;
            $serviceFee = round($subtotal * 0.05);
            $totalAmount = $subtotal + $deliveryFee + $serviceFee;

            $statuses = ['assigned', 'in_delivery'];
            $orderStatus = fake()->randomElement($statuses);
            $deliveryStatus = $orderStatus === 'assigned' ? 'accepted' : 'in_transit';

            $order = Order::create([
                'reference' => 'ORD-' . strtoupper(Str::random(8)),
                'pharmacy_id' => $pharmacy->id,
                'customer_id' => $customer->id,
                'status' => $orderStatus,
                'payment_mode' => 'platform',
                'subtotal' => $subtotal,
                'delivery_fee' => $deliveryFee,
                'service_fee' => $serviceFee,
                'total_amount' => $totalAmount,
                'delivery_address' => fake()->address(),
                'delivery_city' => 'Abidjan',
                'delivery_latitude' => 5.3600 + (rand(-100, 100) / 10000),
                'delivery_longitude' => -4.0083 + (rand(-100, 100) / 10000),
                'customer_phone' => $customer->phone,
                'delivery_code' => rand(1000, 9999),
                'payment_status' => 'paid',
                'confirmed_at' => now()->subHours(2),
                'paid_at' => now()->subHours(1),
            ]);

            foreach ($items as $item) {
                OrderItem::create(array_merge($item, ['order_id' => $order->id]));
            }

            Delivery::create([
                'order_id' => $order->id,
                'courier_id' => $courier->id,
                'status' => $deliveryStatus,
                'pickup_latitude' => $pharmacy->latitude,
                'pickup_longitude' => $pharmacy->longitude,
                'pickup_address' => $pharmacy->address,
                'delivery_latitude' => $order->delivery_latitude,
                'delivery_longitude' => $order->delivery_longitude,
                'delivery_address' => $order->delivery_address,
                'estimated_distance' => rand(2, 10),
                'estimated_duration' => rand(15, 30),
                'delivery_fee' => $deliveryFee,
                'assigned_at' => now()->subMinutes(30),
                'accepted_at' => now()->subMinutes(25),
                'picked_up_at' => $deliveryStatus === 'in_transit' ? now()->subMinutes(10) : null,
            ]);
        }
    }

    /**
     * Commandes en attente
     */
    private function createPendingOrders($customers, $pharmacies): void
    {
        for ($i = 0; $i < 3; $i++) {
            $customer = $customers->random();
            $pharmacy = $pharmacies->random();
            $products = Product::where('pharmacy_id', $pharmacy->id)->inRandomOrder()->limit(rand(1, 3))->get();

            if ($products->isEmpty()) continue;

            $subtotal = 0;
            $items = [];

            foreach ($products as $product) {
                $quantity = rand(1, 2);
                $unitPrice = $product->price;
                $totalPrice = $unitPrice * $quantity;
                $subtotal += $totalPrice;

                $items[] = [
                    'product_id' => $product->id,
                    'product_name' => $product->name,
                    'product_sku' => $product->sku,
                    'quantity' => $quantity,
                    'unit_price' => $unitPrice,
                    'total_price' => $totalPrice,
                ];
            }

            $deliveryFee = 1000;
            $serviceFee = round($subtotal * 0.05);
            $totalAmount = $subtotal + $deliveryFee + $serviceFee;

            $statuses = ['pending', 'confirmed', 'preparing', 'ready'];
            $status = fake()->randomElement($statuses);

            $order = Order::create([
                'reference' => 'ORD-' . strtoupper(Str::random(8)),
                'pharmacy_id' => $pharmacy->id,
                'customer_id' => $customer->id,
                'status' => $status,
                'payment_mode' => fake()->randomElement(['mobile_money', 'cash', 'platform']),
                'subtotal' => $subtotal,
                'delivery_fee' => $deliveryFee,
                'service_fee' => $serviceFee,
                'total_amount' => $totalAmount,
                'delivery_address' => fake()->address(),
                'delivery_city' => 'Abidjan',
                'delivery_latitude' => 5.3600 + (rand(-100, 100) / 10000),
                'delivery_longitude' => -4.0083 + (rand(-100, 100) / 10000),
                'customer_phone' => $customer->phone,
                'payment_status' => in_array($status, ['pending']) ? 'pending' : 'paid',
                'confirmed_at' => in_array($status, ['confirmed', 'preparing', 'ready']) ? now()->subMinutes(rand(10, 60)) : null,
                'paid_at' => in_array($status, ['confirmed', 'preparing', 'ready']) ? now()->subMinutes(rand(5, 30)) : null,
            ]);

            foreach ($items as $item) {
                OrderItem::create(array_merge($item, ['order_id' => $order->id]));
            }

            // Créer une livraison en attente pour les commandes "ready"
            if ($status === 'ready') {
                Delivery::create([
                    'order_id' => $order->id,
                    'courier_id' => null,
                    'status' => 'pending',
                    'pickup_latitude' => $pharmacy->latitude,
                    'pickup_longitude' => $pharmacy->longitude,
                    'pickup_address' => $pharmacy->address,
                    'delivery_latitude' => $order->delivery_latitude,
                    'delivery_longitude' => $order->delivery_longitude,
                    'delivery_address' => $order->delivery_address,
                    'estimated_distance' => rand(2, 15),
                    'estimated_duration' => rand(15, 45),
                    'delivery_fee' => $deliveryFee,
                ]);
            }
        }
    }

    /**
     * Commandes annulées
     */
    private function createCancelledOrders($customers, $pharmacies): void
    {
        for ($i = 0; $i < 2; $i++) {
            $customer = $customers->random();
            $pharmacy = $pharmacies->random();
            $products = Product::where('pharmacy_id', $pharmacy->id)->inRandomOrder()->limit(rand(1, 2))->get();

            if ($products->isEmpty()) continue;

            $subtotal = 0;
            $items = [];

            foreach ($products as $product) {
                $quantity = rand(1, 2);
                $unitPrice = $product->price;
                $totalPrice = $unitPrice * $quantity;
                $subtotal += $totalPrice;

                $items[] = [
                    'product_id' => $product->id,
                    'product_name' => $product->name,
                    'product_sku' => $product->sku,
                    'quantity' => $quantity,
                    'unit_price' => $unitPrice,
                    'total_price' => $totalPrice,
                ];
            }

            $deliveryFee = 1000;
            $serviceFee = round($subtotal * 0.05);
            $totalAmount = $subtotal + $deliveryFee + $serviceFee;

            $cancelReasons = [
                'Client indisponible',
                'Produit en rupture de stock',
                'Délai de livraison trop long',
                'Annulé par le client',
            ];

            $order = Order::create([
                'reference' => 'ORD-' . strtoupper(Str::random(8)),
                'pharmacy_id' => $pharmacy->id,
                'customer_id' => $customer->id,
                'status' => 'cancelled',
                'payment_mode' => 'platform',
                'subtotal' => $subtotal,
                'delivery_fee' => $deliveryFee,
                'service_fee' => $serviceFee,
                'total_amount' => $totalAmount,
                'delivery_address' => fake()->address(),
                'delivery_city' => 'Abidjan',
                'delivery_latitude' => 5.3600 + (rand(-100, 100) / 10000),
                'delivery_longitude' => -4.0083 + (rand(-100, 100) / 10000),
                'customer_phone' => $customer->phone,
                'payment_status' => 'refunded',
                'confirmed_at' => now()->subDays(rand(1, 7)),
                'cancelled_at' => now()->subDays(rand(1, 7))->addHours(rand(1, 5)),
                'cancellation_reason' => fake()->randomElement($cancelReasons),
            ]);

            foreach ($items as $item) {
                OrderItem::create(array_merge($item, ['order_id' => $order->id]));
            }
        }
    }
}
