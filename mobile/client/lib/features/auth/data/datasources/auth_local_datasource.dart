import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/secure_storage_service.dart';
import 'dart:convert';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getCachedToken();
  Future<void> clearToken();

  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
  
  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  // ============================================================
  // TOKEN - Stockage SÉCURISÉ via flutter_secure_storage
  // ============================================================
  
  @override
  Future<void> cacheToken(String token) async {
    // Utiliser le stockage sécurisé pour le token
    await SecureStorageService.saveToken(token);
  }

  @override
  Future<String?> getCachedToken() async {
    // Récupérer depuis le stockage sécurisé
    return await SecureStorageService.getToken();
  }

  @override
  Future<void> clearToken() async {
    // Supprimer du stockage sécurisé
    await SecureStorageService.deleteToken();
  }

  // ============================================================
  // USER DATA - SharedPreferences (données non sensibles)
  // ============================================================

  @override
  Future<void> cacheUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await sharedPreferences.setString(AppConstants.userKey, userJson);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userJson = sharedPreferences.getString(AppConstants.userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.remove(AppConstants.userKey);
  }
  
  // ============================================================
  // CLEAR ALL - Logout complet
  // ============================================================
  
  @override
  Future<void> clearAll() async {
    await SecureStorageService.clearAll();
    await sharedPreferences.remove(AppConstants.userKey);
  }
}
