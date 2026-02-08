<?php

namespace App\Console\Commands;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Delivery;
use App\Models\User;
use App\Models\Pharmacy;
use App\Models\Product;
use Illuminate\Console\Command;
use Illuminate\Support\Str;

class CreateTestOrders extends Command
{
    protected $signature = 'orders:create-test 
                            {--pharmacy= : ID de la pharmacie (optionnel, utilise la première par défaut)}
                            {--count=10 : Nombre total de commandes à créer}
                            {--pending-only : Créer uniquement des commandes en attente (pour tester les nouvelles commandes)}
                            {--clear : Supprimer les commandes existantes de la pharmacie avant de créer}';

    protected $description = 'Créer des commandes de test pour l\'application pharmacy mobile';

    // Noms de clients ivoiriens réalistes
    private array $customerNames = [
        'Kouamé Aya', 'N\'Guessan Koffi', 'Ouattara Aminata', 'Koné Ibrahim',
        'Bamba Fatou', 'Yao Christelle', 'Touré Mamadou', 'Coulibaly Aïcha',
        'Diallo Sékou', 'Traoré Mariam', 'Konan Jean-Claude', 'Aka Patricia',
        'Gnahoré Vincent', 'Ehouman Marie', 'Brou Stéphane', 'Dembélé Rokia',
        'Sangaré Lacina', 'Diabaté Fanta', 'Cissé Oumar', 'Fofana Karidja'
    ];

    // Adresses d'Abidjan réalistes
    private array $addresses = [
        'Cocody Angré 7ème Tranche, près du supermarché',
        'Yopougon Maroc, derrière le lycée',
        'Marcory Zone 4, rue des Jardins',
        'Plateau, Avenue Chardy, immeuble CCIA',
        'Treichville, marché de Treichville',
        'Adjamé, près de la gare routière',
        'Abobo Avocatier, cité SIR',
        'Koumassi Remblais, face école primaire',
        'Port-Bouët Gonzagueville, camp militaire',
        'Bingerville centre, près de la mairie',
        'Riviera Palmeraie, cité Allabra',
        'Cocody Danga, non loin de l\'ambassade',
        'Yopougon Sicogi, secteur 3',
        'Marcory Anoumabo, rue 12',
        'Adjamé Liberté, près du commissariat',
        '2 Plateaux Les Vallons, résidence Palmiers',
        'Riviera 3, près du centre commercial',
        'Cocody Blockhaus, cité universitaire',
        'Yopougon Niangon Nord, cité verte',
        'Marcory Biétry, zone industrielle'
    ];

    // Notes clients réalistes
    private array $customerNotes = [
        'Merci de livrer avant 18h svp',
        'Appeler avant d\'arriver',
        'Laisser au gardien si absent',
        'Sonner 2 fois à la porte bleue',
        'Je suis au 3ème étage, appartement B',
        'Code portail: 1234',
        'Livrer côté garage',
        '',
        '',
        '', // Quelques commandes sans notes
    ];

    public function handle(): int
    {
        $pharmacyId = $this->option('pharmacy');
        $count = (int) $this->option('count');
        $clear = $this->option('clear');
        $pendingOnly = $this->option('pending-only');

        // Récupérer ou sélectionner la pharmacie
        if ($pharmacyId) {
            $pharmacy = Pharmacy::find($pharmacyId);
            if (!$pharmacy) {
                $this->error("Pharmacie avec ID {$pharmacyId} non trouvée.");
                return 1;
            }
        } else {
            $pharmacy = Pharmacy::first();
            if (!$pharmacy) {
                $this->error('Aucune pharmacie trouvée. Veuillez d\'abord créer une pharmacie.');
                return 1;
            }
        }

        $this->info("📍 Pharmacie sélectionnée: {$pharmacy->name} (ID: {$pharmacy->id})");

        // Supprimer les commandes existantes si demandé
        if ($clear) {
            $deleted = Order::where('pharmacy_id', $pharmacy->id)->delete();
            $this->warn("🗑️  {$deleted} commandes supprimées.");
        }

        // Récupérer ou créer des clients test
        $customers = $this->getOrCreateCustomers();
        
        // Récupérer les produits de la pharmacie
        $products = Product::where('pharmacy_id', $pharmacy->id)->get();
        
        if ($products->isEmpty()) {
            $this->warn('⚠️  Aucun produit trouvé pour cette pharmacie. Création de produits de test...');
            $products = $this->createTestProducts($pharmacy);
        }

        $this->info("🏃 Création de {$count} commandes de test...");
        if ($pendingOnly) {
            $this->info("📋 Mode: uniquement des commandes EN ATTENTE (pending)");
        }
        $this->newLine();

        $progressBar = $this->output->createProgressBar($count);

        // Si pendingOnly, créer uniquement des commandes en attente
        if ($pendingOnly) {
            for ($i = 0; $i < $count; $i++) {
                $this->createOrder($pharmacy, $customers->random(), $products, 'pending');
                $progressBar->advance();
            }
        } else {
            // Répartition des statuts
            $statusDistribution = [
                'pending' => max(1, (int)($count * 0.15)),      // 15% en attente
                'confirmed' => max(1, (int)($count * 0.10)),   // 10% confirmées
                'preparing' => max(1, (int)($count * 0.10)),   // 10% en préparation
                'ready' => max(1, (int)($count * 0.10)),       // 10% prêtes
                'assigned' => max(1, (int)($count * 0.10)),    // 10% assignées
                'in_delivery' => max(1, (int)($count * 0.10)), // 10% en livraison
                'delivered' => max(1, (int)($count * 0.25)),   // 25% livrées
                'cancelled' => max(1, (int)($count * 0.10)),   // 10% annulées
            ];

            $created = 0;
            foreach ($statusDistribution as $status => $statusCount) {
                for ($i = 0; $i < $statusCount && $created < $count; $i++) {
                    $this->createOrder($pharmacy, $customers->random(), $products, $status);
                    $created++;
                    $progressBar->advance();
                }
            }
        }

        $progressBar->finish();
        $this->newLine(2);

        // Afficher le résumé
        $this->displaySummary($pharmacy);

        return 0;
    }

    private function getOrCreateCustomers()
    {
        $customers = User::where('role', 'customer')->get();
        
        if ($customers->count() < 5) {
            $this->info('📝 Création de clients de test...');
            
            for ($i = $customers->count(); $i < 10; $i++) {
                User::create([
                    'name' => $this->customerNames[$i % count($this->customerNames)],
                    'phone' => '+22507' . str_pad(rand(10000000, 99999999), 8, '0', STR_PAD_LEFT),
                    'email' => 'client' . ($i + 1) . '@test.ci',
                    'password' => bcrypt('password'),
                    'role' => 'customer',
                    'phone_verified_at' => now(),
                ]);
            }
            
            $customers = User::where('role', 'customer')->get();
        }
        
        return $customers;
    }

    private function createTestProducts(Pharmacy $pharmacy)
    {
        $testProducts = [
            ['name' => 'Doliprane 1000mg', 'price' => 2500, 'category' => 'Antidouleurs'],
            ['name' => 'Efferalgan 500mg', 'price' => 1800, 'category' => 'Antidouleurs'],
            ['name' => 'Spasfon Lyoc', 'price' => 3500, 'category' => 'Antidouleurs'],
            ['name' => 'Augmentin 500mg', 'price' => 8500, 'category' => 'Antibiotiques'],
            ['name' => 'Amoxicilline 250mg', 'price' => 4500, 'category' => 'Antibiotiques'],
            ['name' => 'Smecta', 'price' => 2000, 'category' => 'Gastro'],
            ['name' => 'Imodium', 'price' => 3000, 'category' => 'Gastro'],
            ['name' => 'Vitamine C 1000mg', 'price' => 5500, 'category' => 'Vitamines'],
            ['name' => 'Zinc + B6', 'price' => 7500, 'category' => 'Vitamines'],
            ['name' => 'Paracétamol Générique', 'price' => 1500, 'category' => 'Antidouleurs'],
            ['name' => 'Ibuprofène 400mg', 'price' => 2200, 'category' => 'Anti-inflammatoires'],
            ['name' => 'Aspro 500mg', 'price' => 1200, 'category' => 'Antidouleurs'],
            ['name' => 'Maalox', 'price' => 4200, 'category' => 'Gastro'],
            ['name' => 'Zyrtec 10mg', 'price' => 6800, 'category' => 'Allergies'],
            ['name' => 'Voltarène Gel', 'price' => 5200, 'category' => 'Anti-inflammatoires'],
        ];

        $products = collect();
        foreach ($testProducts as $productData) {
            $product = Product::create([
                'pharmacy_id' => $pharmacy->id,
                'name' => $productData['name'],
                'slug' => Str::slug($productData['name']),
                'sku' => 'TEST-' . strtoupper(Str::random(6)),
                'price' => $productData['price'],
                'stock_quantity' => rand(10, 100),
                'category' => $productData['category'],
                'is_available' => true,
            ]);
            $products->push($product);
        }

        return $products;
    }

    private function createOrder(Pharmacy $pharmacy, User $customer, $products, string $status): void
    {
        // Sélectionner 1-4 produits aléatoires
        $selectedProducts = $products->random(rand(1, min(4, $products->count())));
        
        $subtotal = 0;
        $items = [];
        
        foreach ($selectedProducts as $product) {
            $quantity = rand(1, 3);
            $unitPrice = $product->price;
            $totalPrice = $unitPrice * $quantity;
            $subtotal += $totalPrice;
            
            $items[] = [
                'product_id' => $product->id,
                'product_name' => $product->name,
                'product_sku' => $product->sku ?? 'N/A',
                'quantity' => $quantity,
                'unit_price' => $unitPrice,
                'total_price' => $totalPrice,
            ];
        }

        $deliveryFee = rand(500, 1500);
        $serviceFee = round($subtotal * 0.03);
        $totalAmount = $subtotal + $deliveryFee + $serviceFee;

        // Dates selon le statut
        $createdAt = $this->getCreatedAtForStatus($status);
        
        $paymentModes = ['cash', 'mobile_money', 'platform'];
        $paymentMode = $paymentModes[array_rand($paymentModes)];
        
        // Déterminer le statut de paiement
        $paymentStatus = 'pending';
        if (in_array($status, ['confirmed', 'preparing', 'ready', 'assigned', 'in_delivery', 'delivered'])) {
            $paymentStatus = 'paid';
        } elseif ($status === 'cancelled') {
            $paymentStatus = rand(0, 1) ? 'refunded' : 'pending';
        }

        // Coordonnées de livraison autour d'Abidjan
        $deliveryLat = 5.3600 + (rand(-500, 500) / 10000);
        $deliveryLng = -4.0083 + (rand(-500, 500) / 10000);

        $orderData = [
            'reference' => 'ORD-' . strtoupper(Str::random(8)),
            'pharmacy_id' => $pharmacy->id,
            'customer_id' => $customer->id,
            'status' => $status,
            'payment_mode' => $paymentMode,
            'payment_status' => $paymentStatus,
            'subtotal' => $subtotal,
            'delivery_fee' => $deliveryFee,
            'service_fee' => $serviceFee,
            'total_amount' => $totalAmount,
            'delivery_address' => $this->addresses[array_rand($this->addresses)],
            'delivery_city' => 'Abidjan',
            'delivery_latitude' => $deliveryLat,
            'delivery_longitude' => $deliveryLng,
            'customer_phone' => $customer->phone,
            'customer_notes' => $this->customerNotes[array_rand($this->customerNotes)] ?: null,
            'delivery_code' => rand(1000, 9999),
        ];

        // Ajouter les timestamps selon le statut
        if (in_array($status, ['confirmed', 'preparing', 'ready', 'assigned', 'in_delivery', 'delivered'])) {
            $orderData['confirmed_at'] = $createdAt->copy()->addMinutes(rand(5, 30));
        }
        if ($paymentStatus === 'paid') {
            $orderData['paid_at'] = $orderData['confirmed_at'] ?? $createdAt->copy()->addMinutes(rand(1, 10));
        }
        if ($status === 'delivered') {
            $orderData['delivered_at'] = $createdAt->copy()->addHours(rand(1, 4));
        }
        if ($status === 'cancelled') {
            $orderData['cancelled_at'] = $createdAt->copy()->addMinutes(rand(10, 60));
            $orderData['cancellation_reason'] = $this->getCancellationReason();
        }

        $order = Order::create($orderData);

        // Créer les items de la commande
        foreach ($items as $item) {
            OrderItem::create(array_merge($item, ['order_id' => $order->id]));
        }

        // Créer une livraison si nécessaire
        if (in_array($status, ['assigned', 'in_delivery', 'delivered'])) {
            $this->createDelivery($order, $pharmacy, $status);
        }
    }

    private function getCreatedAtForStatus(string $status): \Carbon\Carbon
    {
        return match($status) {
            'pending' => now()->subMinutes(rand(5, 60)),
            'confirmed' => now()->subMinutes(rand(30, 120)),
            'preparing' => now()->subMinutes(rand(45, 150)),
            'ready' => now()->subHours(rand(1, 3)),
            'assigned' => now()->subHours(rand(1, 4)),
            'in_delivery' => now()->subHours(rand(1, 2)),
            'delivered' => now()->subDays(rand(1, 30)),
            'cancelled' => now()->subDays(rand(1, 14)),
            default => now(),
        };
    }

    private function getCancellationReason(): string
    {
        $reasons = [
            'Client injoignable',
            'Adresse de livraison incorrecte',
            'Médicament en rupture de stock',
            'Annulation par le client',
            'Délai de livraison trop long',
            'Problème de paiement',
        ];
        
        return $reasons[array_rand($reasons)];
    }

    private function createDelivery(Order $order, Pharmacy $pharmacy, string $status): void
    {
        // Récupérer un coursier ou créer un mock
        $courier = \App\Models\Courier::inRandomOrder()->first();
        
        if (!$courier) {
            return; // Pas de livraison si aucun coursier
        }

        $deliveryStatus = match($status) {
            'assigned' => 'accepted',
            'in_delivery' => 'in_transit',
            'delivered' => 'delivered',
            default => 'pending',
        };

        $deliveryData = [
            'order_id' => $order->id,
            'courier_id' => $courier->id,
            'status' => $deliveryStatus,
            'pickup_latitude' => $pharmacy->latitude,
            'pickup_longitude' => $pharmacy->longitude,
            'pickup_address' => $pharmacy->address,
            'delivery_latitude' => $order->delivery_latitude,
            'delivery_longitude' => $order->delivery_longitude,
            'delivery_address' => $order->delivery_address,
            'estimated_distance' => rand(2, 15),
            'estimated_duration' => rand(15, 45),
            'delivery_fee' => $order->delivery_fee,
            'assigned_at' => $order->confirmed_at ?? now(),
            'accepted_at' => $order->confirmed_at?->copy()->addMinutes(5),
        ];

        if (in_array($status, ['in_delivery', 'delivered'])) {
            $deliveryData['picked_up_at'] = $order->confirmed_at?->copy()->addMinutes(30);
        }
        
        if ($status === 'delivered') {
            $deliveryData['delivered_at'] = $order->delivered_at;
        }

        Delivery::create($deliveryData);
    }

    private function displaySummary(Pharmacy $pharmacy): void
    {
        $this->info('═══════════════════════════════════════════════════════');
        $this->info('📊 RÉSUMÉ DES COMMANDES DE TEST');
        $this->info('═══════════════════════════════════════════════════════');
        
        $stats = Order::where('pharmacy_id', $pharmacy->id)
            ->selectRaw('status, count(*) as count, sum(total_amount) as total')
            ->groupBy('status')
            ->get();

        $statusLabels = [
            'pending' => '⏳ En attente',
            'confirmed' => '✅ Confirmées',
            'preparing' => '🔄 En préparation',
            'ready' => '📦 Prêtes',
            'assigned' => '🚚 Assignées',
            'in_delivery' => '🏃 En livraison',
            'delivered' => '✔️  Livrées',
            'cancelled' => '❌ Annulées',
        ];

        $totalOrders = 0;
        $totalAmount = 0;
        
        foreach ($stats as $stat) {
            $label = $statusLabels[$stat->status] ?? $stat->status;
            $amount = number_format($stat->total, 0, ',', ' ');
            $this->line("  {$label}: {$stat->count} commandes ({$amount} FCFA)");
            $totalOrders += $stat->count;
            $totalAmount += $stat->total;
        }

        $this->newLine();
        $this->info("📈 Total: {$totalOrders} commandes");
        $this->info("💰 Montant total: " . number_format($totalAmount, 0, ',', ' ') . ' FCFA');
        $this->newLine();
        $this->info('✅ Commandes de test créées avec succès !');
        $this->info('═══════════════════════════════════════════════════════');
    }
}
