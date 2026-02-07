# DR-PHARMA User App

[![Flutter CI](https://github.com/afriklabprojet/dr-client/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/afriklabprojet/dr-client/actions/workflows/flutter_ci.yml)
[![Tests](https://img.shields.io/badge/tests-104%20passing-brightgreen)](https://github.com/afriklabprojet/dr-client)
[![Flutter](https://img.shields.io/badge/Flutter-3.24.0-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-Proprietary-red.svg)](LICENSE)

Application mobile pour les utilisateurs de DR-PHARMA - Plateforme de livraison de médicaments au Gabon.

## 📱 Fonctionnalités

- 🏥 **Recherche de pharmacies** - Trouvez les pharmacies à proximité et de garde
- 💊 **Catalogue de produits** - Parcourez les médicaments disponibles
- 🛒 **Panier et commandes** - Passez vos commandes facilement
- 📍 **Gestion d'adresses** - Enregistrez vos adresses de livraison
- 📋 **Ordonnances** - Envoyez vos prescriptions médicales
- 🚚 **Suivi de livraison** - Suivez vos commandes en temps réel
- 🔔 **Notifications** - Restez informé de l'état de vos commandes

## 🏗️ Architecture

L'application suit une **Clean Architecture** avec les couches suivantes :

```
lib/
├── core/                    # Services partagés
│   ├── errors/             # Gestion des erreurs (ErrorHandler)
│   ├── network/            # Client API
│   ├── router/             # Navigation GoRouter
│   ├── services/           # Services (AppLogger, SecureStorage)
│   ├── validators/         # Validateurs de formulaires
│   └── widgets/            # Widgets réutilisables
├── config/                 # Configuration et providers
└── features/               # Fonctionnalités par domaine
    ├── auth/               # Authentification
    ├── home/               # Page d'accueil
    ├── pharmacies/         # Pharmacies
    ├── products/           # Produits
    ├── orders/             # Commandes et panier
    ├── addresses/          # Adresses
    ├── prescriptions/      # Ordonnances
    └── profile/            # Profil utilisateur
```

## 🛠️ Technologies

- **Flutter** 3.24.0
- **Riverpod** - State management
- **GoRouter** - Navigation déclarative
- **Dio** - HTTP client
- **flutter_secure_storage** - Stockage sécurisé
- **Mockito** - Tests unitaires

## 🧪 Tests

L'application dispose de **104 tests** couvrant :

| Module | Tests |
|--------|-------|
| AuthNotifier | 11 |
| CartNotifier | 29 |
| OrdersNotifier | 14 |
| AddressesNotifier | 17 |
| PharmaciesNotifier | 18 |
| LoginPage (widget) | 15 |

```bash
# Exécuter tous les tests
flutter test

# Exécuter avec couverture
flutter test --coverage
```

## 🚀 Installation

### Prérequis

- Flutter SDK 3.24.0+
- Dart SDK 3.0+
- Android Studio / Xcode

### Configuration

1. Clonez le repository
```bash
git clone https://github.com/afriklabprojet/dr-client.git
cd dr-client
```

2. Installez les dépendances
```bash
flutter pub get
```

3. Générez les fichiers de mock (pour les tests)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Lancez l'application
```bash
flutter run
```

## 📦 Build

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 📊 Qualité du Code

- **Score audit**: 8/10
- **Tests**: 104 tests passants
- **Navigation**: 100% GoRouter
- **Sécurité**: Tokens stockés avec flutter_secure_storage

## 📄 Documentation

- [Rapport d'Audit](docs/AUDIT_CORRECTIONS_REPORT.md)
- [Guide d'Intégration](docs/INTEGRATION_GUIDE.md)
- [Quick Start](docs/QUICK_START.md)

## 🤝 Contribution

1. Fork le projet
2. Créez votre branche (`git checkout -b feature/amazing-feature`)
3. Committez vos changements (`git commit -m 'Add amazing feature'`)
4. Push sur la branche (`git push origin feature/amazing-feature`)
5. Ouvrez une Pull Request

## 📞 Contact

**Afriklab Projet** - [GitHub](https://github.com/afriklabprojet)

---

© 2026 DR-PHARMA. Tous droits réservés.
