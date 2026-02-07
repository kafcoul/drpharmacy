import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service de stockage sécurisé pour les données sensibles
/// Utilise le Keychain sur iOS et EncryptedSharedPreferences sur Android
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Clés de stockage
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  /// Sauvegarde le token d'authentification de manière sécurisée
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Récupère le token d'authentification
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Supprime le token d'authentification
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Sauvegarde le refresh token
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Récupère le refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Supprime le refresh token
  static Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Sauvegarde l'ID utilisateur
  static Future<void> saveUserId(String id) async {
    await _storage.write(key: _userIdKey, value: id);
  }

  /// Récupère l'ID utilisateur
  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Supprime toutes les données sécurisées (logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Vérifie si un token existe
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
