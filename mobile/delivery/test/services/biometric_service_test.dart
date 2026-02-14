import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:courier_flutter/core/services/biometric_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BiometricService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = BiometricService();
  });

  // ── isBiometricEnabled / setBiometricEnabled ────────
  group('biometric preferences', () {
    test('isBiometricEnabled returns false by default', () async {
      final result = await service.isBiometricEnabled();
      expect(result, isFalse);
    });

    test('setBiometricEnabled true then read', () async {
      await service.setBiometricEnabled(true);
      final result = await service.isBiometricEnabled();
      expect(result, isTrue);
    });

    test('setBiometricEnabled false after true', () async {
      await service.setBiometricEnabled(true);
      await service.setBiometricEnabled(false);
      final result = await service.isBiometricEnabled();
      expect(result, isFalse);
    });
  });

  // ── saveAuthToken / getStoredAuthToken / clearAuthToken
  group('auth token storage', () {
    test('getStoredAuthToken returns null when no token', () async {
      final token = await service.getStoredAuthToken();
      expect(token, isNull);
    });

    test('saveAuthToken then retrieve', () async {
      await service.saveAuthToken('my-token-123');
      final token = await service.getStoredAuthToken();
      expect(token, 'my-token-123');
    });

    test('clearAuthToken removes token', () async {
      await service.saveAuthToken('tok');
      await service.clearAuthToken();
      final token = await service.getStoredAuthToken();
      expect(token, isNull);
    });
  });

  // ── quickLogin ──────────────────────────────────────
  group('quickLogin', () {
    test('returns null when biometric not enabled', () async {
      final result = await service.quickLogin();
      expect(result, isNull);
    });

    test('returns null when enabled but no token stored', () async {
      await service.setBiometricEnabled(true);
      final result = await service.quickLogin();
      expect(result, isNull);
    });

    // When both enabled and token exists, authenticate() will be called
    // which uses LocalAuthentication plugin — in VM test it triggers
    // MissingPluginException → authenticate returns false → quickLogin returns null
    test('returns null when auth fails (MissingPlugin)', () async {
      await service.setBiometricEnabled(true);
      await service.saveAuthToken('stored-tok');
      final result = await service.quickLogin();
      expect(result, isNull);
    });
  });

  // ── canCheckBiometrics ──────────────────────────────
  // In VM tests, LocalAuthentication plugin is not available,
  // so MissingPluginException is thrown → returns false
  group('canCheckBiometrics', () {
    test('returns false when plugin not available', () async {
      final result = await service.canCheckBiometrics();
      expect(result, isFalse);
    });
  });

  // ── isDeviceSupported ───────────────────────────────
  group('isDeviceSupported', () {
    test('returns false when plugin not available', () async {
      final result = await service.isDeviceSupported();
      expect(result, isFalse);
    });
  });

  // ── hasBiometrics ───────────────────────────────────
  group('hasBiometrics', () {
    test('returns false when plugin not available', () async {
      final result = await service.hasBiometrics();
      expect(result, isFalse);
    });
  });

  // ── getAvailableBiometrics ──────────────────────────
  group('getAvailableBiometrics', () {
    test('returns empty when plugin not available', () async {
      final result = await service.getAvailableBiometrics();
      expect(result, isEmpty);
    });
  });

  // ── getPrimaryBiometricType ─────────────────────────
  group('getPrimaryBiometricType', () {
    test('returns none when no biometrics available', () async {
      final result = await service.getPrimaryBiometricType();
      expect(result, AppBiometricType.none);
    });
  });

  // ── getBiometricName ────────────────────────────────
  group('getBiometricName', () {
    test('returns correct name for fingerprint', () {
      expect(service.getBiometricName(AppBiometricType.fingerprint), 'Empreinte digitale');
    });

    test('returns correct name for faceId', () {
      expect(service.getBiometricName(AppBiometricType.faceId), 'Face ID');
    });

    test('returns correct name for iris', () {
      expect(service.getBiometricName(AppBiometricType.iris), 'Iris');
    });

    test('returns correct name for none', () {
      expect(service.getBiometricName(AppBiometricType.none), 'Non disponible');
    });
  });

  // ── authenticate ────────────────────────────────────
  group('authenticate', () {
    test('returns false when plugin not available', () async {
      final result = await service.authenticate();
      expect(result, isFalse);
    });

    test('returns false with custom reason when plugin not available', () async {
      final result = await service.authenticate(reason: 'Custom reason');
      expect(result, isFalse);
    });
  });

  // ── AppBiometricType enum ───────────────────────────
  group('AppBiometricType', () {
    test('has all expected values', () {
      expect(AppBiometricType.values, hasLength(4));
      expect(AppBiometricType.values, contains(AppBiometricType.fingerprint));
      expect(AppBiometricType.values, contains(AppBiometricType.faceId));
      expect(AppBiometricType.values, contains(AppBiometricType.iris));
      expect(AppBiometricType.values, contains(AppBiometricType.none));
    });
  });

  // ── BiometricSettingsNotifier ───────────────────────
  // Note: Full Notifier testing requires a ProviderContainer
  // but the core prefs logic is tested via BiometricService above
}
