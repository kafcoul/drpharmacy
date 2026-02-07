import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/core/config/env_config.dart';

void main() {
  // Note: Ces tests vérifient le comportement par défaut de EnvConfig
  // quand .env n'est pas chargé (cas du CI et des tests)
  
  group('EnvConfig - Default Behavior', () {
    setUpAll(() async {
      // Initialiser EnvConfig (va utiliser les valeurs par défaut si .env absent)
      await EnvConfig.init();
    });

    group('API URLs', () {
      test('apiUrl should contain /api suffix', () {
        expect(EnvConfig.apiUrl, contains('/api'));
      });

      test('apiBaseUrl should return a valid URL', () {
        expect(EnvConfig.apiBaseUrl, isNotEmpty);
        expect(
          EnvConfig.apiBaseUrl.startsWith('http://') || 
          EnvConfig.apiBaseUrl.startsWith('https://'),
          isTrue,
        );
      });

      test('storageBaseUrl should return a valid URL', () {
        expect(EnvConfig.storageBaseUrl, isNotEmpty);
        expect(
          EnvConfig.storageBaseUrl.startsWith('http://') || 
          EnvConfig.storageBaseUrl.startsWith('https://'),
          isTrue,
        );
      });
    });

    group('Environment Detection', () {
      test('environment should return a valid environment string', () {
        expect(
          ['development', 'staging', 'production'],
          contains(EnvConfig.environment),
        );
      });

      test('isDevelopment/isStaging/isProduction should be mutually exclusive', () {
        final envFlags = [
          EnvConfig.isDevelopment,
          EnvConfig.isStaging,
          EnvConfig.isProduction,
        ];
        
        // Au moins un doit être true
        expect(envFlags.any((flag) => flag), isTrue);
        
        // Exactement un doit être true
        expect(envFlags.where((flag) => flag).length, equals(1));
      });
    });

    group('Timeouts', () {
      test('connectionTimeout should be positive', () {
        expect(EnvConfig.connectionTimeout.inMilliseconds, greaterThan(0));
      });

      test('receiveTimeout should be positive', () {
        expect(EnvConfig.receiveTimeout.inMilliseconds, greaterThan(0));
      });

      test('timeouts should be reasonable (between 5s and 2min)', () {
        expect(EnvConfig.connectionTimeout.inSeconds, greaterThanOrEqualTo(5));
        expect(EnvConfig.connectionTimeout.inSeconds, lessThanOrEqualTo(120));
        expect(EnvConfig.receiveTimeout.inSeconds, greaterThanOrEqualTo(5));
        expect(EnvConfig.receiveTimeout.inSeconds, lessThanOrEqualTo(120));
      });
    });

    group('Security', () {
      test('forceHttps should be true in production', () {
        // Si on est en production, HTTPS doit être forcé
        if (EnvConfig.isProduction) {
          expect(EnvConfig.forceHttps, isTrue);
        }
      });

      test('debugMode should be false in production', () {
        // Si on est en production, debug devrait être désactivé
        if (EnvConfig.isProduction) {
          expect(EnvConfig.debugMode, isFalse);
        }
      });
    });

    group('Google Maps', () {
      test('googleMapsApiKey should return a string (can be empty)', () {
        expect(EnvConfig.googleMapsApiKey, isA<String>());
      });
    });

    group('Initialization', () {
      test('init should not throw', () async {
        // Should complete without exception
        await expectLater(EnvConfig.init(), completes);
      });

      test('multiple init calls should be safe', () async {
        // Should not throw on multiple calls
        await EnvConfig.init();
        await EnvConfig.init();
        expect(true, isTrue); // If we get here, no exception was thrown
      });
    });
  });
}
