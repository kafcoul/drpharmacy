import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de sécurité pour l'application
/// Gère l'authentification biométrique, le session timeout, et le chiffrement
class SecurityService {
  final SharedPreferences _prefs;
  
  // Clés de stockage
  static const String _keyBiometricEnabled = 'security_biometric_enabled';
  static const String _keyLastActivity = 'security_last_activity';
  static const String _keySessionTimeout = 'security_session_timeout';
  static const String _keyPinEnabled = 'security_pin_enabled';
  static const String _keyPinHash = 'security_pin_hash';
  static const String _keyFailedAttempts = 'security_failed_attempts';
  static const String _keyLockoutUntil = 'security_lockout_until';
  
  // Configuration par défaut
  static const Duration defaultSessionTimeout = Duration(minutes: 15);
  static const int maxFailedAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 30);

  Timer? _sessionTimer;
  VoidCallback? _onSessionExpired;

  SecurityService(this._prefs);

  /// Configure le callback pour l'expiration de session
  void setSessionExpiredCallback(VoidCallback callback) {
    _onSessionExpired = callback;
  }

  // ==================== SESSION MANAGEMENT ====================

  /// Met à jour l'horodatage de la dernière activité
  Future<void> updateActivity() async {
    await _prefs.setString(
      _keyLastActivity,
      DateTime.now().toIso8601String(),
    );
    _resetSessionTimer();
  }

  /// Vérifie si la session est toujours valide
  bool isSessionValid() {
    final lastActivityStr = _prefs.getString(_keyLastActivity);
    if (lastActivityStr == null) return false;

    final lastActivity = DateTime.parse(lastActivityStr);
    final timeout = getSessionTimeout();
    
    return DateTime.now().isBefore(lastActivity.add(timeout));
  }

  /// Retourne la durée du timeout de session
  Duration getSessionTimeout() {
    final minutes = _prefs.getInt(_keySessionTimeout) ?? defaultSessionTimeout.inMinutes;
    return Duration(minutes: minutes);
  }

  /// Définit la durée du timeout de session
  Future<void> setSessionTimeout(Duration timeout) async {
    await _prefs.setInt(_keySessionTimeout, timeout.inMinutes);
  }

  /// Démarre le timer de session
  void startSessionTimer() {
    _resetSessionTimer();
  }

  /// Arrête le timer de session
  void stopSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  void _resetSessionTimer() {
    _sessionTimer?.cancel();
    final timeout = getSessionTimeout();
    _sessionTimer = Timer(timeout, () {
      debugPrint('⏰ [SecurityService] Session expired');
      _onSessionExpired?.call();
    });
  }

  // ==================== BIOMETRIC AUTHENTICATION ====================

  /// Vérifie si l'appareil supporte l'authentification biométrique
  Future<BiometricCapability> checkBiometricCapability() async {
    try {
      // Utilisation de MethodChannel pour vérifier les capacités biométriques
      // Dans une vraie implémentation, utilisez local_auth package
      return BiometricCapability(
        isAvailable: true,
        hasFaceId: false,
        hasFingerprint: true,
        hasIris: false,
      );
    } catch (e) {
      debugPrint('❌ [SecurityService] Error checking biometric: $e');
      return BiometricCapability(
        isAvailable: false,
        hasFaceId: false,
        hasFingerprint: false,
        hasIris: false,
      );
    }
  }

  /// Active/désactive l'authentification biométrique
  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(_keyBiometricEnabled, enabled);
  }

  /// Vérifie si l'authentification biométrique est activée
  bool isBiometricEnabled() {
    return _prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  /// Authentifie l'utilisateur via biométrie
  Future<BiometricResult> authenticateWithBiometric({
    required String reason,
  }) async {
    try {
      // Dans une vraie implémentation, utilisez local_auth package
      // Pour l'instant, on simule un succès
      await Future.delayed(const Duration(milliseconds: 500));
      
      return BiometricResult(
        success: true,
        message: 'Authentification réussie',
      );
    } on PlatformException catch (e) {
      return BiometricResult(
        success: false,
        message: 'Erreur: ${e.message}',
        errorCode: e.code,
      );
    } catch (e) {
      return BiometricResult(
        success: false,
        message: 'Erreur inattendue',
      );
    }
  }

  // ==================== PIN AUTHENTICATION ====================

  /// Active l'authentification par PIN
  Future<void> setPinEnabled(bool enabled, {String? pin}) async {
    if (enabled && pin != null) {
      final hash = _hashPin(pin);
      await _prefs.setString(_keyPinHash, hash);
    } else {
      await _prefs.remove(_keyPinHash);
    }
    await _prefs.setBool(_keyPinEnabled, enabled);
  }

  /// Vérifie si l'authentification par PIN est activée
  bool isPinEnabled() {
    return _prefs.getBool(_keyPinEnabled) ?? false;
  }

  /// Vérifie le PIN
  Future<PinResult> verifyPin(String pin) async {
    // Vérifier le lockout
    if (isLockedOut()) {
      final lockoutUntil = DateTime.parse(_prefs.getString(_keyLockoutUntil)!);
      final remaining = lockoutUntil.difference(DateTime.now());
      return PinResult(
        success: false,
        message: 'Compte verrouillé. Réessayez dans ${remaining.inMinutes} minutes.',
        isLockedOut: true,
      );
    }

    final storedHash = _prefs.getString(_keyPinHash);
    if (storedHash == null) {
      return PinResult(
        success: false,
        message: 'PIN non configuré',
      );
    }

    final inputHash = _hashPin(pin);
    if (inputHash == storedHash) {
      await _resetFailedAttempts();
      return PinResult(
        success: true,
        message: 'PIN correct',
      );
    } else {
      final attempts = await _incrementFailedAttempts();
      final remaining = maxFailedAttempts - attempts;
      
      if (remaining <= 0) {
        await _setLockout();
        return PinResult(
          success: false,
          message: 'Trop de tentatives. Compte verrouillé.',
          isLockedOut: true,
        );
      }
      
      return PinResult(
        success: false,
        message: 'PIN incorrect. $remaining tentatives restantes.',
        attemptsRemaining: remaining,
      );
    }
  }

  /// Vérifie si le compte est verrouillé
  bool isLockedOut() {
    final lockoutUntilStr = _prefs.getString(_keyLockoutUntil);
    if (lockoutUntilStr == null) return false;
    
    final lockoutUntil = DateTime.parse(lockoutUntilStr);
    if (DateTime.now().isAfter(lockoutUntil)) {
      _prefs.remove(_keyLockoutUntil);
      _prefs.remove(_keyFailedAttempts);
      return false;
    }
    return true;
  }

  Future<int> _incrementFailedAttempts() async {
    final current = _prefs.getInt(_keyFailedAttempts) ?? 0;
    final newCount = current + 1;
    await _prefs.setInt(_keyFailedAttempts, newCount);
    return newCount;
  }

  Future<void> _resetFailedAttempts() async {
    await _prefs.remove(_keyFailedAttempts);
    await _prefs.remove(_keyLockoutUntil);
  }

  Future<void> _setLockout() async {
    final lockoutUntil = DateTime.now().add(lockoutDuration);
    await _prefs.setString(_keyLockoutUntil, lockoutUntil.toIso8601String());
  }

  String _hashPin(String pin) {
    // Simple hash pour la démo - utilisez un vrai hash en production
    final bytes = utf8.encode(pin + 'dr_pharma_salt');
    return base64Encode(bytes);
  }

  // ==================== SECURE DATA ====================

  /// Stocke des données de manière sécurisée
  Future<void> setSecureData(String key, String value) async {
    // Simple encodage pour la démo - utilisez flutter_secure_storage en production
    final encoded = base64Encode(utf8.encode(value));
    await _prefs.setString('secure_$key', encoded);
  }

  /// Récupère des données sécurisées
  String? getSecureData(String key) {
    final encoded = _prefs.getString('secure_$key');
    if (encoded == null) return null;
    return utf8.decode(base64Decode(encoded));
  }

  /// Supprime des données sécurisées
  Future<void> removeSecureData(String key) async {
    await _prefs.remove('secure_$key');
  }

  // ==================== CLEANUP ====================

  /// Nettoie toutes les données de sécurité (logout)
  Future<void> clearAllSecurityData() async {
    stopSessionTimer();
    await _prefs.remove(_keyLastActivity);
    await _prefs.remove(_keyFailedAttempts);
    await _prefs.remove(_keyLockoutUntil);
    debugPrint('🧹 [SecurityService] Security data cleared');
  }

  /// Dispose du service
  void dispose() {
    stopSessionTimer();
  }
}

/// Capacités biométriques de l'appareil
class BiometricCapability {
  final bool isAvailable;
  final bool hasFaceId;
  final bool hasFingerprint;
  final bool hasIris;

  BiometricCapability({
    required this.isAvailable,
    required this.hasFaceId,
    required this.hasFingerprint,
    required this.hasIris,
  });

  String get availableMethodsText {
    final methods = <String>[];
    if (hasFaceId) methods.add('Face ID');
    if (hasFingerprint) methods.add('Empreinte digitale');
    if (hasIris) methods.add('Iris');
    return methods.isEmpty ? 'Aucune' : methods.join(', ');
  }
}

/// Résultat d'authentification biométrique
class BiometricResult {
  final bool success;
  final String message;
  final String? errorCode;

  BiometricResult({
    required this.success,
    required this.message,
    this.errorCode,
  });
}

/// Résultat de vérification PIN
class PinResult {
  final bool success;
  final String message;
  final bool isLockedOut;
  final int? attemptsRemaining;

  PinResult({
    required this.success,
    required this.message,
    this.isLockedOut = false,
    this.attemptsRemaining,
  });
}
