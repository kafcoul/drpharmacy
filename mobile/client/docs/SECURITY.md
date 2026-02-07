# 🔒 Guide de Sécurité

## Vue d'ensemble

Ce guide documente les pratiques de sécurité implémentées dans l'application DR-PHARMA.

## 📁 Fichiers de Sécurité

```
lib/core/security/
├── input_sanitizer.dart      # Sanitisation des entrées
├── network_security.dart     # Sécurité réseau
└── security.dart             # Export barrel
```

---

## 1. Sanitisation des Entrées

### InputSanitizer

Protège contre les injections XSS, SQL et autres attaques.

```dart
import 'package:drpharma_client/core/security/security.dart';

// Sanitisation générale
final safe = InputSanitizer.sanitize(userInput);

// Sanitisation spécifique par type
final email = InputSanitizer.sanitizeEmail(input);
final phone = InputSanitizer.sanitizePhone(input);
final name = InputSanitizer.sanitizeName(input);
final address = InputSanitizer.sanitizeAddress(input);
final amount = InputSanitizer.sanitizeAmount(input);
final otp = InputSanitizer.sanitizeOtp(input);
final search = InputSanitizer.sanitizeSearchQuery(input);
```

### Patterns Détectés

| Type | Exemples bloqués |
|------|------------------|
| XSS | `<script>`, `javascript:`, `onclick=` |
| SQL Injection | `' OR '1'='1`, `; DROP TABLE` |
| Protocoles dangereux | `data:`, `vbscript:`, `file:` |

### Extensions Pratiques

```dart
// Extensions sur String?
final sanitized = userInput.sanitized;
final email = input.sanitizedEmail;
final phone = input.sanitizedPhone;
final name = input.sanitizedName;

// Vérification de contenu malveillant
if (input.isMalicious) {
  // Rejeter l'entrée
}
```

---

## 2. Validation Sécurisée

### SecureValidator

Combine validation et sanitisation en une seule opération.

```dart
// Validation d'email
final result = SecureValidator.validateEmail('test@example.com');
if (result.isValid) {
  final cleanEmail = result.sanitizedValue;
} else {
  showError(result.error!);
}

// Validation de téléphone (format Gabon)
final phoneResult = SecureValidator.validatePhone('+241071234567');

// Validation de nom
final nameResult = SecureValidator.validateName(
  input,
  fieldName: 'Prénom',
  minLength: 2,
  maxLength: 50,
);

// Validation d'adresse
final addressResult = SecureValidator.validateAddress(input);

// Validation OTP
final otpResult = SecureValidator.validateOtp(code, length: 6);

// Validation montant
final amountResult = SecureValidator.validateAmount(
  input,
  min: 100,
  max: 1000000,
);
```

### ValidationResult

```dart
class ValidationResult {
  final bool isValid;
  final String? error;
  final String sanitizedValue;
  
  // Pour les formulaires Flutter
  String? get errorOrNull => isValid ? null : error;
}

// Utilisation dans un formulaire
TextFormField(
  validator: (value) {
    return SecureValidator.validateEmail(value).errorOrNull;
  },
)
```

---

## 3. Sécurité Réseau

### Headers de Sécurité

```dart
// Ajouter automatiquement les headers de sécurité
final headers = NetworkSecurity.securityHeaders;
// Inclut: X-Content-Type-Options, X-Frame-Options, X-XSS-Protection, etc.
```

### Génération de Nonce CSRF

```dart
final nonce = NetworkSecurity.generateNonce();
// Utiliser pour protéger contre les attaques CSRF
```

### Signatures HMAC

```dart
// Signer des données sensibles
final signature = NetworkSecurity.generateSignature(data, secret);

// Vérifier une signature
final isValid = NetworkSecurity.verifySignature(data, signature, secret);
```

### Validation d'URLs

```dart
// Vérifier qu'une URL est sûre
if (NetworkSecurity.isUrlSafe(url)) {
  // OK pour naviguer
}

// Vérifier le domaine autorisé
final allowedDomains = ['api.drpharma.com', 'cdn.drpharma.com'];
if (NetworkSecurity.isDomainAllowed(url, allowedDomains)) {
  // OK
}
```

---

## 4. Validation de Tokens JWT

### TokenValidator

```dart
// Vérifier si un token est expiré
if (TokenValidator.isTokenExpired(token)) {
  // Rediriger vers login
}

// Temps restant avant expiration
final remaining = TokenValidator.getTokenTimeRemaining(token);
print('Expire dans: ${remaining?.inMinutes} minutes');

// Vérifier si rafraîchissement nécessaire (< 5 min)
if (TokenValidator.shouldRefreshToken(token)) {
  await refreshToken();
}
```

---

## 5. Rate Limiting Client

### ClientRateLimiter

Empêche le spam de requêtes côté client.

```dart
final rateLimiter = ClientRateLimiter(
  maxRequests: 60,
  window: const Duration(minutes: 1),
);

// Avant chaque requête
if (rateLimiter.allowRequest('/api/search')) {
  // Effectuer la requête
} else {
  final retryAfter = rateLimiter.getRetryAfter('/api/search');
  showError('Trop de requêtes. Réessayez dans ${retryAfter?.inSeconds}s');
}

// Réinitialiser après succès
rateLimiter.reset('/api/search');
```

---

## 6. Protection Brute Force

### BruteForceProtection

Protège les formulaires de connexion contre les attaques par force brute.

```dart
final bruteForce = BruteForceProtection(
  maxAttempts: 5,
  lockoutDuration: const Duration(minutes: 15),
  attemptWindow: const Duration(minutes: 5),
);

// Vérifier avant tentative
if (bruteForce.isLocked(email)) {
  final remaining = bruteForce.getLockoutRemaining(email);
  showError('Compte verrouillé. Réessayez dans ${remaining?.inMinutes} min');
  return;
}

// Après échec
bruteForce.recordFailedAttempt(email);
final remaining = bruteForce.getRemainingAttempts(email);
showWarning('Tentatives restantes: $remaining');

// Après succès
bruteForce.recordSuccess(email);
```

---

## 7. Hachage Sécurisé

### SecureHash

Pour le hachage de données sensibles stockées localement.

```dart
// Hachage simple
final hash = SecureHash.hash(sensitiveData);

// Hachage avec sel
final salt = SecureHash.generateSalt();
final saltedHash = SecureHash.hashWithSalt(password, salt);

// Stocker: salt + hash
```

---

## 8. Bonnes Pratiques

### ✅ À faire

```dart
// 1. Toujours sanitiser les entrées utilisateur
final searchTerm = InputSanitizer.sanitizeSearchQuery(userInput);

// 2. Valider côté client ET serveur
final result = SecureValidator.validateEmail(email);
if (!result.isValid) return;
await api.register(result.sanitizedValue); // Serveur valide aussi

// 3. Utiliser HTTPS uniquement
if (!NetworkSecurity.isUrlSafe(url)) {
  throw SecurityException('URL non sécurisée');
}

// 4. Vérifier les tokens avant utilisation
if (TokenValidator.isTokenExpired(token)) {
  await refreshOrLogout();
}

// 5. Protéger les formulaires sensibles
if (bruteForce.isLocked(identifier)) {
  return showLockoutMessage();
}
```

### ❌ À éviter

```dart
// 1. NE PAS afficher les entrées utilisateur sans sanitisation
Text(userInput); // ❌ Risque XSS
Text(InputSanitizer.sanitizeForDisplay(userInput)); // ✅

// 2. NE PAS stocker de secrets en clair
SharedPreferences.setString('token', token); // ❌
FlutterSecureStorage().write(key: 'token', value: token); // ✅

// 3. NE PAS ignorer les erreurs de validation
if (email.contains('@')) { /* ... */ } // ❌
SecureValidator.validateEmail(email); // ✅

// 4. NE PAS faire confiance aux données du client
final price = double.parse(userInput); // ❌
// Toujours recalculer côté serveur
```

---

## 9. Checklist Sécurité

### Avant déploiement

- [ ] Toutes les entrées utilisateur sont sanitisées
- [ ] Les tokens sont stockés dans SecureStorage
- [ ] HTTPS est forcé pour toutes les requêtes
- [ ] Les headers de sécurité sont présents
- [ ] Le rate limiting est actif
- [ ] Les logs ne contiennent pas de données sensibles
- [ ] Les clés API ne sont pas dans le code source
- [ ] ProGuard/R8 est activé pour Android
- [ ] Les erreurs ne révèlent pas d'informations sensibles

### Tests de sécurité

```bash
# Lancer les tests de sécurité
flutter test test/core/security/
```

---

## 10. Ressources

- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [Flutter Security Best Practices](https://flutter.dev/docs/security)
- [Dart Secure Coding](https://dart.dev/guides/language/effective-dart/usage#security)

---

*Voir aussi : [ARCHITECTURE.md](./ARCHITECTURE.md), [TESTING.md](./TESTING.md)*
