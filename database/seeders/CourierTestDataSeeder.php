<?php

namespace Database\Seeders;

use App\Models\Challenge;
use App\Models\Courier;
use App\Models\CourierChallenge;
use App\Models\Delivery;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Pharmacy;
use App\Models\Product;
use App\Models\User;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * Seeder pour créer des données de test complètes pour l'application Coursier
 * 
 * Ce seeder crée:
 * - Un livreur de test avec compte complet
 * - Historique de livraisons (passées et en cours)
 * - Progression sur les défis (actifs et terminés)
 * - Wallet avec solde et historique de transactions
 */
class CourierTestDataSeeder extends Seeder
{
    private Courier $testCourier;
    private User $testUser;
    private Pharmacy $testPharmacy;
    private User $testCustomer;

    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $this->command->info('🚀 Création des données de test pour l\'application Coursier...');

        DB::transaction(function () {
            $this->createTestCourier();
            $this->createTestCustomer();
            $this->seedDeliveryHistory();
            $this->seedChallengesProgress();
            $this->seedWalletWithTransactions();
        });

        $this->command->info('✅ Données de test créées avec succès!');
        $this->command->newLine();
        $this->command->info('📱 Compte de test Coursier:');
        $this->command->info("   Email: test.courier@drpharma.ci");
        $this->command->info("   Mot de passe: password123");
        $this->command->info("   Solde Wallet: {$this->testCourier->wallet->balance} FCFA");
    }

    /**
     * Créer le livreur de test principal
     */
    private function createTestCourier(): void
    {
        $this->command->info('👤 Création du livreur de test...');

        // Créer l'utilisateur
        $this->testUser = User::firstOrCreate(
            ['email' => 'test.courier@drpharma.ci'],
            [
                'name' => 'Jean-Paul Kouamé',
                'phone' => '+225 07 99 88 77 66',
                'password' => Hash::make('password123'),
                'role' => 'courier',
                'email_verified_at' => now(),
            ]
        );

        // Créer ou récupérer le profil courier
        $this->testCourier = Courier::firstOrCreate(
            ['user_id' => $this->testUser->id],
            [
                'name' => 'Jean-Paul Kouamé',
                'phone' => '+225 07 99 88 77 66',
                'vehicle_type' => 'moto',
                'vehicle_number' => 'TEST-1234-CI',
                'license_number' => 'DL-CI-123456',
                'latitude' => 5.3600,
                'longitude' => -4.0083,
                'status' => 'available',
                'kyc_status' => 'approved',
                'kyc_verified_at' => now()->subDays(30),
                'rating' => 4.8,
                'completed_deliveries' => 0, // Sera mis à jour par le seeder
            ]
        );

        // S'assurer que la pharmacie de test existe
        $this->testPharmacy = Pharmacy::where('status', 'approved')->first();
        if (!$this->testPharmacy) {
            $this->testPharmacy = Pharmacy::first();
        }
    }

    /**
     * Créer un client de test
     */
    private function createTestCustomer(): void
    {
        $this->testCustomer = User::firstOrCreate(
            ['email' => 'test.customer@drpharma.ci'],
            [
                'name' => 'Marie Bamba',
                'phone' => '+225 05 11 22 33 44',
                'password' => Hash::make('password123'),
                'role' => 'customer',
                'email_verified_at' => now(),
            ]
        );
    }

    /**
     * Créer l'historique des livraisons
     */
    private function seedDeliveryHistory(): void
    {
        $this->command->info('📦 Création de l\'historique des livraisons...');

        // Adresses de livraison à Abidjan
        $deliveryAddresses = [
            ['address' => 'Cocody Riviera 2, Abidjan', 'lat' => 5.3599, 'lng' => -4.0083],
            ['address' => 'Plateau, Rue du Commerce, Abidjan', 'lat' => 5.3200, 'lng' => -4.0200],
            ['address' => 'Marcory Zone 4C, Abidjan', 'lat' => 5.3000, 'lng' => -4.0000],
            ['address' => 'Yopougon Sideci, Abidjan', 'lat' => 5.3500, 'lng' => -4.0900],
            ['address' => 'Treichville Gare du Sud, Abidjan', 'lat' => 5.3050, 'lng' => -4.0100],
            ['address' => 'Adjamé Liberté, Abidjan', 'lat' => 5.3400, 'lng' => -4.0200],
            ['address' => 'Abobo Gare, Abidjan', 'lat' => 5.4200, 'lng' => -4.0200],
            ['address' => 'Port-Bouët Vridi, Abidjan', 'lat' => 5.2600, 'lng' => -4.0100],
            ['address' => 'Koumassi Remblais, Abidjan', 'lat' => 5.2900, 'lng' => -3.9600],
            ['address' => 'Bingerville Centre, Abidjan', 'lat' => 5.3550, 'lng' => -3.8900],
        ];

        // === LIVRAISONS LIVRÉES (Historique) ===
        $this->command->info('   - Création de 25 livraisons passées...');
        
        for ($i = 0; $i < 25; $i++) {
            $daysAgo = rand(1, 60);
            $deliveredAt = now()->subDays($daysAgo)->subHours(rand(0, 12));
            $addr = $deliveryAddresses[array_rand($deliveryAddresses)];
            $deliveryFee = rand(5, 15) * 100; // 500 à 1500 FCFA

            $order = $this->createOrder(
                status: 'delivered',
                deliveryFee: $deliveryFee,
                address: $addr,
                createdAt: $deliveredAt->copy()->subHours(rand(1, 3))
            );

            Delivery::create([
                'order_id' => $order->id,
                'courier_id' => $this->testCourier->id,
                'status' => 'delivered',
                'pickup_address' => $this->testPharmacy->address ?? 'Pharmacie Centrale',
                'pickup_latitude' => $this->testPharmacy->latitude ?? 5.3200,
                'pickup_longitude' => $this->testPharmacy->longitude ?? -4.0100,
                'delivery_address' => $addr['address'],
                'delivery_latitude' => $addr['lat'],
                'delivery_longitude' => $addr['lng'],
                'delivery_fee' => $deliveryFee,
                'estimated_distance' => rand(2, 15) + (rand(0, 9) / 10),
                'estimated_duration' => rand(10, 45),
                'assigned_at' => $deliveredAt->copy()->subMinutes(rand(30, 60)),
                'accepted_at' => $deliveredAt->copy()->subMinutes(rand(25, 55)),
                'picked_up_at' => $deliveredAt->copy()->subMinutes(rand(10, 30)),
                'delivered_at' => $deliveredAt,
                'created_at' => $deliveredAt->copy()->subHours(rand(1, 2)),
            ]);
        }

        // === LIVRAISONS EN COURS ===
        $this->command->info('   - Création de 3 livraisons en cours...');

        // 1. Livraison assignée (en attente d'acceptation)
        $addr1 = $deliveryAddresses[0];
        $order1 = $this->createOrder(
            status: 'confirmed',
            deliveryFee: 1000,
            address: $addr1,
            createdAt: now()->subMinutes(10)
        );
        
        Delivery::create([
            'order_id' => $order1->id,
            'courier_id' => $this->testCourier->id,
            'status' => 'assigned',
            'pickup_address' => $this->testPharmacy->address ?? 'Pharmacie Centrale',
            'pickup_latitude' => $this->testPharmacy->latitude ?? 5.3200,
            'pickup_longitude' => $this->testPharmacy->longitude ?? -4.0100,
            'delivery_address' => $addr1['address'],
            'delivery_latitude' => $addr1['lat'],
            'delivery_longitude' => $addr1['lng'],
            'delivery_fee' => 1000,
            'estimated_distance' => 5.2,
            'estimated_duration' => 18,
            'assigned_at' => now()->subMinutes(5),
        ]);

        // 2. Livraison acceptée (en route vers pharmacie)
        $addr2 = $deliveryAddresses[1];
        $order2 = $this->createOrder(
            status: 'confirmed',
            deliveryFee: 1200,
            address: $addr2,
            createdAt: now()->subMinutes(25)
        );
        
        Delivery::create([
            'order_id' => $order2->id,
            'courier_id' => $this->testCourier->id,
            'status' => 'accepted',
            'pickup_address' => $this->testPharmacy->address ?? 'Pharmacie Centrale',
            'pickup_latitude' => $this->testPharmacy->latitude ?? 5.3200,
            'pickup_longitude' => $this->testPharmacy->longitude ?? -4.0100,
            'delivery_address' => $addr2['address'],
            'delivery_latitude' => $addr2['lat'],
            'delivery_longitude' => $addr2['lng'],
            'delivery_fee' => 1200,
            'estimated_distance' => 7.8,
            'estimated_duration' => 25,
            'assigned_at' => now()->subMinutes(20),
            'accepted_at' => now()->subMinutes(18),
        ]);

        // 3. Livraison en transit (colis récupéré)
        $addr3 = $deliveryAddresses[2];
        $order3 = $this->createOrder(
            status: 'confirmed',
            deliveryFee: 800,
            address: $addr3,
            createdAt: now()->subMinutes(45)
        );
        
        Delivery::create([
            'order_id' => $order3->id,
            'courier_id' => $this->testCourier->id,
            'status' => 'picked_up',
            'pickup_address' => $this->testPharmacy->address ?? 'Pharmacie Centrale',
            'pickup_latitude' => $this->testPharmacy->latitude ?? 5.3200,
            'pickup_longitude' => $this->testPharmacy->longitude ?? -4.0100,
            'delivery_address' => $addr3['address'],
            'delivery_latitude' => $addr3['lat'],
            'delivery_longitude' => $addr3['lng'],
            'delivery_fee' => 800,
            'estimated_distance' => 3.5,
            'estimated_duration' => 12,
            'assigned_at' => now()->subMinutes(40),
            'accepted_at' => now()->subMinutes(38),
            'picked_up_at' => now()->subMinutes(15),
        ]);

        // === LIVRAISONS ANNULÉES (quelques-unes) ===
        $this->command->info('   - Création de 3 livraisons annulées...');
        
        for ($i = 0; $i < 3; $i++) {
            $daysAgo = rand(5, 30);
            $cancelledAt = now()->subDays($daysAgo);
            $addr = $deliveryAddresses[array_rand($deliveryAddresses)];

            $order = $this->createOrder(
                status: 'cancelled',
                deliveryFee: rand(5, 10) * 100,
                address: $addr,
                createdAt: $cancelledAt->copy()->subHours(1)
            );

            Delivery::create([
                'order_id' => $order->id,
                'courier_id' => $this->testCourier->id,
                'status' => 'cancelled',
                'pickup_address' => $this->testPharmacy->address ?? 'Pharmacie Centrale',
                'pickup_latitude' => $this->testPharmacy->latitude ?? 5.3200,
                'pickup_longitude' => $this->testPharmacy->longitude ?? -4.0100,
                'delivery_address' => $addr['address'],
                'delivery_latitude' => $addr['lat'],
                'delivery_longitude' => $addr['lng'],
                'delivery_fee' => rand(5, 10) * 100,
                'assigned_at' => $cancelledAt->copy()->subMinutes(30),
                'accepted_at' => $i % 2 == 0 ? $cancelledAt->copy()->subMinutes(25) : null,
                'cancellation_reason' => ['Client injoignable', 'Adresse incorrecte', 'Client a annulé'][rand(0, 2)],
                'created_at' => $cancelledAt->copy()->subHours(1),
            ]);
        }

        // Mettre à jour le compteur de livraisons
        $completedCount = Delivery::where('courier_id', $this->testCourier->id)
            ->where('status', 'delivered')
            ->count();
        
        $this->testCourier->update(['completed_deliveries' => $completedCount]);
        
        $this->command->info("   ✓ {$completedCount} livraisons livrées, 3 en cours, 3 annulées");
    }

    /**
     * Créer une commande pour une livraison
     */
    private function createOrder(string $status, int $deliveryFee, array $address, Carbon $createdAt): Order
    {
        $subtotal = rand(20, 150) * 100; // 2000 à 15000 FCFA

        $order = Order::create([
            'reference' => 'ORD-' . strtoupper(Str::random(8)),
            'pharmacy_id' => $this->testPharmacy->id,
            'customer_id' => $this->testCustomer->id,
            'status' => $status,
            'delivery_code' => str_pad(mt_rand(0, 9999), 4, '0', STR_PAD_LEFT),
            'payment_mode' => ['cash', 'mobile_money'][rand(0, 1)],
            'subtotal' => $subtotal,
            'delivery_fee' => $deliveryFee,
            'total_amount' => $subtotal + $deliveryFee,
            'currency' => 'XOF',
            'delivery_address' => $address['address'],
            'delivery_latitude' => $address['lat'],
            'delivery_longitude' => $address['lng'],
            'customer_phone' => $this->testCustomer->phone,
            'confirmed_at' => $createdAt,
            'paid_at' => $status === 'delivered' ? $createdAt->copy()->addMinutes(rand(30, 90)) : null,
            'delivered_at' => $status === 'delivered' ? $createdAt->copy()->addMinutes(rand(30, 90)) : null,
            'created_at' => $createdAt,
        ]);

        // Ajouter quelques items à la commande
        $product = Product::inRandomOrder()->first();
        if ($product) {
            $qty = rand(1, 3);
            $unitPrice = $product->price ?? rand(1000, 5000);
            OrderItem::create([
                'order_id' => $order->id,
                'product_id' => $product->id,
                'product_name' => $product->name,
                'product_sku' => $product->sku ?? 'SKU-' . $product->id,
                'quantity' => $qty,
                'unit_price' => $unitPrice,
                'total_price' => $unitPrice * $qty,
            ]);
        }

        return $order;
    }

    /**
     * Créer la progression sur les défis
     */
    private function seedChallengesProgress(): void
    {
        $this->command->info('🏆 Création de la progression des défis...');

        $challenges = Challenge::all();
        
        if ($challenges->isEmpty()) {
            $this->command->warn('   ⚠ Aucun défi trouvé. Exécutez ChallengeSeeder d\'abord.');
            return;
        }

        $completedCount = 0;
        $inProgressCount = 0;

        foreach ($challenges as $challenge) {
            // Supprimer les anciennes progressions pour ce courier
            CourierChallenge::where('courier_id', $this->testCourier->id)
                ->where('challenge_id', $challenge->id)
                ->delete();

            // Déterminer le statut aléatoire
            $progressType = rand(1, 10);
            
            if ($progressType <= 3) {
                // 30% - Défi complété et récompensé
                $startedAt = now()->subDays(rand(1, 30));
                $completedAt = $startedAt->copy()->addHours(rand(2, 48));
                
                CourierChallenge::create([
                    'courier_id' => $this->testCourier->id,
                    'challenge_id' => $challenge->id,
                    'current_progress' => $challenge->target_value,
                    'status' => 'rewarded',
                    'started_at' => $startedAt,
                    'completed_at' => $completedAt,
                    'rewarded_at' => $completedAt->copy()->addMinutes(rand(1, 60)),
                ]);
                $completedCount++;
                
            } elseif ($progressType <= 5) {
                // 20% - Défi complété mais pas encore récompensé
                $startedAt = now()->subDays(rand(1, 7));
                
                CourierChallenge::create([
                    'courier_id' => $this->testCourier->id,
                    'challenge_id' => $challenge->id,
                    'current_progress' => $challenge->target_value,
                    'status' => 'completed',
                    'started_at' => $startedAt,
                    'completed_at' => now()->subHours(rand(1, 24)),
                ]);
                $completedCount++;
                
            } elseif ($progressType <= 8) {
                // 30% - Défi en cours avec progression partielle
                $progress = rand(1, $challenge->target_value - 1);
                
                CourierChallenge::create([
                    'courier_id' => $this->testCourier->id,
                    'challenge_id' => $challenge->id,
                    'current_progress' => $progress,
                    'status' => 'in_progress',
                    'started_at' => now()->subDays(rand(0, 3)),
                ]);
                $inProgressCount++;
                
            } else {
                // 20% - Défi pas encore commencé (on ne crée pas d'entrée)
            }
        }

        $this->command->info("   ✓ {$completedCount} défis complétés, {$inProgressCount} en cours");
    }

    /**
     * Créer le wallet avec historique de transactions
     */
    private function seedWalletWithTransactions(): void
    {
        $this->command->info('💰 Création du portefeuille et des transactions...');

        // Créer ou récupérer le wallet
        $wallet = Wallet::firstOrCreate(
            [
                'walletable_type' => Courier::class,
                'walletable_id' => $this->testCourier->id,
            ],
            [
                'balance' => 0,
                'currency' => 'XOF',
            ]
        );

        // Supprimer les anciennes transactions de test
        WalletTransaction::where('wallet_id', $wallet->id)->delete();
        $wallet->update(['balance' => 0]);

        $runningBalance = 0;
        $transactions = [];

        // === TRANSACTIONS DES 60 DERNIERS JOURS ===
        
        // 1. Gains de livraisons (commissions)
        $this->command->info('   - Création des gains de livraison...');
        
        $deliveries = Delivery::with('order')
            ->where('courier_id', $this->testCourier->id)
            ->where('status', 'delivered')
            ->orderBy('delivered_at')
            ->get();

        foreach ($deliveries as $delivery) {
            // Commission livreur = 70% du delivery_fee (typiquement)
            $commission = (int) ($delivery->delivery_fee * 0.70);
            $runningBalance += $commission;

            $transactions[] = [
                'wallet_id' => $wallet->id,
                'type' => 'CREDIT',
                'amount' => $commission,
                'balance_after' => $runningBalance,
                'reference' => 'DEL-' . $delivery->id,
                'description' => 'Commission livraison #' . ($delivery->order?->reference ?? 'N/A'),
                'category' => 'delivery_commission',
                'delivery_id' => $delivery->id,
                'status' => 'completed',
                'created_at' => $delivery->delivered_at,
                'updated_at' => $delivery->delivered_at,
            ];
        }

        // 2. Bonus de défis complétés
        $this->command->info('   - Création des bonus de défis...');
        
        $rewardedChallenges = CourierChallenge::where('courier_id', $this->testCourier->id)
            ->where('status', 'rewarded')
            ->with('challenge')
            ->get();

        foreach ($rewardedChallenges as $cc) {
            $bonus = $cc->challenge->reward_amount;
            $runningBalance += $bonus;

            $transactions[] = [
                'wallet_id' => $wallet->id,
                'type' => 'CREDIT',
                'amount' => $bonus,
                'balance_after' => $runningBalance,
                'reference' => 'BONUS-' . $cc->id,
                'description' => 'Bonus défi: ' . $cc->challenge->title,
                'category' => 'challenge_bonus',
                'status' => 'completed',
                'created_at' => $cc->rewarded_at,
                'updated_at' => $cc->rewarded_at,
            ];
        }

        // 3. Quelques retraits passés
        $this->command->info('   - Création des retraits...');
        
        $withdrawalDates = [
            now()->subDays(45),
            now()->subDays(30),
            now()->subDays(15),
        ];

        foreach ($withdrawalDates as $date) {
            // Retrait de 30-50% du solde actuel à cette date
            $withdrawAmount = min((int) ($runningBalance * (rand(30, 50) / 100)), $runningBalance - 5000);
            
            if ($withdrawAmount >= 5000) { // Minimum 5000 FCFA pour un retrait
                $runningBalance -= $withdrawAmount;

                $transactions[] = [
                    'wallet_id' => $wallet->id,
                    'type' => 'DEBIT',
                    'amount' => $withdrawAmount,
                    'balance_after' => $runningBalance,
                    'reference' => 'WDR-' . strtoupper(Str::random(8)),
                    'description' => 'Retrait Mobile Money',
                    'category' => 'withdrawal',
                    'status' => 'completed',
                    'metadata' => json_encode([
                        'method' => ['orange_money', 'mtn_money', 'wave'][rand(0, 2)],
                        'phone' => $this->testCourier->phone,
                    ]),
                    'created_at' => $date,
                    'updated_at' => $date,
                ];
            }
        }

        // 4. Un retrait en attente (récent)
        $pendingWithdraw = min(10000, (int) ($runningBalance * 0.3));
        if ($pendingWithdraw >= 5000) {
            $transactions[] = [
                'wallet_id' => $wallet->id,
                'type' => 'DEBIT',
                'amount' => $pendingWithdraw,
                'balance_after' => $runningBalance - $pendingWithdraw,
                'reference' => 'WDR-PENDING-' . strtoupper(Str::random(6)),
                'description' => 'Retrait en cours de traitement',
                'category' => 'withdrawal',
                'status' => 'pending',
                'metadata' => json_encode([
                    'method' => 'orange_money',
                    'phone' => $this->testCourier->phone,
                ]),
                'created_at' => now()->subHours(2),
                'updated_at' => now()->subHours(2),
            ];
            // Note: On ne déduit pas du balance car le retrait est pending
        }

        // Trier les transactions par date et recalculer les balances
        usort($transactions, fn($a, $b) => $a['created_at'] <=> $b['created_at']);
        
        $recalculatedBalance = 0;
        foreach ($transactions as &$tx) {
            if ($tx['type'] === 'CREDIT') {
                $recalculatedBalance += $tx['amount'];
            } else {
                if ($tx['status'] === 'completed') {
                    $recalculatedBalance -= $tx['amount'];
                }
            }
            $tx['balance_after'] = $recalculatedBalance;
        }

        // Insérer toutes les transactions
        foreach ($transactions as $tx) {
            WalletTransaction::create($tx);
        }

        // Mettre à jour le solde final du wallet
        $wallet->update(['balance' => $recalculatedBalance]);

        $creditCount = count(array_filter($transactions, fn($t) => $t['type'] === 'CREDIT'));
        $debitCount = count(array_filter($transactions, fn($t) => $t['type'] === 'DEBIT'));

        $this->command->info("   ✓ Solde final: {$recalculatedBalance} FCFA");
        $this->command->info("   ✓ {$creditCount} crédits, {$debitCount} débits");
    }
}
