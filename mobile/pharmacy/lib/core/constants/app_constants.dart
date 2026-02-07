import '../config/env_config.dart';

class AppConstants {
  static const String appName = 'DR-PHARMA Pharmacie';
  
  /// URL de base du serveur (utilise EnvConfig pour la configuration dynamique)
  static String get baseUrl => EnvConfig.baseUrl;
  
  /// URL de base de l'API
  static String get apiBaseUrl => EnvConfig.apiBaseUrl;
  
  /// URL de base pour les fichiers storage
  static String get storageBaseUrl => EnvConfig.storageBaseUrl;
  
  /// Timeout des requêtes API en secondes
  static Duration get apiTimeout => Duration(milliseconds: EnvConfig.apiTimeout);
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}
