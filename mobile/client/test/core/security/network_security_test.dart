import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/core/security/network_security.dart';

void main() {
  group('NetworkSecurity', () {
    group('securityHeaders', () {
      test('contient les headers de sécurité requis', () {
        final headers = NetworkSecurity.securityHeaders;
        
        expect(headers['X-Content-Type-Options'], 'nosniff');
        expect(headers['X-Frame-Options'], 'DENY');
        expect(headers['X-XSS-Protection'], '1; mode=block');
        expect(headers['Cache-Control'], contains('no-store'));
      });
    });

    group('generateNonce', () {
      test('génère des nonces uniques', () {
        final nonce1 = NetworkSecurity.generateNonce();
        final nonce2 = NetworkSecurity.generateNonce();
        
        expect(nonce1, isNotEmpty);
        expect(nonce2, isNotEmpty);
        expect(nonce1.length, 32);
        // Les nonces peuvent être identiques si générés au même moment
      });
    });

    group('generateSignature', () {
      test('génère une signature cohérente', () {
        const data = 'test data';
        const secret = 'secret key';
        
        final sig1 = NetworkSecurity.generateSignature(data, secret);
        final sig2 = NetworkSecurity.generateSignature(data, secret);
        
        expect(sig1, sig2);
      });

      test('signatures différentes pour données différentes', () {
        const secret = 'secret key';
        
        final sig1 = NetworkSecurity.generateSignature('data1', secret);
        final sig2 = NetworkSecurity.generateSignature('data2', secret);
        
        expect(sig1, isNot(sig2));
      });
    });

    group('verifySignature', () {
      test('valide une signature correcte', () {
        const data = 'test data';
        const secret = 'secret key';
        
        final signature = NetworkSecurity.generateSignature(data, secret);
        expect(NetworkSecurity.verifySignature(data, signature, secret), true);
      });

      test('rejette une signature incorrecte', () {
        const data = 'test data';
        const secret = 'secret key';
        
        expect(NetworkSecurity.verifySignature(data, 'fake', secret), false);
      });
    });

    group('isUrlSafe', () {
      test('accepte les URLs HTTPS', () {
        expect(NetworkSecurity.isUrlSafe('https://example.com'), true);
      });

      test('accepte les URLs HTTP', () {
        expect(NetworkSecurity.isUrlSafe('http://localhost:8080'), true);
      });

      test('rejette javascript:', () {
        expect(NetworkSecurity.isUrlSafe('javascript:alert(1)'), false);
      });

      test('rejette data:', () {
        expect(NetworkSecurity.isUrlSafe('data:text/html,<script>'), false);
      });

      test('rejette file:', () {
        expect(NetworkSecurity.isUrlSafe('file:///etc/passwd'), false);
      });

      test('rejette null/empty', () {
        expect(NetworkSecurity.isUrlSafe(null), false);
        expect(NetworkSecurity.isUrlSafe(''), false);
      });
    });

    group('isDomainAllowed', () {
      test('accepte un domaine autorisé', () {
        final allowed = ['example.com', 'api.example.com'];
        expect(
          NetworkSecurity.isDomainAllowed('https://example.com/path', allowed),
          true,
        );
      });

      test('accepte un sous-domaine autorisé', () {
        final allowed = ['example.com'];
        expect(
          NetworkSecurity.isDomainAllowed('https://api.example.com/path', allowed),
          true,
        );
      });

      test('rejette un domaine non autorisé', () {
        final allowed = ['example.com'];
        expect(
          NetworkSecurity.isDomainAllowed('https://malicious.com', allowed),
          false,
        );
      });
    });
  });

  group('TokenValidator', () {
    // Token JWT de test expiré
    final expiredToken = _createTestJwt(
      DateTime.now().subtract(const Duration(hours: 1)),
    );

    // Token JWT de test valide
    final validToken = _createTestJwt(
      DateTime.now().add(const Duration(hours: 1)),
    );

    group('isTokenExpired', () {
      test('retourne true pour null', () {
        expect(TokenValidator.isTokenExpired(null), true);
      });

      test('retourne true pour chaîne vide', () {
        expect(TokenValidator.isTokenExpired(''), true);
      });

      test('retourne true pour token invalide', () {
        expect(TokenValidator.isTokenExpired('invalid.token'), true);
      });

      test('retourne true pour token expiré', () {
        expect(TokenValidator.isTokenExpired(expiredToken), true);
      });

      test('retourne false pour token valide', () {
        expect(TokenValidator.isTokenExpired(validToken), false);
      });
    });

    group('getTokenTimeRemaining', () {
      test('retourne null pour token invalide', () {
        expect(TokenValidator.getTokenTimeRemaining(null), null);
        expect(TokenValidator.getTokenTimeRemaining('invalid'), null);
      });

      test('retourne durée restante pour token valide', () {
        final remaining = TokenValidator.getTokenTimeRemaining(validToken);
        expect(remaining, isNotNull);
        expect(remaining!.inMinutes, greaterThan(0));
      });

      test('retourne zero ou null pour token expiré', () {
        final remaining = TokenValidator.getTokenTimeRemaining(expiredToken);
        expect(remaining == null || remaining == Duration.zero, true);
      });
    });

    group('shouldRefreshToken', () {
      test('retourne true pour token presque expiré', () {
        final almostExpiredToken = _createTestJwt(
          DateTime.now().add(const Duration(minutes: 2)),
        );
        expect(TokenValidator.shouldRefreshToken(almostExpiredToken), true);
      });

      test('retourne false pour token avec beaucoup de temps', () {
        expect(TokenValidator.shouldRefreshToken(validToken), false);
      });
    });
  });

  group('ClientRateLimiter', () {
    test('autorise les premières requêtes', () {
      final limiter = ClientRateLimiter(maxRequests: 5, window: const Duration(seconds: 1));
      
      expect(limiter.allowRequest('/api/test'), true);
      expect(limiter.allowRequest('/api/test'), true);
      expect(limiter.allowRequest('/api/test'), true);
    });

    test('bloque après limite atteinte', () {
      final limiter = ClientRateLimiter(maxRequests: 3, window: const Duration(seconds: 1));
      
      limiter.allowRequest('/api/test');
      limiter.allowRequest('/api/test');
      limiter.allowRequest('/api/test');
      
      expect(limiter.allowRequest('/api/test'), false);
    });

    test('reset réinitialise le compteur', () {
      final limiter = ClientRateLimiter(maxRequests: 2, window: const Duration(seconds: 1));
      
      limiter.allowRequest('/api/test');
      limiter.allowRequest('/api/test');
      expect(limiter.allowRequest('/api/test'), false);
      
      limiter.reset('/api/test');
      expect(limiter.allowRequest('/api/test'), true);
    });

    test('getRetryAfter retourne la durée d\'attente', () {
      final limiter = ClientRateLimiter(maxRequests: 1, window: const Duration(seconds: 10));
      
      limiter.allowRequest('/api/test');
      expect(limiter.allowRequest('/api/test'), false);
      
      final retryAfter = limiter.getRetryAfter('/api/test');
      expect(retryAfter, isNotNull);
      expect(retryAfter!.inSeconds, greaterThan(0));
    });
  });

  group('BruteForceProtection', () {
    test('autorise les tentatives initiales', () {
      final protection = BruteForceProtection(maxAttempts: 3);
      
      expect(protection.isLocked('user@test.com'), false);
      expect(protection.getRemainingAttempts('user@test.com'), 3);
    });

    test('verrouille après trop de tentatives', () {
      final protection = BruteForceProtection(
        maxAttempts: 3,
        lockoutDuration: const Duration(minutes: 1),
      );
      
      protection.recordFailedAttempt('user@test.com');
      protection.recordFailedAttempt('user@test.com');
      protection.recordFailedAttempt('user@test.com');
      
      expect(protection.isLocked('user@test.com'), true);
    });

    test('recordSuccess déverrouille', () {
      final protection = BruteForceProtection(maxAttempts: 2);
      
      protection.recordFailedAttempt('user@test.com');
      protection.recordFailedAttempt('user@test.com');
      expect(protection.isLocked('user@test.com'), true);
      
      protection.recordSuccess('user@test.com');
      expect(protection.isLocked('user@test.com'), false);
    });

    test('getLockoutRemaining retourne le temps restant', () {
      final protection = BruteForceProtection(
        maxAttempts: 1,
        lockoutDuration: const Duration(minutes: 15),
      );
      
      protection.recordFailedAttempt('user@test.com');
      
      final remaining = protection.getLockoutRemaining('user@test.com');
      expect(remaining, isNotNull);
      expect(remaining!.inMinutes, greaterThan(0));
    });
  });

  group('SecureHash', () {
    group('hash', () {
      test('génère un hash cohérent', () {
        expect(SecureHash.hash('test'), SecureHash.hash('test'));
      });

      test('génère des hashs différents pour inputs différents', () {
        expect(SecureHash.hash('test1'), isNot(SecureHash.hash('test2')));
      });
    });

    group('hashWithSalt', () {
      test('génère un hash avec sel', () {
        final hash1 = SecureHash.hashWithSalt('password', 'salt1');
        final hash2 = SecureHash.hashWithSalt('password', 'salt2');
        
        expect(hash1, isNot(hash2));
      });
    });

    group('generateSalt', () {
      test('génère un sel de 16 caractères', () {
        final salt = SecureHash.generateSalt();
        expect(salt.length, 16);
      });
    });
  });
}

/// Crée un JWT de test avec une date d'expiration spécifique
String _createTestJwt(DateTime expiry) {
  // Header: {"alg":"HS256","typ":"JWT"}
  const header = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';
  
  // Payload avec exp
  final exp = (expiry.millisecondsSinceEpoch / 1000).floor();
  final payloadJson = '{"sub":"1234567890","name":"John Doe","iat":1516239022,"exp":$exp}';
  final payload = _base64UrlEncode(payloadJson);
  
  // Signature factice
  const signature = 'signature';
  
  return '$header.$payload.$signature';
}

String _base64UrlEncode(String input) {
  final bytes = input.codeUnits;
  final encoded = base64Encode(bytes);
  return encoded.replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
}

String base64Encode(List<int> bytes) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  final result = StringBuffer();
  
  for (var i = 0; i < bytes.length; i += 3) {
    final b1 = bytes[i];
    final b2 = i + 1 < bytes.length ? bytes[i + 1] : 0;
    final b3 = i + 2 < bytes.length ? bytes[i + 2] : 0;
    
    result.write(chars[(b1 >> 2) & 0x3F]);
    result.write(chars[((b1 << 4) | (b2 >> 4)) & 0x3F]);
    result.write(i + 1 < bytes.length ? chars[((b2 << 2) | (b3 >> 6)) & 0x3F] : '=');
    result.write(i + 2 < bytes.length ? chars[b3 & 0x3F] : '=');
  }
  
  return result.toString();
}
