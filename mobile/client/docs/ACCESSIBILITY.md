# 📱 Guide d'Accessibilité (a11y) - DR-Pharma User

Ce guide détaille les fonctionnalités d'accessibilité implémentées pour assurer une application inclusive et conforme aux standards WCAG AA.

## 📋 Table des Matières

1. [Conformité WCAG AA](#conformité-wcag-aa)
2. [Widgets Accessibles](#widgets-accessibles)
3. [Thèmes à Contraste Élevé](#thèmes-à-contraste-élevé)
4. [Extensions Sémantiques](#extensions-sémantiques)
5. [Service d'Accessibilité](#service-daccessibilité)
6. [Bonnes Pratiques](#bonnes-pratiques)
7. [Tests d'Accessibilité](#tests-daccessibilité)

---

## 🎯 Conformité WCAG AA

### Critères Respectés

| Critère | Description | Implémentation |
|---------|-------------|----------------|
| 1.4.3 | Contraste minimum 4.5:1 | `AccessibleThemes` |
| 2.1.1 | Accessibilité clavier | Focus management |
| 2.4.7 | Visibilité du focus | Focus indicators |
| 2.5.5 | Taille de cible 44x44 | `A11yConstants.minTouchTarget` |
| 4.1.2 | Nom, rôle, valeur | Semantic labels |

### Constantes d'Accessibilité

```dart
import 'package:drpharma_client/core/accessibility/accessibility.dart';

class A11yConstants {
  /// Taille minimale de zone tactile (44x44 points)
  static const double minTouchTarget = 44.0;
  
  /// Ratio de contraste minimum (WCAG AA)
  static const double minContrastRatio = 4.5;
  
  /// Ratio pour texte large (WCAG AA)
  static const double minContrastRatioLarge = 3.0;
  
  /// Durée minimum animation (permet désactivation)
  static const Duration reducedMotionDuration = Duration.zero;
  
  /// Durée animation standard
  static const Duration standardAnimationDuration = Duration(milliseconds: 300);
}
```

---

## 🔲 Widgets Accessibles

### AccessibleButton

Bouton avec zone tactile garantie et labels sémantiques :

```dart
import 'package:drpharma_client/core/accessibility/accessibility.dart';

// Bouton standard
AccessibleButton(
  label: 'Commander',
  onPressed: () => handleOrder(),
)

// Avec icône et hint
AccessibleButton(
  label: 'Ajouter au panier',
  icon: Icons.add_shopping_cart,
  hint: 'Ajoute ce médicament au panier',
  onPressed: () => addToCart(item),
)

// Mode destructif
AccessibleButton(
  label: 'Supprimer',
  isDestructive: true,
  onPressed: () => confirmDelete(),
)
```

**Propriétés :**
| Propriété | Type | Description |
|-----------|------|-------------|
| `label` | `String` | Texte du bouton (obligatoire) |
| `onPressed` | `VoidCallback?` | Action au tap |
| `icon` | `IconData?` | Icône optionnelle |
| `hint` | `String?` | Description additionnelle pour lecteurs d'écran |
| `isDestructive` | `bool` | Mode alerte (couleur rouge) |

### AccessibleIcon

Icône avec description sémantique :

```dart
// Icône décorative (ignorée par lecteurs d'écran)
AccessibleIcon(
  icon: Icons.favorite,
  color: Colors.red,
)

// Icône informative avec label
AccessibleIcon(
  icon: Icons.verified,
  semanticLabel: 'Pharmacie vérifiée',
  color: Colors.green,
)

// Icône bouton
AccessibleIcon(
  icon: Icons.close,
  semanticLabel: 'Fermer',
  isButton: true,
  onTap: () => Navigator.pop(context),
)
```

### AccessibleTextField

Champ de texte avec support complet :

```dart
AccessibleTextField(
  label: 'Numéro de téléphone',
  hint: 'Entrez votre numéro au format 06 XX XX XX XX',
  controller: phoneController,
  keyboardType: TextInputType.phone,
)

// Champ obligatoire avec erreur
AccessibleTextField(
  label: 'Adresse email',
  hint: 'exemple@email.com',
  isRequired: true,
  errorText: emailError,
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
)

// Champ mot de passe
AccessibleTextField(
  label: 'Mot de passe',
  hint: 'Minimum 8 caractères',
  obscureText: true,
  controller: passwordController,
)
```

### AccessibleCard

Carte avec zone tactile accessible :

```dart
// Carte informative
AccessibleCard(
  semanticLabel: 'Pharmacie du Centre - 2.5km',
  child: PharmacyInfo(pharmacy: pharmacy),
)

// Carte cliquable
AccessibleCard(
  semanticLabel: 'Médicament Doliprane 500mg - 5,90€',
  hint: 'Appuyez pour voir les détails',
  onTap: () => openProduct(product),
  child: ProductCard(product: product),
)
```

### AccessibleImage

Image avec description alternative :

```dart
// Image informative
AccessibleImage(
  imageProvider: NetworkImage(product.imageUrl),
  semanticLabel: 'Photo du médicament ${product.name}',
  width: 120,
  height: 120,
)

// Image décorative (ignorée)
AccessibleImage(
  imageProvider: AssetImage('assets/decorative_bg.png'),
  isDecorative: true,
)

// Image avec placeholder
AccessibleImage(
  imageProvider: NetworkImage(url),
  semanticLabel: 'Photo de profil',
  placeholder: Container(color: Colors.grey.shade200),
)
```

---

## 🎨 Thèmes à Contraste Élevé

### Configuration des Thèmes

```dart
import 'package:drpharma_client/core/accessibility/accessibility.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AccessibilityPreferences(
      highContrast: true, // Activer le mode contraste élevé
      child: MaterialApp(
        theme: AccessibleThemes.lightTheme(),
        darkTheme: AccessibleThemes.darkTheme(),
        highContrastTheme: AccessibleThemes.highContrastLightTheme(),
        highContrastDarkTheme: AccessibleThemes.highContrastDarkTheme(),
        home: HomePage(),
      ),
    );
  }
}
```

### Thèmes Disponibles

#### Thème Clair Standard
```dart
final lightTheme = AccessibleThemes.lightTheme();
// Contraste : Texte noir sur fond blanc (21:1)
// Accent : Bleu primaire (#1976D2)
```

#### Thème Sombre Standard
```dart
final darkTheme = AccessibleThemes.darkTheme();
// Contraste : Texte blanc sur fond sombre (15.8:1)
// Surface : #121212 (Material Design dark)
```

#### Thème Contraste Élevé Clair
```dart
final highContrastLight = AccessibleThemes.highContrastLightTheme();
// Contraste maximum : Noir pur sur blanc pur
// Bordures accentuées
// Ombres plus marquées
```

#### Thème Contraste Élevé Sombre
```dart
final highContrastDark = AccessibleThemes.highContrastDarkTheme();
// Fond : Noir pur (#000000)
// Texte : Blanc pur (#FFFFFF)
// Accent : Jaune vif pour visibilité maximale
```

### Accéder aux Préférences

```dart
Widget build(BuildContext context) {
  final prefs = AccessibilityPreferences.of(context);
  
  return Column(
    children: [
      Text('Contraste élevé: ${prefs?.highContrast ?? false}'),
      Text('Mouvement réduit: ${prefs?.reduceMotion ?? false}'),
      Text('Texte gras: ${prefs?.boldText ?? false}'),
    ],
  );
}
```

### Configurer les Préférences

```dart
// Au niveau de l'application
AccessibilityPreferences(
  highContrast: userSettings.highContrast,
  reduceMotion: userSettings.reduceMotion,
  boldText: userSettings.boldText,
  child: MaterialApp(...),
)
```

---

## 🏷️ Extensions Sémantiques

### withSemanticLabel

Ajoute un label sémantique à n'importe quel widget :

```dart
Container(
  decoration: BoxDecoration(...),
  child: Icon(Icons.star, color: Colors.yellow),
).withSemanticLabel('Note : 4.5 étoiles sur 5');

// Équivalent à :
Semantics(
  label: 'Note : 4.5 étoiles sur 5',
  child: Container(...),
)
```

### ensureMinTouchTarget

Garantit une zone tactile minimum de 44x44 :

```dart
IconButton(
  icon: Icon(Icons.close, size: 16),
  onPressed: () => close(),
).ensureMinTouchTarget();

// Le bouton aura au minimum 44x44 de zone cliquable
// même si l'icône est plus petite
```

### excludeFromSemantics

Exclut un widget des lecteurs d'écran :

```dart
// Image décorative qui n'apporte pas d'information
Image.asset('assets/pattern_bg.png').excludeFromSemantics();

// Équivalent à :
ExcludeSemantics(
  child: Image.asset('assets/pattern_bg.png'),
)
```

---

## 🔧 Service d'Accessibilité

### AccessibilityService

Service singleton pour la gestion de l'accessibilité :

```dart
import 'package:drpharma_client/core/accessibility/accessibility.dart';

final accessibilityService = AccessibilityService();

// Vérifier le ratio de contraste
final ratio = accessibilityService.getContrastRatio(
  foreground: Colors.black,
  background: Colors.white,
);
// ratio = 21.0 (maximum)

// Vérifier la conformité WCAG AA
final isCompliant = accessibilityService.meetsContrastRequirements(
  foreground: textColor,
  background: backgroundColor,
  isLargeText: false,
);

// Obtenir une couleur accessible
final accessibleColor = accessibilityService.getAccessibleTextColor(
  backgroundColor: Colors.blue,
  preferredColor: Colors.white,
);
// Retourne blanc ou noir selon le meilleur contraste

// Durée d'animation adaptée
final duration = accessibilityService.getAnimationDuration(
  reduceMotion: userPrefs.reduceMotion,
);
```

### Calcul de Contraste

Le service utilise la formule WCAG pour calculer la luminance relative :

```dart
// Luminance relative : L = 0.2126 * R + 0.7152 * G + 0.0722 * B
// Ratio : (L1 + 0.05) / (L2 + 0.05) où L1 > L2

// Exemples de ratios :
// Noir sur Blanc : 21:1 ✅
// Gris #757575 sur Blanc : 4.6:1 ✅ (juste conforme AA)
// Gris #999999 sur Blanc : 2.8:1 ❌ (non conforme)
```

---

## ✅ Bonnes Pratiques

### 1. Labels Sémantiques

```dart
// ❌ Mauvais : pas de contexte
IconButton(
  icon: Icon(Icons.delete),
  onPressed: () => delete(),
)

// ✅ Bon : label explicite
Semantics(
  label: 'Supprimer le médicament Doliprane',
  button: true,
  child: IconButton(
    icon: Icon(Icons.delete),
    onPressed: () => delete(),
  ),
)

// ✅ Mieux : utiliser AccessibleIcon
AccessibleIcon(
  icon: Icons.delete,
  semanticLabel: 'Supprimer le médicament Doliprane',
  isButton: true,
  onTap: () => delete(),
)
```

### 2. Zone Tactile Minimum

```dart
// ❌ Mauvais : zone trop petite
GestureDetector(
  onTap: () => select(),
  child: Container(
    width: 20,
    height: 20,
    child: Icon(Icons.check, size: 12),
  ),
)

// ✅ Bon : zone de 44x44 minimum
GestureDetector(
  onTap: () => select(),
  child: Container(
    width: A11yConstants.minTouchTarget,
    height: A11yConstants.minTouchTarget,
    alignment: Alignment.center,
    child: Icon(Icons.check, size: 24),
  ),
)
```

### 3. Images

```dart
// ❌ Mauvais : pas de description
Image.network(product.imageUrl)

// ✅ Bon : description pour lecteur d'écran
Semantics(
  label: 'Photo du médicament ${product.name}',
  image: true,
  child: Image.network(product.imageUrl),
)

// ❌ Mauvais pour image décorative
Semantics(
  label: 'Image de fond abstraite',
  child: Image.asset('assets/bg.png'),
)

// ✅ Bon : exclure les images décoratives
ExcludeSemantics(
  child: Image.asset('assets/bg.png'),
)
```

### 4. Formulaires

```dart
// ❌ Mauvais : champ sans contexte
TextField(
  decoration: InputDecoration(hintText: '06...'),
)

// ✅ Bon : champ avec label et hint
AccessibleTextField(
  label: 'Numéro de téléphone',
  hint: 'Format : 06 XX XX XX XX',
  isRequired: true,
  errorText: phoneError,
  controller: phoneController,
)
```

### 5. Navigation

```dart
// ❌ Mauvais : pas de description de navigation
BottomNavigationBarItem(
  icon: Icon(Icons.home),
  label: '',
)

// ✅ Bon : labels explicites
BottomNavigationBarItem(
  icon: Icon(Icons.home),
  label: 'Accueil',
  tooltip: 'Aller à la page d\'accueil',
)
```

### 6. États et Feedback

```dart
// ❌ Mauvais : état non annoncé
if (isLoading) CircularProgressIndicator();

// ✅ Bon : état annoncé
Semantics(
  label: 'Chargement en cours',
  child: CircularProgressIndicator(),
)

// ✅ Annoncer les changements importants
SemanticsService.announce('Commande validée avec succès', TextDirection.ltr);
```

### 7. Mouvement Réduit

```dart
// Respecter la préférence de mouvement réduit
Widget build(BuildContext context) {
  final prefs = AccessibilityPreferences.of(context);
  final reduceMotion = prefs?.reduceMotion ?? 
    MediaQuery.of(context).disableAnimations;
  
  return AnimatedContainer(
    duration: reduceMotion 
      ? A11yConstants.reducedMotionDuration 
      : A11yConstants.standardAnimationDuration,
    // ...
  );
}
```

---

## 🧪 Tests d'Accessibilité

### Tests Unitaires Existants

```bash
# Exécuter les tests d'accessibilité
flutter test test/core/accessibility/

# Tests disponibles :
# - accessibility_test.dart (33 tests)
#   - A11yConstants
#   - AccessibilityService
#   - AccessibleButton
#   - AccessibleIcon
#   - AccessibleTextField
#   - AccessibleCard
#   - Extensions sémantiques
```

### Exemple de Test

```dart
testWidgets('AccessibleButton has minimum touch target', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AccessibleButton(
          label: 'Test',
          onPressed: () {},
        ),
      ),
    ),
  );
  
  final button = tester.widget<ConstrainedBox>(
    find.descendant(
      of: find.byType(AccessibleButton),
      matching: find.byType(ConstrainedBox),
    ),
  );
  
  expect(button.constraints.minHeight, A11yConstants.minTouchTarget);
  expect(button.constraints.minWidth, A11yConstants.minTouchTarget);
});
```

### Tests Recommandés

```dart
// 1. Vérifier les labels sémantiques
testWidgets('Widget has semantic label', (tester) async {
  await tester.pumpWidget(MyWidget());
  
  expect(
    find.bySemanticsLabel('Description attendue'),
    findsOneWidget,
  );
});

// 2. Vérifier la zone tactile
testWidgets('Touch target is at least 44x44', (tester) async {
  await tester.pumpWidget(MyButton());
  
  final size = tester.getSize(find.byType(MyButton));
  expect(size.width, greaterThanOrEqualTo(44));
  expect(size.height, greaterThanOrEqualTo(44));
});

// 3. Vérifier le contraste
test('Colors meet contrast requirements', () {
  final service = AccessibilityService();
  final ratio = service.getContrastRatio(
    foreground: theme.textColor,
    background: theme.backgroundColor,
  );
  expect(ratio, greaterThanOrEqualTo(4.5));
});
```

### Outils de Test Manuel

1. **Flutter DevTools** - Inspecteur d'accessibilité
2. **Lecteur d'écran** - VoiceOver (iOS) / TalkBack (Android)
3. **Contrast Checker** - Vérifier les ratios de couleur
4. **Accessibility Scanner** - App Android de test

---

## 📚 Ressources

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Flutter Accessibility](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [Material Design Accessibility](https://material.io/design/usability/accessibility.html)
- [Semantics Widget](https://api.flutter.dev/flutter/widgets/Semantics-class.html)

---

## 📊 Checklist d'Accessibilité

### Avant Chaque Release

- [ ] Tous les boutons ont une zone tactile ≥ 44x44
- [ ] Toutes les images informatives ont un `semanticLabel`
- [ ] Les images décoratives sont exclues des lecteurs d'écran
- [ ] Le contraste texte/fond respecte le ratio 4.5:1
- [ ] Les formulaires ont des labels explicites
- [ ] Les erreurs sont annoncées aux lecteurs d'écran
- [ ] La navigation est possible au clavier
- [ ] Les animations respectent `reduceMotion`
- [ ] Les états (loading, error) sont annoncés
- [ ] Test avec VoiceOver/TalkBack effectué

---

*Documentation générée pour DR-Pharma User v1.0*
