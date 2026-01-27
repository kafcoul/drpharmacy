# 🏥 DR-PHARMA Client Mobile

Application mobile Flutter pour DR-PHARMA - Plateforme de vente de médicaments en ligne en Côte d'Ivoire.

## 📱 Fonctionnalités

### ✅ Récemment implémentées

#### 🏥 Pharmacies avec Géolocalisation (29 déc 2025)

- **Liste des pharmacies** : Affichage de toutes les pharmacies disponibles
- **Géolocalisation GPS** : Trouvez les pharmacies à proximité dans un rayon de 10 km
- **Calcul des distances** : Distances en temps réel (ex: "350 m", "1.2 km")
- **Actions de contact** :
  - 📞 Appel téléphonique direct
  - 📧 Envoi d'email
  - 🗺️ Navigation Google Maps
- **Basculement de modes** : "Toutes les pharmacies" ↔ "À proximité"
- **Gestion intelligente des permissions** : Dialogues pour GPS et autorisations

#### 🔐 Authentification JWT

- Connexion/Inscription avec tokens JWT
- Gestion automatique des tokens dans l'ApiClient
- Persistance de la session utilisateur

#### 🛍️ Catalogue de Produits

- Liste paginée avec recherche
- Détails des produits
- Images en cache

#### 📦 Gestion des Commandes

- Panier d'achat persistant
- Processus de checkout
- Liste et détails des commandes
- Annulation de commande

#### 👤 Profil Utilisateur

- Visualisation du profil
- Modification des informations
- Upload de photo de profil

### 📚 Guides disponibles

- **[OU_TROUVER_PHARMACIES.md](OU_TROUVER_PHARMACIES.md)** - Guide visuel pour trouver l'option Pharmacies
- **[GEOLOCALISATION_GUIDE.md](GEOLOCALISATION_GUIDE.md)** - Documentation complète de la géolocalisation
- **[IMPLEMENTATION_GEOLOCALISATION.md](IMPLEMENTATION_GEOLOCALISATION.md)** - Résumé technique de l'implémentation
- **[README_URL_LAUNCHER.md](core/services/README_URL_LAUNCHER.md)** - Documentation du service UrlLauncher

## 🚀 Démarrage rapide

### Prérequis

```bash
# Flutter SDK 3.32.0+
flutter --version

# Dépendances système
# Android Studio (pour Android)
# Xcode (pour iOS, sur macOS uniquement)
```

### Installation

```bash
# 1. Cloner le projet
cd Mobile/client_flutter

# 2. Installer les dépendances
flutter pub get

# 3. Générer les fichiers JSON
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Vérifier les devices disponibles
flutter devices

# 5. Lancer l'application
flutter run
```

### Configuration Backend

L'application se connecte au backend Laravel sur :

- **Web** : `http://localhost:8000/api`
- **Android Emulator** : `http://10.0.2.2:8000/api`
- **iOS Simulator** : `http://localhost:8000/api`

Modifiable dans : `lib/core/network/api_client.dart`

## 🏗️ Architecture

### Clean Architecture

```
lib/
├── core/                          # Code partagé
│   ├── constants/                 # Couleurs, routes, etc.
│   ├── network/                   # ApiClient, Dio
│   ├── services/                  # Services utilitaires
│   │   └── url_launcher_service.dart  # Appels, emails, maps
│   └── utils/                     # Helpers
│
├── features/                      # Fonctionnalités par domaine
│   ├── auth/                      # Authentification
│   │   ├── domain/               # Entities, Repositories, UseCases
│   │   ├── data/                 # Models, DataSources, Repositories Impl
│   │   └── presentation/         # Pages, Providers, Widgets
│   │
│   ├── products/                  # Produits
│   ├── orders/                    # Commandes
│   ├── pharmacies/                # Pharmacies (NOUVEAU)
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── pharmacies_list_page.dart  # Liste + Géoloc
│   │       │   └── pharmacy_details_page.dart  # Détails + Actions
│   │       ├── providers/
│   │       └── widgets/
│   │
│   ├── profile/                   # Profil utilisateur
│   └── notifications/             # Notifications
│
└── config/
    └── providers.dart             # Configuration Riverpod
```

### État Management

**Riverpod** pour la gestion d'état réactive

Exemple :

```dart
// Provider
final pharmaciesProvider = StateNotifierProvider<PharmaciesNotifier, PharmaciesState>(
  (ref) => PharmaciesNotifier(...)
);

// Usage
final pharmacies = ref.watch(pharmaciesProvider).pharmacies;
```

## 📦 Dépendances principales

```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.5.1

  # Network
  dio: ^5.4.0

  # Storage
  shared_preferences: ^2.2.2

  # Geolocation (NOUVEAU)
  geolocator: ^11.0.0
  geocoding: ^3.0.0

  # URL Launcher (NOUVEAU)
  url_launcher: ^6.2.5

  # JSON
  json_annotation: ^4.8.1

  # Utils
  intl: ^0.19.0
  dartz: ^0.10.1
  equatable: ^2.0.5
```

## 🔐 Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<!-- Géolocalisation -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- URL Launcher -->
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />

<queries>
  <!-- Téléphone -->
  <intent>
    <action android:name="android.intent.action.DIAL" />
  </intent>

  <!-- Email -->
  <intent>
    <action android:name="android.intent.action.SENDTO" />
    <data android:scheme="mailto" />
  </intent>

  <!-- Maps -->
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="geo" />
  </intent>
</queries>
```

### iOS (`ios/Runner/Info.plist`)

```xml
<!-- Géolocalisation -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>DR-PHARMA a besoin d'accéder à votre position pour trouver les pharmacies à proximité.</string>

<!-- URL Launcher -->
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>tel</string>
  <string>mailto</string>
  <string>comgooglemaps</string>
</array>
```

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests avec couverture
flutter test --coverage

# Analyse statique
flutter analyze
```

## 📱 Utilisation

### 1. Navigation vers Pharmacies

Sur la page d'accueil, cliquez sur la carte **"Pharmacies"** (verte avec icône 🏥)

### 2. Voir toutes les pharmacies

Par défaut, la liste affiche toutes les pharmacies disponibles.

### 3. Activer la géolocalisation

**Option A** : Cliquez sur le FloatingActionButton **"À proximité"** (en bas à droite)

**Option B** : Cliquez sur l'icône 📍 dans l'AppBar

### 4. Accorder les permissions

Au premier usage, autorisez l'accès à votre position GPS.

### 5. Consulter les distances

Les pharmacies s'affichent avec leur distance (ex: "350 m", "1.2 km")

### 6. Contacter une pharmacie

Cliquez sur une pharmacie pour voir les détails, puis :

- 📞 Cliquez sur le téléphone pour appeler
- 📧 Cliquez sur l'email pour envoyer un message
- 🗺️ Cliquez sur l'adresse pour ouvrir Google Maps

## 🐛 Dépannage

### Problème : L'option "Pharmacies" n'apparaît pas

**Solution** :

1. Faites un Hot Restart (appuyez sur 'R' dans le terminal)
2. Vérifiez que vous êtes sur la page d'accueil
3. Scrollez vers le bas jusqu'à "Actions Rapides"

### Problème : La géolocalisation ne fonctionne pas

**Solutions** :

1. Vérifiez que le GPS est activé sur votre appareil
2. Accordez les permissions de localisation à l'app
3. Sur Android : Vérifiez les permissions dans les paramètres de l'app
4. Sur iOS : Paramètres → Confidentialité → Services de localisation

### Problème : Les distances ne s'affichent pas

**Causes possibles** :

1. Vous n'êtes pas en mode "À proximité"
2. Les pharmacies n'ont pas de coordonnées GPS dans la base de données
3. La géolocalisation a échoué

**Solutions** :

1. Cliquez sur le bouton "À proximité"
2. Vérifiez les logs Flutter pour les erreurs
3. Vérifiez que le backend retourne `latitude` et `longitude`

### Problème : Erreur 401 Unauthorized

**Cause** : Token JWT expiré ou non configuré

**Solution** :

1. Déconnectez-vous et reconnectez-vous
2. Vérifiez que le backend Laravel est démarré
3. Vérifiez que le token est bien stocké dans SharedPreferences

## 📊 État du projet

### ✅ Fonctionnalités complètes

- Authentification (JWT)
- Produits (liste, recherche, détails)
- Commandes (panier, checkout, liste, annulation)
- Pharmacies (liste, géolocalisation, détails, contact)
- Profil (visualisation, édition, photo)

### 🚧 En développement

- Notifications push
- Chat avec les pharmaciens
- Pharmacies de garde
- Carte interactive

### 📋 À implémenter

- Paiement mobile (Orange Money, MTN Mobile Money, Moov Money)
- Système de fidélité
- Avis et notes
- Historique de recherche

## 📝 Commandes utiles

```bash
# Hot Reload (changements mineurs)
r

# Hot Restart (changements majeurs)
R

# Ouvrir DevTools
p

# Quit
q

# Rebuild (après changements de assets)
flutter clean && flutter pub get && flutter run

# Générer les fichiers JSON
flutter pub run build_runner build --delete-conflicting-outputs

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## 🤝 Contribution

### Workflow

1. Créer une branche : `git checkout -b feature/nom-feature`
2. Coder et tester
3. Commit : `git commit -m "feat: description"`
4. Push : `git push origin feature/nom-feature`
5. Créer une Pull Request

### Conventions

- **Commits** : Suivre [Conventional Commits](https://www.conventionalcommits.org/)
- **Code** : Respecter les conventions Dart/Flutter
- **Tests** : Couvrir les nouvelles fonctionnalités

## 📄 Licence

Propriétaire - DR-PHARMA © 2025

## 📞 Support

Pour toute question ou problème :

- **Documentation** : Voir les guides dans `/Mobile/client_flutter/`
- **Issues** : Créer un ticket sur le dépôt Git
- **Email** : support@drpharma.ci (fictif)

---

**Version** : 1.0.0+1  
**Date de mise à jour** : 29 décembre 2025  
**Dernières modifications** : Ajout de la géolocalisation des pharmacies

🎉 **Application prête pour les tests !**
