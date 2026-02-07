# 📱 DR-PHARMA User App - Documentation

> Application mobile Flutter pour les clients de DR-PHARMA

## 📋 Table des matières

| Document | Description |
|----------|-------------|
| [🏗️ Architecture](./ARCHITECTURE.md) | Clean Architecture, structure des couches, patterns |
| [🔒 Sécurité](./SECURITY.md) | Validation, sanitisation, protection réseau |
| [♿ Accessibilité](./ACCESSIBILITY.md) | WCAG AA, widgets accessibles, thèmes |
| [🔌 API](./API.md) | Client HTTP, providers, endpoints backend |
| [🚀 Développement](./DEVELOPMENT.md) | Standards, conventions, git workflow |

---

## 🏗️ Vue d'ensemble

DR-PHARMA User est l'application mobile destinée aux clients pour :

- 🔍 **Rechercher** des médicaments et pharmacies
- 📋 **Commander** via ordonnance ou panier
- 🚚 **Suivre** les livraisons en temps réel
- 💳 **Payer** de manière sécurisée

## 🛠️ Stack Technique

| Composant | Technologie |
|-----------|-------------|
| Framework | Flutter 3.10+ |
| State Management | Riverpod |
| Navigation | Go Router |
| HTTP Client | Dio |
| Stockage local | SharedPreferences + SecureStorage |
| Maps | Google Maps Flutter |
| Notifications | Firebase Cloud Messaging |

## 📁 Structure du Projet

```
lib/
├── core/                    # Fonctionnalités partagées
│   ├── accessibility/       # Widgets accessibles
│   ├── animations/          # Animations et transitions
│   ├── config/              # Configuration app
│   ├── errors/              # Gestion des erreurs
│   ├── network/             # Client API
│   ├── providers/           # Providers globaux
│   ├── router/              # Configuration routes
│   ├── security/            # Sécurité et validation
│   ├── services/            # Services (storage, etc.)
│   ├── utils/               # Utilitaires
│   ├── validators/          # Validateurs de formulaires
│   └── widgets/             # Widgets réutilisables
│
├── features/                # Modules fonctionnels
│   ├── auth/                # Authentification
│   ├── cart/                # Panier
│   ├── delivery/            # Livraison
│   ├── home/                # Accueil
│   ├── notifications/       # Notifications
│   ├── orders/              # Commandes
│   ├── pharmacy/            # Pharmacies
│   ├── prescription/        # Ordonnances
│   ├── products/            # Produits
│   ├── profile/             # Profil utilisateur
│   └── search/              # Recherche
│
└── main.dart                # Point d'entrée

test/
├── core/                    # Tests core
│   ├── accessibility/       # Tests accessibilité
│   ├── animations/          # Tests animations
│   ├── network/             # Tests API
│   ├── providers/           # Tests providers
│   └── security/            # Tests sécurité
├── features/                # Tests fonctionnels
└── performance/             # Tests de performance
```

## 🚀 Démarrage Rapide

```bash
# Installation des dépendances
flutter pub get

# Lancer les tests
flutter test

# Lancer l'application
flutter run
```

## 📊 Statistiques

| Métrique | Valeur |
|----------|--------|
| Tests | 329+ |
| Couverture | ~80% |
| Fichiers Dart | 100+ |
| Lignes de code | 15,000+ |

## 📖 Documentation Complète

Consultez les fichiers de documentation individuels pour plus de détails :

- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - Patterns et architecture
- **[SECURITY.md](./SECURITY.md)** - Pratiques de sécurité
- **[ACCESSIBILITY.md](./ACCESSIBILITY.md)** - Accessibilité WCAG
- **[API_SERVICES.md](./API_SERVICES.md)** - Services et API
- **[TESTING.md](./TESTING.md)** - Guide de tests
- **[CODE_STANDARDS.md](./CODE_STANDARDS.md)** - Standards de code

---

*Documentation générée le 1 février 2026*
