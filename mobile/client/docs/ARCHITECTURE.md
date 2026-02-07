# 🏗️ Architecture

## Vue d'ensemble

L'application suit une **architecture Clean Architecture** adaptée à Flutter avec Riverpod.

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Pages     │  │   Widgets   │  │   Providers         │  │
│  │  (Screens)  │  │ (Components)│  │ (State Management)  │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                      DOMAIN                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Entities  │  │  Use Cases  │  │   Repositories      │  │
│  │   (Models)  │  │  (Business) │  │   (Interfaces)      │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                       DATA                                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   API       │  │   Local     │  │   Repository        │  │
│  │   Client    │  │   Storage   │  │   Implementations   │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Structure d'un Feature

Chaque feature suit la structure suivante :

```
features/auth/
├── data/
│   ├── datasources/
│   │   ├── auth_local_datasource.dart
│   │   └── auth_remote_datasource.dart
│   ├── models/
│   │   ├── user_model.dart
│   │   └── login_response_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   └── user.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── login_usecase.dart
│       └── logout_usecase.dart
│
└── presentation/
    ├── pages/
    │   ├── login_page.dart
    │   └── register_page.dart
    ├── providers/
    │   └── auth_provider.dart
    └── widgets/
        └── login_form.dart
```

## State Management avec Riverpod

### Types de Providers

```dart
// 1. Provider simple (valeur statique)
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// 2. StateProvider (état simple)
final counterProvider = StateProvider<int>((ref) => 0);

// 3. StateNotifierProvider (état complexe)
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

// 4. FutureProvider (données asynchrones)
final userProvider = FutureProvider<User>((ref) async {
  return ref.read(authRepositoryProvider).getCurrentUser();
});

// 5. StreamProvider (données en temps réel)
final ordersProvider = StreamProvider<List<Order>>((ref) {
  return ref.read(ordersRepositoryProvider).watchOrders();
});
```

### StateNotifier Pattern

```dart
// État immutable
class AuthState extends Equatable {
  final User? user;
  final bool isLoading;
  final String? error;
  
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });
  
  AuthState copyWith({...}) => AuthState(...);
  
  @override
  List<Object?> get props => [user, isLoading, error];
}

// Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  
  AuthNotifier(this._repository) : super(const AuthState());
  
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _repository.login(email, password);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false, 
        error: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false, 
        user: user,
      ),
    );
  }
}
```

## Navigation avec Go Router

### Configuration des Routes

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(authState),
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      
      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.login;
      }
      if (isLoggedIn && isAuthRoute) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      // ...autres routes
    ],
  );
});
```

### Navigation Programmatique

```dart
// Navigation simple
context.go('/home');

// Avec paramètres
context.go('/pharmacy/${pharmacy.id}');

// Navigation push (empile)
context.push('/product/${product.id}');

// Retour
context.pop();

// Avec données de retour
final result = await context.push<bool>('/confirm');
if (result == true) {
  // Action confirmée
}
```

## Gestion des Erreurs

### Pattern Either (avec dartz)

```dart
// Définition
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erreur serveur']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Erreur réseau']);
}

// Utilisation
Future<Either<Failure, User>> login(String email, String password) async {
  try {
    final user = await _remoteDataSource.login(email, password);
    return Right(user);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } on NetworkException {
    return Left(const NetworkFailure());
  }
}

// Consommation
final result = await repository.login(email, password);

result.fold(
  (failure) => showError(failure.message),
  (user) => navigateToHome(user),
);
```

## Injection de Dépendances

### Avec Riverpod

```dart
// Providers de base
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiUrl,
    connectTimeout: const Duration(seconds: 30),
  ));
  
  dio.interceptors.add(AuthInterceptor(ref));
  dio.interceptors.add(LoggingInterceptor());
  
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(dioProvider));
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    localDataSource: ref.read(authLocalDataSourceProvider),
  );
});

// Use Cases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});
```

## Bonnes Pratiques

### 1. Immutabilité

```dart
// ✅ Bon
class User extends Equatable {
  final String id;
  final String name;
  
  const User({required this.id, required this.name});
  
  User copyWith({String? id, String? name}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
  
  @override
  List<Object?> get props => [id, name];
}

// ❌ Mauvais
class User {
  String id;
  String name;
}
```

### 2. Séparation des Responsabilités

```dart
// ✅ Bon - Un provider par responsabilité
final cartItemsProvider = StateNotifierProvider<CartNotifier, List<CartItem>>();
final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartItemsProvider);
  return items.fold(0, (sum, item) => sum + item.total);
});

// ❌ Mauvais - Provider qui fait tout
final cartProvider = StateNotifierProvider<CartNotifier, CartState>();
// CartState contient items, total, discount, shipping...
```

### 3. Tests First

```dart
// Écrire le test d'abord
test('should return user when login succeeds', () async {
  // Arrange
  when(() => mockRepository.login(any(), any()))
      .thenAnswer((_) async => Right(tUser));
  
  // Act
  final result = await useCase(LoginParams(email: 'test@test.com', password: '123'));
  
  // Assert
  expect(result, Right(tUser));
});
```

## Diagramme de Flux

```
User Action
    │
    ▼
┌─────────┐     ┌──────────┐     ┌────────────┐
│  Widget │────▶│ Provider │────▶│ Repository │
└─────────┘     └──────────┘     └────────────┘
    ▲               │                   │
    │               ▼                   ▼
    │         ┌──────────┐       ┌────────────┐
    │         │  State   │       │   API /    │
    │         │  Update  │       │  Storage   │
    │         └──────────┘       └────────────┘
    │               │                   │
    └───────────────┴───────────────────┘
                Rebuild
```

---

*Voir aussi : [API_SERVICES.md](./API_SERVICES.md), [TESTING.md](./TESTING.md)*
