# Migration setState → Riverpod Providers

## Objectif

Remplacer les `setState()` par des providers Riverpod pour :
- Meilleure testabilité
- Réutilisabilité des états
- Séparation UI/logique
- Éviter les rebuilds inutiles

## Providers disponibles

Le fichier `lib/core/providers/ui_state_providers.dart` fournit des providers réutilisables :

### 1. `toggleProvider` - Pour les états booléens

```dart
// Avant (setState)
bool _obscurePassword = true;
onPressed: () => setState(() => _obscurePassword = !_obscurePassword)

// Après (Riverpod)
// Dans le widget (ConsumerStatefulWidget ou ConsumerWidget)
final obscure = ref.watch(toggleProvider('password_visibility'));
onPressed: () => ref.read(toggleProvider('password_visibility').notifier).toggle()
```

### 2. `loadingProvider` - Pour les états de chargement

```dart
// Avant
bool _isLoading = false;
setState(() => _isLoading = true);
// ... async operation
setState(() => _isLoading = false);

// Après
ref.read(loadingProvider('form_submit').notifier).startLoading();
// ... async operation
ref.read(loadingProvider('form_submit').notifier).stopLoading();

// Dans le build
final loadingState = ref.watch(loadingProvider('form_submit'));
if (loadingState.isLoading) { ... }
```

### 3. `selectedIndexProvider` - Pour les index sélectionnés

```dart
// Avant
int _selectedTab = 0;
onTap: (index) => setState(() => _selectedTab = index)

// Après
final selectedTab = ref.watch(selectedIndexProvider('main_tabs'));
onTap: (index) => ref.read(selectedIndexProvider('main_tabs').notifier).select(index)
```

### 4. `countdownProvider` - Pour les compteurs

```dart
// Avant
int _countdown = 60;
setState(() => _countdown = _countdown - 1);

// Après
ref.read(countdownProvider('otp_resend').notifier).setValue(60);
ref.read(countdownProvider('otp_resend').notifier).decrement();
```

## Quand garder setState

**Garder `setState`** pour :
- PageController synchronization (ex: onboarding pages)
- Animations locales
- États très éphémères (ex: hover states)
- TextEditingController focus management

**Migrer vers Riverpod** pour :
- États partagés entre widgets
- États qui affectent la logique métier
- États testables (loading, errors)
- États persistés ou synchronisés

## Exemple complet : Migration d'un formulaire

### Avant

```dart
class LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;
  
  Future<void> _handleSubmit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      await authService.login(...);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
            ),
          ),
        ),
        if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading ? CircularProgressIndicator() : Text('Login'),
        ),
      ],
    );
  }
}
```

### Après

```dart
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingState = ref.watch(loadingProvider('login'));
    final obscurePassword = ref.watch(toggleProvider('login_password'));
    
    Future<void> handleSubmit() async {
      ref.read(loadingProvider('login').notifier).startLoading();
      
      try {
        await ref.read(authProvider.notifier).login(...);
      } catch (e) {
        ref.read(loadingProvider('login').notifier).setError(e.toString());
      }
    }
    
    return Column(
      children: [
        TextField(
          obscureText: obscurePassword,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () => ref.read(toggleProvider('login_password').notifier).toggle(),
              icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
            ),
          ),
        ),
        if (loadingState.error != null) 
          Text(loadingState.error!, style: TextStyle(color: Colors.red)),
        ElevatedButton(
          onPressed: loadingState.isLoading ? null : handleSubmit,
          child: loadingState.isLoading 
              ? CircularProgressIndicator() 
              : Text('Login'),
        ),
      ],
    );
  }
}
```

## Plan de migration

1. ✅ Créer `ui_state_providers.dart`
2. ✅ Migrer les pages critiques :
   - ✅ `login_page.dart` - _obscurePassword, _useEmail, _isRedirecting
   - ✅ `register_page.dart` - _obscurePassword, _obscureConfirmPassword, _acceptTerms
   - ✅ `otp_verification_page.dart` - _isLoading, _resendTimer, _errorMessage
   - ✅ `forgot_password_page.dart` - _isLoading, _emailSent, _errorMessage
   - ✅ `change_password_page.dart` - _obscure* toggles (password strength gardé setState)
   - ✅ `checkout_page.dart` - useManualAddress, saveNewAddress, isSubmitting, paymentMode
3. ✅ Migrer les pages secondaires :
   - ✅ `edit_profile_page.dart` - password toggles
   - ✅ `add_address_page.dart` - isDefault, selectedLabel, isLoadingLocation
   - ✅ `edit_address_page.dart` - idem
   - ✅ `products_list_page.dart` - selectedCategory
   - ✅ `product_details_page.dart` - quantity
   - ✅ `orders_list_page.dart` - selectedStatus
   - ✅ `prescription_upload_page.dart` - _isUploading → loadingProvider
   - ✅ `pharmacies_list_page_v2.dart` - _searchQuery → formFieldsProvider
4. ⏳ Pages non migrées (setState acceptable) :
   - `onboarding_page.dart` - PageController sync
   - `tracking_page.dart` - LatLng, Set<Marker> (objets complexes)
   - `pharmacies_list_page.dart` - multiples filtres + Position GPS
   - `pharmacies_map_page.dart` - Set<Marker> Google Maps
   - `on_duty_pharmacies_map_page.dart` - état carte Google Maps

## Statistiques actuelles (1 février 2026)

- **38 occurrences** de `setState` restantes (sur 102 initiales = **-63%**)
- **14 pages migrées** sur 20
- **6 pages gardent setState** (acceptable pour états complexes: GPS, Google Maps, PageController)

## Tests

Après migration, ajouter des tests pour chaque provider :

```dart
test('toggleProvider should toggle state', () {
  final container = ProviderContainer();
  
  expect(container.read(toggleProvider('test')), true);
  
  container.read(toggleProvider('test').notifier).toggle();
  expect(container.read(toggleProvider('test')), false);
});
```
