<?php

/**
 * Script de test rapide pour vérifier les problèmes potentiels avec PrescriptionController
 * 
 * Usage: php test_prescription.php
 */

require_once __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\User;
use App\Models\Prescription;

echo "=== TEST PRESCRIPTION CONTROLLER ===\n\n";

// Test 1: Vérifier que User n'a pas de méthode roles()
echo "1. Test: User model n'a pas de relation roles()...\n";
$user = new User();
if (method_exists($user, 'roles')) {
    echo "   ❌ ERREUR: User a une méthode roles() qui ne devrait pas exister!\n";
    echo "   Solution: Supprimer la méthode roles() du modèle User ou utiliser ->role (colonne string)\n";
} else {
    echo "   ✅ OK: User n'a pas de méthode roles()\n";
}

// Test 2: Vérifier la colonne role existe dans User
echo "\n2. Test: User a une colonne 'role'...\n";
try {
    $schema = \Illuminate\Support\Facades\Schema::getColumnListing('users');
    if (in_array('role', $schema)) {
        echo "   ✅ OK: Colonne 'role' existe dans la table users\n";
    } else {
        echo "   ❌ ERREUR: Colonne 'role' n'existe pas!\n";
    }
} catch (\Exception $e) {
    echo "   ⚠️  Impossible de vérifier: " . $e->getMessage() . "\n";
}

// Test 3: Récupérer les utilisateurs pharmacy par role
echo "\n3. Test: Récupération des utilisateurs pharmacy...\n";
try {
    $pharmacyUsers = User::where('role', 'pharmacy')->get();
    echo "   ✅ OK: " . count($pharmacyUsers) . " utilisateur(s) pharmacy trouvé(s)\n";
} catch (\Exception $e) {
    echo "   ❌ ERREUR: " . $e->getMessage() . "\n";
}

// Test 4: Vérifier le code du PrescriptionController
echo "\n4. Test: Vérification du code PrescriptionController...\n";
$controllerPath = __DIR__ . '/app/Http/Controllers/Api/Customer/PrescriptionController.php';
if (file_exists($controllerPath)) {
    $content = file_get_contents($controllerPath);
    
    // Check for problematic code patterns
    $problems = [];
    
    if (preg_match('/whereHas\s*\(\s*[\'"]roles[\'"]/i', $content)) {
        $problems[] = "whereHas('roles'...) - User n'a pas de relation roles()";
    }
    
    if (preg_match('/->roles\s*\(\s*\)/i', $content)) {
        $problems[] = "->roles() - User n'a pas de relation roles()";
    }
    
    if (preg_match('/hasRole\s*\(/i', $content)) {
        $problems[] = "hasRole() - Méthode non définie sur User";
    }
    
    if (empty($problems)) {
        echo "   ✅ OK: Aucun pattern problématique trouvé\n";
        
        // Vérifier le bon pattern
        if (preg_match('/User::where\s*\(\s*[\'"]role[\'"]\s*,\s*[\'"]pharmacy[\'"]\s*\)/', $content)) {
            echo "   ✅ OK: Utilise correctement User::where('role', 'pharmacy')\n";
        }
    } else {
        echo "   ❌ ERREURS TROUVÉES:\n";
        foreach ($problems as $problem) {
            echo "      - $problem\n";
        }
    }
} else {
    echo "   ⚠️  Fichier non trouvé: $controllerPath\n";
}

// Test 5: Vérifier les notifications
echo "\n5. Test: Classe NewPrescriptionNotification...\n";
$notifPath = __DIR__ . '/app/Notifications/NewPrescriptionNotification.php';
if (file_exists($notifPath)) {
    echo "   ✅ OK: NewPrescriptionNotification existe\n";
} else {
    echo "   ❌ ERREUR: NewPrescriptionNotification n'existe pas!\n";
    echo "   Solution: Créer la notification avec php artisan make:notification NewPrescriptionNotification\n";
}

// Test 6: Vérifier la relation prescriptions() sur User
echo "\n6. Test: User->prescriptions() relation...\n";
if (method_exists($user, 'prescriptions')) {
    echo "   ✅ OK: User a la relation prescriptions()\n";
} else {
    echo "   ❌ ERREUR: User n'a pas de relation prescriptions()!\n";
}

// Test 7: Test de création de prescription (dry run)
echo "\n7. Test: Simulation création prescription...\n";
try {
    // Trouver ou créer un utilisateur de test
    $testUser = User::where('role', 'customer')->first();
    if ($testUser) {
        echo "   ✅ OK: Utilisateur customer trouvé (ID: {$testUser->id})\n";
        
        // Vérifier qu'on peut accéder aux prescriptions
        $count = $testUser->prescriptions()->count();
        echo "   ✅ OK: L'utilisateur a $count prescription(s)\n";
    } else {
        echo "   ⚠️  Aucun utilisateur customer trouvé pour tester\n";
    }
} catch (\Exception $e) {
    echo "   ❌ ERREUR: " . $e->getMessage() . "\n";
}

echo "\n=== FIN DES TESTS ===\n";
echo "\nSi tous les tests passent mais l'erreur persiste sur un autre serveur,\n";
echo "cela signifie que le code n'est pas synchronisé. Faire un git pull.\n";
