<?php
$email = 'pharmacie@test.com';
$phone = '0102030405';

// Nettoyage préalable (incluant Soft Deletes si activé)
$u = \App\Models\User::withTrashed()->where('email', $email)->orWhere('phone', $phone)->get();
foreach($u as $user) { 
    $user->tokens()->delete();
    $user->forceDelete(); 
}

$p = \App\Models\Pharmacy::withTrashed()->where('email', $email)->orWhere('phone', $phone)->get();
foreach($p as $pharmacy) { 
    $pharmacy->users()->detach(); 
    $pharmacy->forceDelete(); 
}

echo "Anciennes données nettoyées (y compris corbeille)...\n";

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
