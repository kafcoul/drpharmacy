<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\User;
use App\Models\Pharmacy;
use App\Models\Wallet;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

echo "=== Création du compte pharmacie complet ===\n\n";

try {
    DB::beginTransaction();

    // Vérifier si l'utilisateur existe déjà
    $existingUser = User::where('email', 'pharmacie@test.com')->first();
    if ($existingUser) {
        echo "⚠️  L'utilisateur pharmacie@test.com existe déjà. Suppression...\n";
        // Supprimer les entités liées
        $pharmacy = Pharmacy::where('user_id', $existingUser->id)->first();
        if ($pharmacy) {
            Wallet::where('walletable_id', $pharmacy->id)->where('walletable_type', 'App\Models\Pharmacy')->delete();
            $pharmacy->forceDelete();
        }
        $existingUser->forceDelete();
        echo "✅ Ancien compte supprimé.\n\n";
    }

    // 1. Créer l'utilisateur
    echo "1. Création de l'utilisateur pharmacien...\n";
    $user = new User();
    $user->name = 'Dr. Kouassi Jean';
    $user->email = 'pharmacie@test.com';
    $user->phone = '+2250701234567';
    $user->password = Hash::make('password123');
    $user->role = 'pharmacy';
    $user->email_verified_at = now();
    $user->phone_verified_at = now();
    $user->save();

    echo "   ✓ ID: {$user->id}\n";
    echo "   ✓ Nom: {$user->name}\n";
    echo "   ✓ Email: {$user->email}\n\n";

    // 2. Créer la pharmacie
    echo "2. Création de la pharmacie...\n";
    $pharmacy = new Pharmacy();
    $pharmacy->name = 'Pharmacie du Plateau';
    $pharmacy->phone = '+2250701234567';
    $pharmacy->email = 'pharmacie@test.com';
    $pharmacy->address = 'Avenue Terrasson de Fougères, Plateau';
    $pharmacy->city = 'Abidjan';
    $pharmacy->latitude = 5.3364;
    $pharmacy->longitude = -4.0266;
    $pharmacy->status = 'approved';
    $pharmacy->is_active = true;
    $pharmacy->is_featured = true;
    $pharmacy->license_number = 'LIC-CI-2024-12345';
    $pharmacy->owner_name = 'Dr. Kouassi Jean';
    $pharmacy->approved_at = now();
    $pharmacy->commission_rate_platform = 0.05;
    $pharmacy->commission_rate_pharmacy = 0.85;
    $pharmacy->commission_rate_courier = 0.10;
    $pharmacy->save();

    echo "   ✓ ID: {$pharmacy->id}\n";
    echo "   ✓ Nom: {$pharmacy->name}\n";
    echo "   ✓ Statut: {$pharmacy->status}\n";
    echo "   ✓ Active: Oui\n\n";

    // 3. Lier l'utilisateur à la pharmacie via la table pivot
    echo "3. Liaison utilisateur-pharmacie...\n";
    $pharmacy->users()->attach($user->id, ['role' => 'owner']);
    echo "   ✓ Utilisateur lié comme propriétaire\n\n";

    // 4. Créer le wallet
    echo "4. Création du wallet...\n";
    $wallet = new Wallet();
    $wallet->walletable_type = 'App\Models\Pharmacy';
    $wallet->walletable_id = $pharmacy->id;
    $wallet->balance = 150000;
    $wallet->currency = 'XOF';
    $wallet->save();

    echo "   ✓ Balance: 150,000 XOF\n\n";

    DB::commit();

    echo "===========================================\n";
    echo "🎉 COMPTE PHARMACIE CRÉÉ AVEC SUCCÈS !\n";
    echo "===========================================\n\n";
    echo "📧 Email: pharmacie@test.com\n";
    echo "🔑 Mot de passe: password123\n";
    echo "🏪 Pharmacie: {$pharmacy->name}\n";
    echo "💰 Balance: 150,000 XOF\n";
    echo "===========================================\n";

} catch (\Exception $e) {
    DB::rollBack();
    echo "\n❌ ERREUR: " . $e->getMessage() . "\n";
    echo "Fichier: " . $e->getFile() . "\n";
    echo "Ligne: " . $e->getLine() . "\n";
}
