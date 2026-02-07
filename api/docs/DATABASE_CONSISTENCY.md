# Cohérence Migrations, Modèles et Seeders

Ce document résume les corrections apportées pour assurer la cohérence entre les migrations de base de données, les modèles Eloquent et les seeders.

## Date de mise à jour : 3 février 2026

## ✅ État actuel : COHÉRENT

Tous les seeders fonctionnent correctement et les données sont créées sans erreur.

### Données créées par les seeders :
- Users: 13
- Pharmacies: 3
- Couriers: 3
- Categories: 7
- Products: 48
- Settings: 14
- Wallets: 6

---

## 1. Table `pharmacies`

### Migration (`2024_01_01_000008_create_pharmacies_table.php`)
```php
$table->string('status')->default('pending');  // pending, approved, rejected
$table->decimal('commission_rate_platform', 5, 2)->default(0.10);
$table->decimal('commission_rate_pharmacy', 5, 2)->default(0.85);
$table->decimal('commission_rate_courier', 5, 2)->default(0.05);
$table->boolean('is_featured')->default(false);
```

### Migration ajoutée (`2026_02_03_000001_add_is_active_to_pharmacies_table.php`)
```php
$table->boolean('is_active')->default(true)->after('status');
```

### Modèle (`app/Models/Pharmacy.php`)
```php
protected $fillable = [
    // ... autres champs
    'status',
    'is_active',  // AJOUTÉ
    'is_featured',
    'commission_rate_platform',
    'commission_rate_pharmacy',
    'commission_rate_courier',
];

protected $casts = [
    'is_active' => 'boolean',  // AJOUTÉ
    'is_featured' => 'boolean',
];
```

### Factory (`database/factories/PharmacyFactory.php`)
```php
'status' => 'approved',
'is_active' => true,  // AJOUTÉ
```

### Seeder (`database/seeders/PharmacySeeder.php`)
- ✅ Corrigé : Utilise `status` au lieu de `is_active` et `is_verified`
- ✅ Corrigé : Wallet polymorphique (`walletable_type`, `walletable_id`)

---

## 2. Table `couriers`

### Migration (`2024_01_01_000011_create_couriers_table.php`)
```php
$table->string('vehicle_number')->nullable();  // PAS vehicle_plate
$table->enum('status', ['available', 'busy', 'offline', 'suspended', 'pending_approval']);
$table->integer('completed_deliveries')->default(0);  // PAS total_deliveries
```

### Seeder (`database/seeders/CourierSeeder.php`)
- ✅ Corrigé : `vehicle_plate` → `vehicle_number`
- ✅ Corrigé : `is_active/is_available/is_verified` → `status`
- ✅ Corrigé : `total_deliveries` → `completed_deliveries`
- ✅ Corrigé : Wallet polymorphique

---

## 3. Table `categories`

### Migration (`2024_01_01_000012_create_categories_table.php`)
```php
$table->string('name')->unique();
$table->string('slug')->unique();
$table->text('description')->nullable();
$table->string('image')->nullable();  // PAS icon
$table->boolean('is_active')->default(true);
// AUCUNE colonne 'order'
```

### Seeder (`database/seeders/CategorySeeder.php`)
- ✅ Corrigé : Supprimé `icon` et `order`

---

## 4. Table `products`

### Migration (`2024_01_01_000013_create_products_table.php`)
```php
$table->integer('stock_quantity')->default(0);  // PAS stock
$table->boolean('is_available')->default(true);  // PAS is_active
$table->string('slug')->unique();  // REQUIS
```

### Seeder (`database/seeders/ProductSeeder.php`)
- ✅ Corrigé : `stock` → `stock_quantity`
- ✅ Corrigé : `is_active` → `is_available`
- ✅ Corrigé : Ajout du `slug`

---

## 5. Table `wallets`

### Migration (`2024_01_01_000021_create_wallets_table.php`)
```php
// Relation POLYMORPHIQUE, PAS user_id
$table->string('walletable_type');
$table->unsignedBigInteger('walletable_id')->nullable();
```

### Utilisation correcte dans les seeders
```php
Wallet::create([
    'walletable_type' => Pharmacy::class,  // ou Courier::class
    'walletable_id' => $entity->id,
    'balance' => 0,
    'currency' => 'XOF',
]);
```

---

## 6. Table `settings`

### Migration (`2024_01_01_000032_create_settings_table.php`)
```php
$table->string('key')->unique();
$table->text('value')->nullable();
$table->string('type')->default('string');  // PAS group
```

### Seeder (`database/seeders/SettingsSeeder.php`)
- ✅ Corrigé : `group` → `type`

---

## Commandes utiles

```bash
# Rafraîchir la base avec les seeds
php artisan migrate:fresh --seed

# Vérifier la structure d'une table
php artisan db:table pharmacies

# Exécuter les tests
php artisan test
```

---

## Checklist de cohérence

Avant d'ajouter une nouvelle fonctionnalité, vérifier :

1. ✅ La migration définit les bonnes colonnes
2. ✅ Le modèle a les colonnes dans `$fillable`
3. ✅ Le modèle a les bons `$casts`
4. ✅ La factory utilise les bons noms de colonnes
5. ✅ Le seeder utilise les bons noms de colonnes
6. ✅ Les tests utilisent les bons noms de colonnes
