# 🔌 Documentation API Interne - DR-Pharma User

Ce guide documente les services, providers et l'interaction avec l'API backend de DR-Pharma.

## 📋 Table des Matières

1. [Architecture API](#architecture-api)
2. [Client HTTP](#client-http)
3. [Providers Riverpod](#providers-riverpod)
4. [Endpoints Backend](#endpoints-backend)
5. [Gestion des Erreurs](#gestion-des-erreurs)
6. [Authentification](#authentification)
7. [Exemples d'Utilisation](#exemples-dutilisation)

---

## 🏗️ Architecture API

### Structure des Couches

```
┌─────────────────────────────────────────────────────┐
│                    UI (Widgets)                      │
│                        │                             │
│                        ▼                             │
│              Providers (Riverpod)                    │
│                        │                             │
│                        ▼                             │
│               Use Cases / Services                   │
│                        │                             │
│                        ▼                             │
│                  Repositories                        │
│                        │                             │
│                        ▼                             │
│               Data Sources (API)                     │
│                        │                             │
│                        ▼                             │
│                  HTTP Client                         │
└─────────────────────────────────────────────────────┘
```

### Flux de Données

```
1. Widget appelle ref.watch(provider)
2. Provider déclenche le UseCase
3. UseCase appelle le Repository
4. Repository fait la requête via DataSource
5. DataSource utilise HttpClient
6. Réponse remonte via les couches
7. Widget se rebuild avec les nouvelles données
```

---

## 🌐 Client HTTP

### Configuration de Base

```dart
// lib/core/network/http_client.dart
import 'package:dio/dio.dart';
import '../security/security.dart';

class ApiClient {
  late final Dio _dio;
  final String baseUrl;
  
  ApiClient({required this.baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _SecurityInterceptor(),
      _LoggingInterceptor(),
    ]);
  }
}
```

### Intercepteurs

#### Intercepteur d'Authentification

```dart
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = AuthService.instance.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Tenter de refresh le token
      final refreshed = await AuthService.instance.refreshToken();
      if (refreshed) {
        // Retry la requête
        final response = await _retry(err.requestOptions);
        return handler.resolve(response);
      }
    }
    handler.next(err);
  }
}
```

#### Intercepteur de Sécurité

```dart
class _SecurityInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Ajouter les headers de sécurité
    final securityHeaders = NetworkSecurity.getSecurityHeaders(
      'your-secret-key',
      apiVersion: 'v1',
    );
    options.headers.addAll(securityHeaders);
    
    // Ajouter la signature
    if (options.data != null) {
      final signature = NetworkSecurity.generateRequestSignature(
        options.path,
        DateTime.now().millisecondsSinceEpoch.toString(),
        options.data.toString(),
        'your-secret-key',
      );
      options.headers['X-Request-Signature'] = signature;
    }
    
    handler.next(options);
  }
}
```

---

## 🔄 Providers Riverpod

### Provider d'API Client

```dart
// lib/core/providers/api_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: Environment.apiBaseUrl);
});
```

### Providers de Données

#### Pharmacies Provider

```dart
// Fetch all pharmacies
final pharmaciesProvider = FutureProvider<List<Pharmacy>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/pharmacies');
  return (response.data as List)
      .map((json) => Pharmacy.fromJson(json))
      .toList();
});

// Pharmacy details
final pharmacyProvider = FutureProvider.family<Pharmacy, String>((ref, id) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/pharmacies/$id');
  return Pharmacy.fromJson(response.data);
});

// Nearby pharmacies
final nearbyPharmaciesProvider = FutureProvider.family<List<Pharmacy>, LatLng>((ref, location) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/pharmacies/nearby', queryParameters: {
    'latitude': location.latitude,
    'longitude': location.longitude,
    'radius': 5000, // 5km
  });
  return (response.data as List)
      .map((json) => Pharmacy.fromJson(json))
      .toList();
});
```

#### Products Provider

```dart
// Search products
final productSearchProvider = FutureProvider.family<List<Product>, String>((ref, query) async {
  final apiClient = ref.watch(apiClientProvider);
  final sanitizedQuery = InputSanitizer.sanitizeText(query);
  
  final response = await apiClient.get('/products/search', queryParameters: {
    'q': sanitizedQuery,
  });
  return (response.data as List)
      .map((json) => Product.fromJson(json))
      .toList();
});

// Product by barcode
final productByBarcodeProvider = FutureProvider.family<Product?, String>((ref, barcode) async {
  final apiClient = ref.watch(apiClientProvider);
  
  if (!InputSanitizer.isValidBarcode(barcode)) {
    throw InvalidInputException('Code-barres invalide');
  }
  
  final response = await apiClient.get('/products/barcode/$barcode');
  return Product.fromJson(response.data);
});
```

#### Orders Provider (StateNotifier)

```dart
// Order state
class OrderState {
  final List<OrderItem> items;
  final Pharmacy? selectedPharmacy;
  final DeliveryAddress? deliveryAddress;
  final bool isProcessing;
  final String? error;
  
  const OrderState({
    this.items = const [],
    this.selectedPharmacy,
    this.deliveryAddress,
    this.isProcessing = false,
    this.error,
  });
  
  OrderState copyWith({...}) => OrderState(...);
  
  double get total => items.fold(0, (sum, item) => sum + item.subtotal);
}

// Order notifier
class OrderNotifier extends StateNotifier<OrderState> {
  final ApiClient _apiClient;
  
  OrderNotifier(this._apiClient) : super(const OrderState());
  
  void addItem(Product product, int quantity) {
    state = state.copyWith(
      items: [...state.items, OrderItem(product: product, quantity: quantity)],
    );
  }
  
  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
  }
  
  void updateQuantity(String productId, int quantity) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.product.id == productId) {
          return item.copyWith(quantity: quantity);
        }
        return item;
      }).toList(),
    );
  }
  
  Future<Order> submitOrder() async {
    state = state.copyWith(isProcessing: true, error: null);
    
    try {
      final response = await _apiClient.post('/orders', data: {
        'pharmacy_id': state.selectedPharmacy!.id,
        'items': state.items.map((i) => i.toJson()).toList(),
        'delivery_address': state.deliveryAddress!.toJson(),
      });
      
      final order = Order.fromJson(response.data);
      state = const OrderState(); // Reset
      return order;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}

// Provider
final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OrderNotifier(apiClient);
});
```

#### Authentication Provider

```dart
// Auth state
class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  
  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final SecureStorage _storage;
  
  AuthNotifier(this._apiClient, this._storage) : super(const AuthState()) {
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    final token = await _storage.read('access_token');
    if (token != null && TokenValidator.isTokenValid(token)) {
      await _fetchUser();
    }
  }
  
  Future<void> login(String email, String password) async {
    // Valider et sanitiser les entrées
    if (!InputSanitizer.isValidEmail(email)) {
      state = state.copyWith(error: 'Email invalide');
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiClient.post('/auth/login', data: {
        'email': InputSanitizer.sanitizeText(email),
        'password': password,
      });
      
      await _storage.write('access_token', response.data['access_token']);
      await _storage.write('refresh_token', response.data['refresh_token']);
      
      await _fetchUser();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Identifiants incorrects');
    }
  }
  
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    // Validation
    if (!InputSanitizer.isValidEmail(email)) {
      throw ValidationException('Email invalide');
    }
    if (!InputSanitizer.isValidPhone(phone)) {
      throw ValidationException('Téléphone invalide');
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiClient.post('/auth/register', data: {
        'name': InputSanitizer.sanitizeText(name),
        'email': InputSanitizer.sanitizeText(email),
        'phone': InputSanitizer.sanitizeText(phone),
        'password': password,
      });
      
      await _storage.write('access_token', response.data['access_token']);
      await _fetchUser();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
  
  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthState();
  }
  
  Future<void> _fetchUser() async {
    final response = await _apiClient.get('/user');
    final user = User.fromJson(response.data);
    state = AuthState(user: user, isAuthenticated: true);
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(apiClient, storage);
});
```

---

## 📡 Endpoints Backend

### Authentification

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/auth/register` | Inscription |
| POST | `/auth/login` | Connexion |
| POST | `/auth/logout` | Déconnexion |
| POST | `/auth/refresh` | Rafraîchir le token |
| POST | `/auth/forgot-password` | Mot de passe oublié |
| POST | `/auth/reset-password` | Réinitialiser mot de passe |

### Utilisateur

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/user` | Profil utilisateur |
| PUT | `/user` | Mettre à jour le profil |
| PUT | `/user/password` | Changer le mot de passe |
| DELETE | `/user` | Supprimer le compte |

### Pharmacies

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/pharmacies` | Liste des pharmacies |
| GET | `/pharmacies/{id}` | Détails d'une pharmacie |
| GET | `/pharmacies/nearby` | Pharmacies à proximité |
| GET | `/pharmacies/{id}/products` | Produits d'une pharmacie |
| GET | `/pharmacies/{id}/hours` | Horaires d'ouverture |

### Produits

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/products` | Liste des produits |
| GET | `/products/{id}` | Détails d'un produit |
| GET | `/products/search` | Recherche de produits |
| GET | `/products/barcode/{code}` | Produit par code-barres |
| GET | `/products/categories` | Catégories de produits |

### Commandes

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/orders` | Historique des commandes |
| GET | `/orders/{id}` | Détails d'une commande |
| POST | `/orders` | Créer une commande |
| PUT | `/orders/{id}/cancel` | Annuler une commande |
| GET | `/orders/{id}/track` | Suivi de livraison |

### Ordonnances

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/prescriptions` | Liste des ordonnances |
| POST | `/prescriptions` | Envoyer une ordonnance |
| GET | `/prescriptions/{id}` | Détails d'une ordonnance |
| GET | `/prescriptions/{id}/status` | Statut de validation |

### Paiements

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/payments/initiate` | Initier un paiement |
| GET | `/payments/{id}/status` | Statut du paiement |
| POST | `/payments/webhook` | Webhook de confirmation |

---

## ⚠️ Gestion des Erreurs

### Classes d'Erreur

```dart
// lib/core/errors/app_exceptions.dart

abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, [this.code]);
  
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([String message = 'Erreur réseau']) : super(message, 'NETWORK');
}

class ApiException extends AppException {
  final int statusCode;
  
  ApiException(String message, this.statusCode, [String? code]) 
    : super(message, code);
  
  factory ApiException.fromResponse(Response response) {
    final data = response.data;
    return ApiException(
      data['message'] ?? 'Erreur serveur',
      response.statusCode ?? 500,
      data['code'],
    );
  }
}

class ValidationException extends AppException {
  final Map<String, List<String>>? errors;
  
  ValidationException(String message, [this.errors]) 
    : super(message, 'VALIDATION');
}

class AuthException extends AppException {
  AuthException([String message = 'Non authentifié']) 
    : super(message, 'AUTH');
}

class NotFoundException extends AppException {
  NotFoundException([String message = 'Ressource non trouvée']) 
    : super(message, 'NOT_FOUND');
}
```

### Intercepteur d'Erreurs

```dart
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapError(err);
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: exception,
    ));
  }
  
  AppException _mapError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException('Délai de connexion dépassé');
        
      case DioExceptionType.connectionError:
        return NetworkException('Impossible de se connecter au serveur');
        
      case DioExceptionType.badResponse:
        return _mapResponseError(err.response!);
        
      default:
        return NetworkException('Erreur inattendue');
    }
  }
  
  AppException _mapResponseError(Response response) {
    switch (response.statusCode) {
      case 400:
        return ValidationException(
          response.data['message'] ?? 'Données invalides',
          response.data['errors'],
        );
      case 401:
        return AuthException('Session expirée');
      case 403:
        return AuthException('Accès non autorisé');
      case 404:
        return NotFoundException(response.data['message']);
      case 422:
        return ValidationException(
          'Validation échouée',
          response.data['errors'],
        );
      case 429:
        return ApiException('Trop de requêtes, réessayez plus tard', 429);
      case 500:
      case 502:
      case 503:
        return ApiException('Erreur serveur', response.statusCode!);
      default:
        return ApiException.fromResponse(response);
    }
  }
}
```

### Gestion dans l'UI

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pharmaciesAsync = ref.watch(pharmaciesProvider);
    
    return pharmaciesAsync.when(
      data: (pharmacies) => PharmacyList(pharmacies: pharmacies),
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorWidget(
        error: error,
        onRetry: () => ref.refresh(pharmaciesProvider),
      ),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  
  @override
  Widget build(BuildContext context) {
    final message = _getErrorMessage(error);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          SizedBox(height: 16),
          AccessibleButton(
            label: 'Réessayer',
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
  
  String _getErrorMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Une erreur est survenue';
  }
}
```

---

## 🔐 Authentification

### Flow d'Authentification

```
┌──────────────────────────────────────────────────────┐
│                    Login Flow                         │
├──────────────────────────────────────────────────────┤
│                                                       │
│  User Input                                          │
│      │                                               │
│      ▼                                               │
│  Validation (InputSanitizer)                         │
│      │                                               │
│      ▼                                               │
│  POST /auth/login                                    │
│      │                                               │
│      ▼                                               │
│  Receive Tokens (access + refresh)                   │
│      │                                               │
│      ▼                                               │
│  Store in SecureStorage                              │
│      │                                               │
│      ▼                                               │
│  Fetch User Profile                                  │
│      │                                               │
│      ▼                                               │
│  Update AuthState                                    │
│                                                       │
└──────────────────────────────────────────────────────┘
```

### Token Refresh Flow

```dart
class TokenManager {
  final SecureStorage _storage;
  final ApiClient _apiClient;
  
  Future<String?> getValidAccessToken() async {
    final accessToken = await _storage.read('access_token');
    
    if (accessToken == null) return null;
    
    // Vérifier si le token expire bientôt (5 min)
    if (TokenValidator.isTokenExpiringSoon(accessToken, 
        thresholdMinutes: 5)) {
      return await _refreshToken();
    }
    
    return accessToken;
  }
  
  Future<String?> _refreshToken() async {
    final refreshToken = await _storage.read('refresh_token');
    if (refreshToken == null) return null;
    
    try {
      final response = await _apiClient.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });
      
      final newAccessToken = response.data['access_token'];
      final newRefreshToken = response.data['refresh_token'];
      
      await _storage.write('access_token', newAccessToken);
      if (newRefreshToken != null) {
        await _storage.write('refresh_token', newRefreshToken);
      }
      
      return newAccessToken;
    } catch (e) {
      // Refresh failed, user needs to re-login
      await _storage.deleteAll();
      return null;
    }
  }
}
```

---

## 💡 Exemples d'Utilisation

### Recherche de Produits

```dart
class ProductSearchPage extends ConsumerStatefulWidget {
  @override
  _ProductSearchPageState createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends ConsumerState<ProductSearchPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AccessibleTextField(
          label: 'Rechercher un médicament',
          hint: 'Nom du médicament...',
          controller: _searchController,
          onSubmitted: (value) {
            setState(() => _searchQuery = value);
          },
        ),
      ),
      body: _searchQuery.isEmpty
          ? _buildEmptyState()
          : _buildSearchResults(),
    );
  }
  
  Widget _buildSearchResults() {
    final results = ref.watch(productSearchProvider(_searchQuery));
    
    return results.when(
      data: (products) {
        if (products.isEmpty) {
          return Center(child: Text('Aucun résultat'));
        }
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return AccessibleCard(
              semanticLabel: '${product.name} - ${product.price}€',
              onTap: () => _openProduct(product),
              child: ProductListItem(product: product),
            );
          },
        );
      },
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorWidget(error: e, onRetry: () {
        ref.refresh(productSearchProvider(_searchQuery));
      }),
    );
  }
}
```

### Passer une Commande

```dart
class CheckoutPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('Valider la commande')),
      body: Column(
        children: [
          // Liste des articles
          Expanded(
            child: ListView.builder(
              itemCount: orderState.items.length,
              itemBuilder: (context, index) {
                final item = orderState.items[index];
                return OrderItemTile(
                  item: item,
                  onQuantityChanged: (qty) {
                    ref.read(orderProvider.notifier)
                        .updateQuantity(item.product.id, qty);
                  },
                  onRemove: () {
                    ref.read(orderProvider.notifier)
                        .removeItem(item.product.id);
                  },
                );
              },
            ),
          ),
          
          // Total
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: Theme.of(context).textTheme.titleLarge),
                Text(
                  '${orderState.total.toStringAsFixed(2)}€',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Bouton de validation
          Padding(
            padding: EdgeInsets.all(16),
            child: AccessibleButton(
              label: orderState.isProcessing 
                  ? 'Traitement...' 
                  : 'Confirmer la commande',
              onPressed: orderState.isProcessing 
                  ? null 
                  : () => _submitOrder(context, ref),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _submitOrder(BuildContext context, WidgetRef ref) async {
    try {
      final order = await ref.read(orderProvider.notifier).submitOrder();
      
      // Annoncer le succès pour l'accessibilité
      SemanticsService.announce(
        'Commande ${order.id} confirmée',
        TextDirection.ltr,
      );
      
      // Naviguer vers la confirmation
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderConfirmationPage(order: order),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }
}
```

### Upload d'Ordonnance

```dart
class PrescriptionUploadPage extends ConsumerStatefulWidget {
  @override
  _PrescriptionUploadPageState createState() => _PrescriptionUploadPageState();
}

class _PrescriptionUploadPageState extends ConsumerState<PrescriptionUploadPage> {
  File? _selectedImage;
  bool _isUploading = false;
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.camera);
    
    if (result != null) {
      // Valider le fichier
      final file = File(result.path);
      if (!PathValidator.isAllowedExtension(result.path, ['.jpg', '.jpeg', '.png', '.pdf'])) {
        _showError('Format de fichier non supporté');
        return;
      }
      
      setState(() => _selectedImage = file);
    }
  }
  
  Future<void> _uploadPrescription() async {
    if (_selectedImage == null) return;
    
    setState(() => _isUploading = true);
    
    try {
      final apiClient = ref.read(apiClientProvider);
      
      // Sanitize filename
      final safeFilename = InputSanitizer.sanitizeFilename(
        _selectedImage!.path.split('/').last,
      );
      
      final formData = FormData.fromMap({
        'prescription': await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: safeFilename,
        ),
      });
      
      final response = await apiClient.post(
        '/prescriptions',
        data: formData,
      );
      
      final prescription = Prescription.fromJson(response.data);
      
      // Navigate to status page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PrescriptionStatusPage(prescription: prescription),
        ),
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isUploading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Envoyer une ordonnance')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedImage != null)
              Image.file(_selectedImage!, height: 200)
            else
              AccessibleIcon(
                icon: Icons.document_scanner,
                semanticLabel: 'Aucune ordonnance sélectionnée',
                size: 100,
                color: Colors.grey,
              ),
            
            SizedBox(height: 24),
            
            AccessibleButton(
              label: 'Prendre une photo',
              icon: Icons.camera_alt,
              onPressed: _pickImage,
            ),
            
            if (_selectedImage != null) ...[
              SizedBox(height: 16),
              AccessibleButton(
                label: _isUploading ? 'Envoi...' : 'Envoyer l\'ordonnance',
                icon: Icons.upload,
                onPressed: _isUploading ? null : _uploadPrescription,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## 📚 Ressources

- [Dio Documentation](https://pub.dev/packages/dio)
- [Riverpod Documentation](https://riverpod.dev/)
- [Laravel Sanctum](https://laravel.com/docs/sanctum)
- [OpenAPI Specification](/openapi.yaml)

---

*Documentation générée pour DR-Pharma User v1.0*
