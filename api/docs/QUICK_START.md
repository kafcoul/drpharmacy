# 🚀 Guide de Démarrage Rapide - Application Pharmacie

## ✅ Problème Résolu

**Erreur précédente:** `NetworkException: Impossible de se connecter au serveur`

**Cause:** L'URL de l'API était configurée pour l'émulateur Android (`http://10.0.2.2:8000`) au lieu de localhost pour le web.

**Solution:** Modification de `.env` pour utiliser `http://127.0.0.1:8000`

---

## 🔧 Configuration Actuelle

### Fichier `.env`
```properties
API_BASE_URL=http://127.0.0.1:8000
API_TIMEOUT=15000
APP_ENV=development
```

### URLs selon la plateforme
- **Web (Chrome/Safari):** `http://127.0.0.1:8000`
- **Android Emulator:** `http://10.0.2.2:8000` 
- **iOS Simulator:** `http://127.0.0.1:8000`
- **Appareil physique:** `http://[IP_DE_VOTRE_MACHINE]:8000`

---

## 🔐 Comptes de Test

### Compte Pharmacien Principal
| Champ | Valeur |
|-------|--------|
| **Email** | `kouadio.jean@pharmacie.test` |
| **Mot de passe** | `password` |
| **Pharmacie** | Pharmacie Nouvelle |
| **Statut** | ✅ Approuvée |

### Autres Comptes Disponibles
- `pharmacie.soleil@test.ci` / `password` (Pharmacie du Soleil)
- `pharmacie.centrale@test.ci` / `password` (Pharmacie Centrale)

---

## 🚀 Commandes de Lancement

### Lancer sur Web (Chrome)
```bash
cd /Users/teya2023/Downloads/DR-PHARMA/Mobile/pharmacy
./run_pharmacy_web.sh
```

Ou manuellement:
```bash
cd /Users/teya2023/Downloads/DR-PHARMA/Mobile/pharmacy
flutter run -d chrome
```

### Lancer sur Android Emulator
```bash
# 1. Modifier .env pour utiliser 10.0.2.2
# 2. Lancer l'émulateur
# 3. flutter run
```

### Lancer sur iOS Simulator
```bash
flutter run -d ios
```

---

## 🔍 Vérifications Avant de Lancer

### 1. Serveur Laravel actif
```bash
cd /Users/teya2023/Downloads/DR-PHARMA/Backend/laravel-api
php artisan serve
```

### 2. Test de l'API
```bash
curl http://127.0.0.1:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"kouadio.jean@pharmacie.test","password":"password","device_name":"Test"}'
```

Réponse attendue: `{"success":true, ...}`

### 3. Vérifier les logs Flutter
Les logs montreront l'URL utilisée:
```
🔧 [ApiClient] Initialisation - baseUrl: http://127.0.0.1:8000/api
➡️ [ApiClient] REQUEST: POST http://127.0.0.1:8000/api/auth/login
```

---

## 🐛 Dépannage

### Erreur "NetworkException"
✅ **Solution appliquée:** Vérifier que `.env` utilise la bonne URL pour votre plateforme

### Erreur "403 Forbidden"
- Vérifier que le compte est approuvé
- Consulter le panel admin: http://localhost:8000/admin

### Serveur Laravel non accessible
```bash
# Démarrer le serveur
cd Backend/laravel-api
php artisan serve

# Vérifier qu'il tourne
curl http://127.0.0.1:8000
```

### Hot Reload ne fonctionne pas
```bash
# Nettoyer et relancer
flutter clean
flutter pub get
flutter run -d chrome
```

---

## 📱 Fonctionnalités Disponibles

Avec le compte pharmacien, vous avez accès à:
- ✅ Dashboard avec statistiques
- ✅ Gestion des commandes
- ✅ Catalogue de produits
- ✅ Gestion des stocks
- ✅ Notifications en temps réel
- ✅ Paiements et commissions
- ✅ Profil et paramètres
- ✅ Mode offline (avec sync auto)

---

## 📚 Documentation Complémentaire

- **Backend:** `Backend/laravel-api/README.md`
- **Nouveau compte:** `Backend/laravel-api/NOUVEAU_COMPTE_PHARMACIEN.md`
- **Améliorations:** `Mobile/pharmacy/IMPROVEMENTS_SUMMARY.md`
- **Guide d'intégration:** `Mobile/pharmacy/INTEGRATION_GUIDE.md`
- **Tests:** `Documentations/TEST_ACCOUNTS.md`

---

*Dernière mise à jour: 27 janvier 2026*
