<?php
$email = 'pharmacie@test.com';
$phone = '0102030405';

// Nettoyage préalable (SANS withTrashed pour User si non supporté, mais forcé sur Pharmacy si besoin)
// En fait, User n'utilise peut-être pas SoftDeletes, alors on fait un delete simple qui devrait suffire.
// Mais pour Pharmacy on a vu softDeletes dans la migration!

$u = \App\Models\User::where('email', $email)->orWhere('phone', $phone)->get();
foreach($u as $user) { 
    $user->tokens()->delete();
    $user->delete(); 
}

// Pour Pharmacy, on vérifie si la méthode existe, sinon delete simple
try {
    $p = \App\Models\Pharmacy::withTrashed()->where('email', $email)->orWhere('phone', $phone)->get();
    foreach($p as $pharmacy) { 
        $pharmacy->users()->detach(); 
        $pharmacy->forceDelete(); 
    }
} catch (\Exception $e) {
    // Fallback si withTrashed n'existe pas (mauvaise config model)
    $p = \App\Models\Pharmacy::where('email', $email)->orWhere('phone', $phone)->get();
    foreach($p as $pharmacy) { 
        $pharmacy->users()->detach(); 
        $pharmacy->delete(); 
    }
}


echo "Anciennes données nettoyées...\n";

// Création User
$user = \App\Models\User::create([
    'name' => 'Dr Teya',
    'email' => $email,
    'phone' => $phone,
    'password' => Illuminate\Support\Facades\Hash::make('password123'),
    'role' => 'pharmacy'
]);

echo "Utilisateur créé (ID: {$user->id})...\n";

// Création Pharmacie
$pharmacy = \App\Models\Pharmacy::create([
    'name' => 'Pharmacie de la Grace',
    'phone' => $phone,
    'email' => $email,
    'address' => 'Cocody Riviera 2',
    'city' => 'Abidjan',
    'license_number' => 'LIC-2024-TEYA',
    'owner_name' => 'Dr Teya',
    'status' => 'approved', 
]);

echo "Pharmacie créée (ID: {$pharmacy->id})...\n";

// Liaison
$pharmacy->users()->attach($user->id, ['role' => 'owner']);

echo "Comptes liés avec succès !\n";
echo "--------------------------------\n";
echo "Email: $email\n";
echo "Mot de passe: password123\n";
