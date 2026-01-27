# 🏥 Nouveau Compte Pharmacien Créé

**Date de création:** 27 janvier 2026

---

## 🔐 Identifiants de Connexion

### Application Pharmacie
| Champ | Valeur |
|-------|--------|
| **Email** | `kouadio.jean@pharmacie.test` |
| **Mot de passe** | `password` |
| **Rôle** | Pharmacien |

---

## 📋 Informations de l'Utilisateur

| Champ | Valeur |
|-------|--------|
| **ID Utilisateur** | 25 |
| **Nom** | Dr. Kouadio Jean |
| **Téléphone** | +225 27 22 00 99 88 |
| **Email** | kouadio.jean@pharmacie.test |
| **Rôle** | pharmacy |

---

## 🏥 Informations de la Pharmacie

| Champ | Valeur |
|-------|--------|
| **ID Pharmacie** | 11 |
| **Nom** | Pharmacie Nouvelle |
| **Licence** | PHARM-CI-2026-050 |
| **Adresse** | Boulevard Principal, Angré |
| **Ville** | Abidjan |
| **Téléphone** | +225 27 22 00 99 88 |
| **Email** | kouadio.jean@pharmacie.test |
| **Coordonnées GPS** | 5.3800, -4.0200 |
| **Statut** | ✅ **Approuvée** (approved) |
| **Date d'approbation** | 27 janvier 2026 |
| **Propriétaire** | Dr. Kouadio Jean |

---

## 🚀 Utilisation

### Se connecter à l'application pharmacie

1. **Sur Web/Mobile:**
   - Ouvrir l'application pharmacie
   - Utiliser l'email: `kouadio.jean@pharmacie.test`
   - Mot de passe: `password`

2. **API Token (pour tests):**
   ```bash
   curl -X POST http://localhost:8000/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{
       "email": "kouadio.jean@pharmacie.test",
       "password": "password",
       "device_name": "TestDevice"
     }'
   ```

### Accès Admin

Pour gérer la pharmacie via le panel admin:
- **URL:** http://localhost:8000/admin
- **Email:** admin@drpharma.ci
- **Mot de passe:** password

---

## ✅ Statut du Compte

- [x] Utilisateur créé
- [x] Pharmacie créée
- [x] Pharmacie approuvée
- [x] Compte actif et prêt à l'emploi

---

## 🔧 Commandes Utiles

### Réinitialiser le mot de passe
```bash
cd Backend/laravel-api
php artisan tinker --execute="\$user = App\Models\User::where('email', 'kouadio.jean@pharmacie.test')->first(); \$user->password = Hash::make('nouveau_mot_de_passe'); \$user->save(); echo 'Mot de passe modifié!';"
```

### Vérifier le statut
```bash
cd Backend/laravel-api
php artisan tinker --execute="\$pharmacy = App\Models\Pharmacy::find(11); echo 'Statut: ' . \$pharmacy->status;"
```

### Désactiver la pharmacie
```bash
cd Backend/laravel-api
php artisan tinker --execute="\$pharmacy = App\Models\Pharmacy::find(11); \$pharmacy->status = 'suspended'; \$pharmacy->save(); echo 'Pharmacie suspendue';"
```

---

## 📝 Notes

- Le compte est immédiatement utilisable
- Le statut "approved" permet l'accès complet à toutes les fonctionnalités
- Pour créer d'autres comptes, utilisez: `php scripts/create_pharmacy_account.php`

---

*Généré automatiquement le 27 janvier 2026*
