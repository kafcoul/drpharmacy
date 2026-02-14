import 'package:flutter/foundation.dart';

/// Configuration centralisée de l'application
/// En production, ces valeurs devraient venir de variables d'environnement
/// ou d'un fichier de configuration sécurisé (.env)
class AppConfig {
  // Singleton
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  /// Environnement actuel
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const bool isDebug = !isProduction;

  /// API Base URL
  static String get apiBaseUrl {
    // En production, utiliser l'URL de production
    if (isProduction) {
      return const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://api.drpharma.ci/api',
      );
    }
    
    // En développement
    if (kIsWeb) {
      return const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://127.0.0.1:8000/api',
      );
    }
    // Android Emulator
    return const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000/api',
    );
  }

  /// Google Maps API Key
  /// Passée via --dart-define=GOOGLE_MAPS_API_KEY=xxx au build
  /// Ne JAMAIS hardcoder la clé ici
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '', // Définie via --dart-define ou .env
  );

  /// Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  /// Cache
  static const Duration cacheExpiration = Duration(minutes: 5);

  /// Logging
  static bool get enableApiLogging => isDebug;
  static bool get enableLocationLogging => isDebug;
}
