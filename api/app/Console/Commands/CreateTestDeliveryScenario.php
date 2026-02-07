<?php

namespace App\Console\Commands;

use App\Models\Courier;
use App\Models\Delivery;
use App\Models\Order;
use App\Models\Pharmacy;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class CreateTestDeliveryScenario extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'test:create-scenario {--email= : Email of the courier to assign (optional)}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Creates a test order and delivery scenario for debugging';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('🚀 Démarrage de la création du scénario de test...');

        // 1. Ensure Dependencies Exist
        $pharmacy = Pharmacy::first();
        if (!$pharmacy) {
            $user = User::factory()->create([
                'role' => 'pharmacy',
                'email' => 'pharmacie@test.com',
                'password' => Hash::make('password'),
            ]);
            $pharmacy = Pharmacy::create([
                'user_id' => $user->id,
                'name' => 'Pharmacie de Test',
                'address' => 'Plateau, Abidjan',
                'phone' => '+225 0101010101',
                'latitude' => 5.326284,
                'longitude' => -4.020476,
            ]);
            $this->info('✅ Pharmacie de test créée.');
        }

        $customer = User::where('role', 'customer')->first();
        if (!$customer) {
            $customer = User::factory()->create([
                'role' => 'customer',
                'email' => 'client@test.com',
                'password' => Hash::make('password'),
                'name' => 'Client Test',
                'phone' => '+225 0707070707',
            ]);
            $this->info('✅ Client de test créé.');
        }

        // 2. Create Order
        $deliveryCode = '1234';
        $order = Order::create([
            'reference' => 'ORD-' . strtoupper(Str::random(6)),
            'customer_id' => $customer->id,
            'pharmacy_id' => $pharmacy->id,
            'status' => 'paid',
            'subtotal' => 14000,
            'total_amount' => 15000,
            'delivery_fee' => 1000,
            'delivery_address' => 'Riviera 2, Cocody, Abidjan',
            'delivery_code' => $deliveryCode,
            'customer_notes' => 'Ceci est une commande de test générée automatiquement.',
            'customer_phone' => $customer->phone ?? '+225 0707070707',
        ]);

        $this->info("✅ Commande créée: {$order->reference}");
        $this->info("🔑 CODE DE LIVRAISON: {$deliveryCode} (Notez-le pour la fin !)");

        // 3. Create Delivery
        $email = $this->option('email');
        $courier = null;

        if ($email) {
            $user = User::where('email', $email)->first();
            if ($user && $user->courier) {
                $courier = $user->courier;
            } else {
                $this->error("Livreur avec l'email {$email} introuvable.");
            }
        }

        $deliveryData = [
            'order_id' => $order->id,
            'pickup_address' => $pharmacy->address,
            'pickup_latitude' => $pharmacy->latitude,
            'pickup_longitude' => $pharmacy->longitude,
            'delivery_address' => $order->delivery_address,
            'dropoff_latitude' => 5.352985, // Riviera 2 approx
            'dropoff_longitude' => -3.968038,
            'estimated_distance' => 5.2,
            'estimated_duration' => 15,
        ];

        if ($courier) {
            $deliveryData['courier_id'] = $courier->id;
            $deliveryData['status'] = 'assigned';
            $delivery = Delivery::create($deliveryData);
            $this->info("✅ Livraison assignée directement à {$courier->user->name}.");
            
            // Ensure wallet has funds
            $wallet = Wallet::firstOrCreate(
                ['walletable_type' => Courier::class, 'walletable_id' => $courier->id],
                ['balance' => 0, 'currency' => 'XOF']
            );
            
             if ($wallet->balance < 200) {
                $wallet->balance = 5000;
                $wallet->save();
                $this->info("💰 Portefeuille rechargé à 5000 FCFA pour permettre la commission.");
            } else {
                $this->info("💰 Solde actuel: {$wallet->balance} FCFA (Suffisant).");
            }

        } else {
            $deliveryData['status'] = 'pending';
            $delivery = Delivery::create($deliveryData);
            $this->info("✅ Livraison publiée sur le marché (En attente d'acceptation).");
            $this->info("ℹ️  Ouvrez l'appli et allez dans 'Nouvelles Livraisons' pour l'accepter.");
        }

        $this->newLine();
        $this->info('=== SCÉNARIO PRÊT ===');
        $this->info('1. Acceptez la livraison (si pas déjà fait).');
        $this->info('2. Cliquez sur "Récupérer le colis".');
        $this->info('3. Cliquez sur "Terminer la livraison".');
        $this->info("4. Entrez le code: {$deliveryCode}");
        $this->info('5. Vérifiez que votre solde diminue de 200 FCFA et augmente de 1000 FCFA.');
    }
}
