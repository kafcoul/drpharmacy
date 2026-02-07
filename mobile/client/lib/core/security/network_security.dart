/// Service de sécurité pour les requêtes réseau
/// Protection contre les attaques MITM, validation des certificats, etc.
library;

import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utilitaires de sécurité réseau
class NetworkSecurity {
  NetworkSecurity._();

  /// Headers de sécurité recommandés pour les requêtes
  static Map<String, String> get securityHeaders => {
        'X-Content-Type-Options': 'nosniff',
        'X-Frame-Options': 'DENY',
        'X-XSS-Protection': '1; mode=block',
        'Cache-Control': 'no-store, no-cache, must-revalidate',
        'Pragma': 'no-cache',
      };

  /// Génère un nonce pour les requêtes (protection CSRF)
  static String generateNonce() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    final combined = '$now-$random';
    return sha256.convert(utf8.encode(combined)).toString().substring(0, 32);
  }

  /// Génère une signature pour les données sensibles
  static String generateSignature(String data, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    return hmac.convert(bytes).toString();
  }

  /// Vérifie une signature
  static bool verifySignature(String data, String signature, String secret) {
    final expectedSignature = generateSignature(data, secret);
    return _secureCompare(signature, expectedSignature);
  }

  /// Comparaison sécurisée (timing-safe)
  static bool _secureCompare(String a, String b) {
    if (a.length != b.length) return false;
    
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Valide qu'une URL est sûre (pas de schémas dangereux)
  static bool isUrlSafe(String? url) {
    if (url == null || url.isEmpty) return false;

    final lowered = url.toLowerCase().trim();

    // Schémas dangereux
    const dangerousSchemes = [
      'javascript:',
      'data:',
      'vbscript:',
      'file:',
      'about:',
    ];

    for (final scheme in dangerousSchemes) {
      if (lowered.startsWith(scheme)) return false;
    }

    // Vérifier que c'est une URL HTTP(S) valide
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'http' || uri.scheme == 'https';
    } catch (_) {
      return false;
    }
  }

  /// Valide un domaine autorisé
  static bool isDomainAllowed(String url, List<String> allowedDomains) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();
      
      for (final domain in allowedDomains) {
        if (host == domain || host.endsWith('.$domain')) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

/// Service de validation des tokens
class TokenValidator {
  TokenValidator._();

  /// Vérifie si un token JWT est expiré (sans vérification de signature)
  static bool isTokenExpired(String? token) {
    if (token == null || token.isEmpty) return true;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = jsonDecode(decoded) as Map<String, dynamic>;

      final exp = data['exp'] as int?;
      if (exp == null) return true;

      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiry);
    } catch (_) {
      return true;
    }
  }

  /// Extrait le temps restant avant expiration
  static Duration? getTokenTimeRemaining(String? token) {
    if (token == null || token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = jsonDecode(decoded) as Map<String, dynamic>;

      final exp = data['exp'] as int?;
      if (exp == null) return null;

      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final remaining = expiry.difference(DateTime.now());
      
      return remaining.isNegative ? Duration.zero : remaining;
    } catch (_) {
      return null;
    }
  }

  /// Vérifie si le token doit être rafraîchi (moins de 5 minutes restantes)
  static bool shouldRefreshToken(String? token, {Duration threshold = const Duration(minutes: 5)}) {
    final remaining = getTokenTimeRemaining(token);
    if (remaining == null) return true;
    return remaining < threshold;
  }
}

/// Service de rate limiting côté client
class ClientRateLimiter {
  final Map<String, List<DateTime>> _requests = {};
  final int maxRequests;
  final Duration window;

  ClientRateLimiter({
    this.maxRequests = 60,
    this.window = const Duration(minutes: 1),
  });

  /// Vérifie si une requête est autorisée
  bool allowRequest(String endpoint) {
    final now = DateTime.now();
    final key = _normalizeEndpoint(endpoint);

    // Nettoyer les anciennes requêtes
    _requests[key] = (_requests[key] ?? [])
        .where((time) => now.difference(time) < window)
        .toList();

    // Vérifier la limite
    if ((_requests[key]?.length ?? 0) >= maxRequests) {
      return false;
    }

    // Enregistrer la requête
    _requests[key] = [...(_requests[key] ?? []), now];
    return true;
  }

  /// Temps restant avant de pouvoir faire une nouvelle requête
  Duration? getRetryAfter(String endpoint) {
    final key = _normalizeEndpoint(endpoint);
    final requests = _requests[key];
    
    if (requests == null || requests.isEmpty) return null;
    if (requests.length < maxRequests) return null;

    final oldest = requests.first;
    final unlockTime = oldest.add(window);
    final remaining = unlockTime.difference(DateTime.now());

    return remaining.isNegative ? null : remaining;
  }

  /// Réinitialise le compteur pour un endpoint
  void reset(String endpoint) {
    final key = _normalizeEndpoint(endpoint);
    _requests.remove(key);
  }

  /// Réinitialise tous les compteurs
  void resetAll() {
    _requests.clear();
  }

  String _normalizeEndpoint(String endpoint) {
    // Normaliser l'endpoint pour grouper les requêtes similaires
    try {
      final uri = Uri.parse(endpoint);
      return uri.path;
    } catch (_) {
      return endpoint;
    }
  }
}

/// Service de protection contre les attaques par force brute
class BruteForceProtection {
  final Map<String, _AttemptTracker> _trackers = {};
  final int maxAttempts;
  final Duration lockoutDuration;
  final Duration attemptWindow;

  BruteForceProtection({
    this.maxAttempts = 5,
    this.lockoutDuration = const Duration(minutes: 15),
    this.attemptWindow = const Duration(minutes: 5),
  });

  /// Enregistre une tentative échouée
  void recordFailedAttempt(String identifier) {
    final now = DateTime.now();
    final tracker = _trackers[identifier] ?? _AttemptTracker();

    // Nettoyer les anciennes tentatives
    tracker.attempts = tracker.attempts
        .where((time) => now.difference(time) < attemptWindow)
        .toList();

    tracker.attempts.add(now);

    // Verrouiller si trop de tentatives
    if (tracker.attempts.length >= maxAttempts) {
      tracker.lockedUntil = now.add(lockoutDuration);
    }

    _trackers[identifier] = tracker;
  }

  /// Vérifie si l'identifiant est verrouillé
  bool isLocked(String identifier) {
    final tracker = _trackers[identifier];
    if (tracker == null) return false;

    final lockedUntil = tracker.lockedUntil;
    if (lockedUntil == null) return false;

    if (DateTime.now().isAfter(lockedUntil)) {
      // Débloquer
      _trackers.remove(identifier);
      return false;
    }

    return true;
  }

  /// Temps restant de verrouillage
  Duration? getLockoutRemaining(String identifier) {
    final tracker = _trackers[identifier];
    if (tracker?.lockedUntil == null) return null;

    final remaining = tracker!.lockedUntil!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  /// Tentatives restantes
  int getRemainingAttempts(String identifier) {
    final tracker = _trackers[identifier];
    if (tracker == null) return maxAttempts;

    final now = DateTime.now();
    final recentAttempts = tracker.attempts
        .where((time) => now.difference(time) < attemptWindow)
        .length;

    return (maxAttempts - recentAttempts).clamp(0, maxAttempts);
  }

  /// Réinitialise après succès
  void recordSuccess(String identifier) {
    _trackers.remove(identifier);
  }
}

class _AttemptTracker {
  List<DateTime> attempts = [];
  DateTime? lockedUntil;
}

/// Service de hachage sécurisé pour données sensibles locales
class SecureHash {
  SecureHash._();

  /// Hache une chaîne avec SHA-256
  static String hash(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  /// Hache avec un sel
  static String hashWithSalt(String input, String salt) {
    return sha256.convert(utf8.encode('$salt:$input')).toString();
  }

  /// Génère un sel aléatoire
  static String generateSalt() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return sha256.convert(utf8.encode('$now')).toString().substring(0, 16);
  }
}
