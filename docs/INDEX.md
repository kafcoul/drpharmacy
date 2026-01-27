# 📚 Documentation DR-PHARMA

## Vue d'ensemble

DR-PHARMA est une plateforme de livraison de médicaments composée de :
- **Backend API** (Laravel)
- **App Client** (Flutter)
- **App Pharmacie** (Flutter)
- **App Coursier** (Flutter)

---

## 📁 Structure de la documentation

### 🚀 Démarrage rapide
| Document | Description |
|----------|-------------|
| [QUICK_START.md](./QUICK_START.md) | Guide de démarrage rapide |
| [INTEGRATION_GUIDE.md](./INTEGRATION_GUIDE.md) | Guide d'intégration des APIs |

### 📖 README par composant
| Document | Description |
|----------|-------------|
| [README_MAIN.md](./README_MAIN.md) | README principal du projet |
| [README_API.md](./README_API.md) | Documentation API Laravel |
| [README_USER.md](./README_USER.md) | Documentation app client |
| [README_PHARMACY.md](./README_PHARMACY.md) | Documentation app pharmacie |
| [README_COURSIER.md](./README_COURSIER.md) | Documentation app coursier |

### 👤 Gestion des comptes
| Document | Description |
|----------|-------------|
| [NOUVEAU_COMPTE_PHARMACIEN.md](./NOUVEAU_COMPTE_PHARMACIEN.md) | Création de compte pharmacien |
| [NOUVEAU_COMPTE_PHARMACIEN_API.md](./NOUVEAU_COMPTE_PHARMACIEN_API.md) | API création compte pharmacien |

### 📊 Rapports & Historique
| Document | Description |
|----------|-------------|
| [WORK_COMPLETED.md](./WORK_COMPLETED.md) | Travaux terminés |
| [IMPROVEMENTS_SUMMARY.md](./IMPROVEMENTS_SUMMARY.md) | Résumé des améliorations |
| [IMPROVEMENTS_SESSION2.md](./IMPROVEMENTS_SESSION2.md) | Améliorations session 2 |
| [MISSING_FEATURES.md](./MISSING_FEATURES.md) | Fonctionnalités manquantes |
| [MOBILE_IMPLEMENTATION_REPORT.md](./MOBILE_IMPLEMENTATION_REPORT.md) | Rapport implémentation mobile |

---

## 🔧 Configuration

### Backend (Laravel)
```bash
cd Backend/laravel-api
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

### Apps Flutter
```bash
cd Mobile/[user|pharmacy|coursier]
flutter pub get
flutter run
```

---

## 📞 Support

Pour toute question, consultez les documents ci-dessus ou contactez l'équipe de développement.
