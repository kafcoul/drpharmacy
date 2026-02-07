import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider pour le service d'authentification biométrique
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

/// Provider pour l'état d'activation de la biométrie (simple bool)
final biometricEnabledProvider = Provider<bool>((ref) => false);

/// Provider pour les réglages biométriques
final biometricSettingsProvider = NotifierProvider<BiometricSettingsNotifier, bool>(
  BiometricSettingsNotifier.new,
);

/// Notifier pour gérer l'état des réglages biométriques
class BiometricSettingsNotifier extends Notifier<bool> {
  static const String _key = 'biometric_login_enabled';

  @override
  bool build() {
    _loadSettings();
    return false;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> enableBiometricLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = true;
  }

  Future<void> disableBiometricLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, false);
    state = false;
  }
}

/// Types de biométrie disponibles
enum AppBiometricType {
  fingerprint,
  faceId,
  iris,
  none,
}

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricTokenKey = 'biometric_auth_token';

  /// Vérifie si le device peut vérifier les biométries
  Future<bool> canCheckBiometrics() async {
    // Biometrics not supported on web
    if (kIsWeb) return false;
    
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } on PlatformException catch (e) {
      debugPrint('Error checking biometrics: $e');
      return false;
    } on MissingPluginException catch (_) {
      debugPrint('Biometrics not available on this platform');
      return false;
    }
  }

  /// Vérifie si le device supporte la biométrie
  Future<bool> isDeviceSupported() async {
    // Biometrics not supported on web
    if (kIsWeb) return false;
    
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException catch (e) {
      debugPrint('Error checking device support: $e');
      return false;
    } on MissingPluginException catch (_) {
      return false;
    }
  }

  /// Vérifie si des biométries sont enregistrées sur le device
  Future<bool> hasBiometrics() async {
    // Biometrics not supported on web
    if (kIsWeb) return false;
    
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      debugPrint('Error checking biometrics: $e');
      return false;
    } on MissingPluginException catch (_) {
      return false;
    }
  }

  /// Retourne les types de biométrie disponibles
  Future<List<AppBiometricType>> getAvailableBiometrics() async {
    // Biometrics not supported on web
    if (kIsWeb) return [];
    
    try {
      final available = await _localAuth.getAvailableBiometrics();
      return available.map((bio) {
        switch (bio) {
          case BiometricType.fingerprint:
            return AppBiometricType.fingerprint;
          case BiometricType.face:
            return AppBiometricType.faceId;
          case BiometricType.iris:
            return AppBiometricType.iris;
          default:
            return AppBiometricType.none;
        }
      }).where((b) => b != AppBiometricType.none).toList();
    } on PlatformException catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    } on MissingPluginException catch (_) {
      debugPrint('Biometrics not available on this platform');
      return [];
    }
  }

  /// Retourne le type de biométrie principal disponible
  Future<AppBiometricType> getPrimaryBiometricType() async {
    final types = await getAvailableBiometrics();
    if (types.contains(AppBiometricType.faceId)) {
      return AppBiometricType.faceId;
    } else if (types.contains(AppBiometricType.fingerprint)) {
      return AppBiometricType.fingerprint;
    } else if (types.contains(AppBiometricType.iris)) {
      return AppBiometricType.iris;
    }
    return AppBiometricType.none;
  }

  /// Retourne le nom localisé du type de biométrie
  String getBiometricName(AppBiometricType type) {
    switch (type) {
      case AppBiometricType.fingerprint:
        return 'Empreinte digitale';
      case AppBiometricType.faceId:
        return 'Face ID';
      case AppBiometricType.iris:
        return 'Iris';
      case AppBiometricType.none:
        return 'Non disponible';
    }
  }

  /// Authentifie l'utilisateur avec biométrie
  Future<bool> authenticate({
    String reason = 'Veuillez vous authentifier pour continuer',
  }) async {
    // Biometrics not supported on web
    if (kIsWeb) return false;
    
    try {
      // Vérifier d'abord si la biométrie est disponible
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      
      if (!canCheck || !isSupported) {
        debugPrint('Biometric auth not available');
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Authentication error: ${e.message}');
      return false;
    } on MissingPluginException catch (_) {
      debugPrint('Biometrics not available on this platform');
      return false;
    }
  }

  /// Vérifie si la biométrie est activée dans les préférences
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Active ou désactive la biométrie
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  /// Stocke le token d'authentification pour la reconnexion biométrique
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_biometricTokenKey, token);
  }

  /// Récupère le token d'authentification stocké
  Future<String?> getStoredAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_biometricTokenKey);
  }

  /// Supprime le token stocké (logout)
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_biometricTokenKey);
  }

  /// Authentification rapide avec biométrie si activée
  /// Retourne le token si succès, null sinon
  Future<String?> quickLogin() async {
    final isEnabled = await isBiometricEnabled();
    if (!isEnabled) return null;

    final token = await getStoredAuthToken();
    if (token == null) return null;

    final authenticated = await authenticate(
      reason: 'Authentifiez-vous pour accéder à DR-PHARMA',
    );

    return authenticated ? token : null;
  }
}
