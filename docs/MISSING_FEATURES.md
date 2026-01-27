# 🔍 Fonctionnalités Non Implémentées - Application Pharmacy

## 📋 Résumé

| Catégorie | Fonctionnalité | Statut | Priorité |
|-----------|----------------|--------|----------|
| Commandes | Rejeter une commande | ✅ FAIT | Haute |
| Profil | Page paramètres notifications | ✅ FAIT | Moyenne |
| Profil | Page Aide & Support | ✅ FAIT | Moyenne |
| Profil | Conditions d'utilisation | ✅ FAIT | Moyenne |
| Profil | Politique de confidentialité | ✅ FAIT | Moyenne |
| Inventaire | Scan depuis image/galerie | ✅ FAIT | Basse |
| Inventaire | Recherche produits persistante | ✅ FAIT | Basse |
| Inventaire | Appliquer promotion stock | ✅ FAIT | Moyenne |
| Inventaire | Supprimer produit du stock | ✅ FAIT | Moyenne |

---

## 🛒 COMMANDES

### 1. ✅ Rejeter une commande
**Statut**: IMPLÉMENTÉ
**Description**: Dialogue amélioré avec choix de raison prédéfinie ou personnalisée.

---

## 👤 PROFIL

### 2. Page Paramètres Notifications
**Fichier**: `lib/features/profile/presentation/widgets/profile_menu_section.dart:54`
**Description**: Menu "Notifications" n'a pas de page dédiée.

**Solution**: Créer `notification_settings_page.dart` avec:
- Toggle notifications push
- Toggle notifications email
- Choix sons de notification
- Heures silencieuses

### 3. Page Aide & Support
**Fichier**: `lib/features/profile/presentation/widgets/profile_menu_section.dart:78`
**Description**: Pas de page d'aide.

**Solution**: Créer page avec FAQ, contact support, liens utiles.

### 4. Conditions d'utilisation (CGU)
**Fichier**: `lib/features/profile/presentation/widgets/profile_menu_section.dart:121`
**Description**: Pas d'affichage des CGU.

**Solution**: Créer page ou modal affichant les CGU.

### 5. Politique de confidentialité
**Fichier**: `lib/features/profile/presentation/widgets/profile_menu_section.dart:132`
**Description**: Pas d'affichage de la politique.

**Solution**: Créer page ou modal affichant la politique.

---

## 📦 INVENTAIRE

### 6. ✅ Scanner depuis image/galerie
**Statut**: IMPLÉMENTÉ
**Fichier**: `lib/features/inventory/presentation/pages/enhanced_scanner_page.dart`
**Description**: 
- Bouton "Galerie" appelle `_scanFromGallery()`
- Utilise `image_picker` pour sélectionner une image
- Utilise `MobileScannerController.analyzeImage()` pour scanner
- Affiche message si aucun code détecté
- Gestion des erreurs complète

### 7. ✅ Persistance recherche produits
**Statut**: IMPLÉMENTÉ
**Fichier**: `lib/features/inventory/presentation/widgets/product_search_widget.dart`
**Description**:
- Historique sauvegardé dans SharedPreferences
- Méthodes `_loadSearchHistory()`, `_saveSearchToHistory()`, `_clearSearchHistory()`, `_removeFromHistory()`
- Bouton "X" pour supprimer un élément individuel
- Bouton "Effacer" pour vider tout l'historique
- Maximum 10 recherches conservées

### 8. ✅ Appliquer promotion sur produit
**Statut**: IMPLÉMENTÉ
**Fichier**: `lib/features/inventory/presentation/widgets/stock_alerts_widget.dart`
**Description**: Dialogue complet avec:
- Slider de réduction (5% à 70%)
- Sélecteur de dates (début/fin)
- Appel API préparé (repository + datasource)

### 9. ✅ Supprimer produit du stock (Perte)
**Statut**: IMPLÉMENTÉ  
**Fichier**: `lib/features/inventory/presentation/widgets/stock_alerts_widget.dart`
**Description**: Dialogue complet avec:
- Champ quantité à retirer
- Sélection raison (expiré, endommagé, vol, etc.)
- Notes optionnelles
- Appel API préparé (repository + datasource)

---

## ✅ Fonctionnalités DÉJÀ Implémentées

- ✅ Authentification (Login, Register, Forgot Password)
- ✅ Liste des commandes avec filtres
- ✅ Détails commande
- ✅ Confirmer/Préparer commande
- ✅ Gestion inventaire
- ✅ Scanner codes-barres
- ✅ Ajout produit
- ✅ Mise à jour stock
- ✅ Alertes stock bas
- ✅ Liste ordonnances
- ✅ Notifications
- ✅ Wallet/Finances
- ✅ Rapports & Analytics
- ✅ Paramètres sécurité (PIN, Biométrie)
- ✅ Paramètres apparence (Thème, Couleur accent)
- ✅ Profil utilisateur (Édition)
- ✅ Profil pharmacie (Édition)
- ✅ Mode garde

---

## 🎯 Prochaines Étapes Recommandées

1. **Haute priorité**: Implémenter `rejectOrder` (critique pour la gestion des commandes)
2. **Moyenne priorité**: Pages légales (CGU, Confidentialité) pour conformité
3. **Basse priorité**: Améliorations UX (langue, recherche persistante)
