# 🔐 AUDIT COMPLET - Authentification DR-PHARMA Pharmacy App

## Date: Février 2026

---

## 1. 📊 État Actuel

### ✅ Points Positifs

| Fonctionnalité | Status | Notes |
|----------------|--------|-------|
| Token Storage | ✅ | Stocké via `AuthLocalDataSource` (SharedPreferences) |
| Token dans Headers | ✅ | `ApiClient.setToken()` ajoute `Authorization: Bearer` |
| Gestion 401 | ✅ | `UnauthorizedException` levée et propagée |
| Gestion 403 | ✅ | `ForbiddenException` avec `errorCode` |
| Logout local | ✅ | `clearAuthData()` + `clearToken()` |
| Clean Architecture | ✅ | Repository pattern bien implémenté |

### ⚠️ Points d'Amélioration

| Problème | Criticité | Solution |
|----------|-----------|----------|
| Pas de refresh token | 🔴 Haute | Implémenter refresh token flow |
| Pas de logout auto sur 401 global | 🔴 Haute | Intercepteur global 401 |
| Token en SharedPreferences | 🟡 Moyenne | Migrer vers flutter_secure_storage |
| Pas de token expiration check | 🟡 Moyenne | Vérifier exp claim JWT |

---

## 2. 🔴 Problème Critique: Pas de Refresh Token

### Situation Actuelle
- Le token est stocké après login
- Si le token expire, l'utilisateur doit se reconnecter manuellement
- Mauvaise UX pour sessions longues

### Solution Recommandée

```dart
// 1. Ajouter dans auth_response_model.dart
class AuthResponseModel {
  final String token;
  final String refreshToken;  // ← AJOUTER
  final int expiresIn;        // ← AJOUTER
  final UserModel user;
}

// 2. Créer un intercepteur de refresh
class TokenRefreshInterceptor extends Interceptor {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Tenter de rafraîchir le token
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken != null) {
        try {
          final newAuth = await remoteDataSource.refreshToken(refreshToken);
          await localDataSource.cacheToken(newAuth.token);
          
          // Retry la requête originale
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer ${newAuth.token}';
          final response = await Dio().fetch(opts);
          return handler.resolve(response);
        } catch (_) {
          // Refresh échoué → logout
        }
      }
    }
    return handler.next(err);
  }
}
```

---

## 3. 🔴 Problème Critique: Logout Auto sur 401 Global

### Situation Actuelle
Quand un 401 arrive sur une route protégée (pas /login), l'utilisateur reste bloqué.

### Solution: Intercepteur Global 401

Voir fichier: `lib/core/network/auth_interceptor.dart`

---

## 4. 🟡 Amélioration: Secure Storage

### Problème
SharedPreferences n'est pas chiffré sur Android/iOS.

### Solution
```yaml
# pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

```dart
class SecureAuthLocalDataSource implements AuthLocalDataSource {
  final FlutterSecureStorage _storage;
  
  @override
  Future<void> cacheToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  @override
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}
```

---

## 5. 🟡 Amélioration: Vérification Expiration JWT

### Solution
```dart
import 'package:jwt_decoder/jwt_decoder.dart';

extension TokenValidator on String {
  bool get isExpired {
    try {
      final decodedToken = JwtDecoder.decode(this);
      return JwtDecoder.isExpired(this);
    } catch (_) {
      return true; // Token invalide = expiré
    }
  }
  
  Duration get remainingTime {
    try {
      return JwtDecoder.getRemainingTime(this);
    } catch (_) {
      return Duration.zero;
    }
  }
}

// Usage dans AuthRepository
@override
Future<Either<Failure, UserEntity>> getCurrentUser() async {
  final token = await localDataSource.getToken();
  
  if (token == null || token.isExpired) {
    await localDataSource.clearAuthData();
    return Left(UnauthorizedFailure('Session expirée'));
  }
  
  // ... continuer avec le token valide
}
```

---

## 6. ✅ Checklist d'Implémentation

### Phase 1 (Urgent)
- [ ] Créer `AuthInterceptor` pour logout auto sur 401
- [ ] Tester le flow de session expirée

### Phase 2 (Important)
- [ ] Implémenter refresh token côté backend
- [ ] Ajouter `TokenRefreshInterceptor`
- [ ] Migrer vers `flutter_secure_storage`

### Phase 3 (Nice to have)
- [ ] Vérification expiration JWT client-side
- [ ] Refresh proactif avant expiration
- [ ] Biometric authentication pour unlock

---

## 7. 📁 Fichiers Modifiés/Créés

| Fichier | Action |
|---------|--------|
| `lib/core/network/auth_interceptor.dart` | CRÉER |
| `lib/core/network/api_client.dart` | MODIFIER (ajouter intercepteur) |
| `lib/features/auth/data/datasources/auth_local_datasource.dart` | MODIFIER (secure storage) |

---

## 8. 🧪 Tests Recommandés

```dart
group('Auth Security Tests', () {
  test('should logout on 401 from protected route', () async {
    // Simuler un 401 sur /orders
    // Vérifier que l'utilisateur est déconnecté
  });
  
  test('should refresh token before expiration', () async {
    // Simuler token proche expiration
    // Vérifier que le refresh est appelé
  });
  
  test('should store token securely', () async {
    // Vérifier que le token n'est pas en clair
  });
});
```
