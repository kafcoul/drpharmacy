<?php

/**
 * Script pour créer un compte pharmacien via l'API
 * Usage: php scripts/create_pharmacy_account.php
 */

// Configuration de l'API
$apiUrl = 'http://localhost:8000/api/auth/register/pharmacy';

// Données du compte pharmacien à créer
$pharmacyData = [
    // Informations utilisateur
    'name' => 'Dr. Kouadio Jean',
    'email' => 'kouadio.jean@pharmacie.test',
    'phone' => '+225 27 22 00 99 88',
    'password' => 'password',
    'password_confirmation' => 'password',
    
    // Informations pharmacie
    'pharmacy_name' => 'Pharmacie Nouvelle',
    'pharmacy_license' => 'PHARM-CI-2026-050',
    'pharmacy_address' => 'Boulevard Principal, Angré',
    'city' => 'Abidjan',
    'latitude' => 5.3800,
    'longitude' => -4.0200,
    
    // Device
    'device_name' => 'TestDevice'
];

echo "🏥 Création d'un nouveau compte pharmacien...\n";
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";

echo "📋 Informations du compte:\n";
echo "  Nom: {$pharmacyData['name']}\n";
echo "  Email: {$pharmacyData['email']}\n";
echo "  Téléphone: {$pharmacyData['phone']}\n";
echo "  Pharmacie: {$pharmacyData['pharmacy_name']}\n";
echo "  Licence: {$pharmacyData['pharmacy_license']}\n";
echo "  Adresse: {$pharmacyData['pharmacy_address']}, {$pharmacyData['city']}\n";
echo "  Coordonnées: {$pharmacyData['latitude']}, {$pharmacyData['longitude']}\n\n";

// Initialiser cURL
$ch = curl_init($apiUrl);

// Configuration de la requête
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($pharmacyData));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json',
]);

// Exécuter la requête
echo "🔄 Envoi de la requête à l'API...\n";
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";

// Traiter la réponse
if ($error) {
    echo "❌ Erreur cURL: $error\n";
    exit(1);
}

$responseData = json_decode($response, true);

if ($httpCode === 201 || $httpCode === 200) {
    echo "✅ Compte pharmacien créé avec succès!\n\n";
    
    // Debug: afficher la structure de la réponse
    if (!isset($responseData['user']) && !isset($responseData['pharmacy'])) {
        echo "📄 Réponse de l'API:\n";
        echo json_encode($responseData, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";
    }
    
    if (isset($responseData['user'])) {
        echo "📝 Détails du compte:\n";
        echo "  ID Utilisateur: {$responseData['user']['id']}\n";
        echo "  Nom: {$responseData['user']['name']}\n";
        echo "  Email: {$responseData['user']['email']}\n";
        echo "  Rôle: {$responseData['user']['role']}\n\n";
    }
    
    if (isset($responseData['pharmacy'])) {
        echo "🏥 Détails de la pharmacie:\n";
        echo "  ID: {$responseData['pharmacy']['id']}\n";
        echo "  Nom: {$responseData['pharmacy']['name']}\n";
        echo "  Statut: {$responseData['pharmacy']['status']}\n\n";
    }
    
    if (isset($responseData['token'])) {
        echo "🔑 Token d'authentification:\n";
        echo "  {$responseData['token']}\n\n";
    }
    
    echo "⚠️  IMPORTANT:\n";
    echo "  - Le compte a le statut 'pending' et doit être approuvé par un admin\n";
    echo "  - Utilisez le panel admin pour approuver: http://localhost:8000/admin\n";
    echo "  - Email: admin@drpharma.ci\n";
    echo "  - Mot de passe: password\n\n";
    
    echo "🔐 Identifiants de connexion:\n";
    echo "  Email: {$pharmacyData['email']}\n";
    echo "  Mot de passe: {$pharmacyData['password']}\n";
    
} else {
    echo "❌ Erreur lors de la création du compte (HTTP $httpCode)\n\n";
    
    if (isset($responseData['message'])) {
        echo "Message: {$responseData['message']}\n\n";
    }
    
    if (isset($responseData['errors'])) {
        echo "Erreurs de validation:\n";
        foreach ($responseData['errors'] as $field => $messages) {
            echo "  - $field: " . implode(', ', $messages) . "\n";
        }
    } else {
        echo "Réponse complète:\n";
        echo json_encode($responseData, JSON_PRETTY_PRINT) . "\n";
    }
    
    exit(1);
}

echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
echo "✨ Script terminé avec succès!\n";
