import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service de configuration d'environnement
/// Charge les variables depuis .env et fournit un accès type-safe
class EnvConfig {
  static bool _initialized = false;

  /// Initialise la configuration depuis le fichier .env
  /// Doit être appelé dans main() avant runApp()
  static Future<void> init() async {
    if (_initialized) return;
    
    try {
      await dotenv.load(fileName: '.env');
      _initialized = true;
    } catch (e) {
      // En cas d'erreur, utiliser les valeurs par défaut
      // Utile pour les tests et le CI
      _initialized = true;
    }
  }

  /// Helper safe environment access
  static String _getEnv(String key, [String defaultValue = '']) {
    if (!_initialized) return defaultValue;
    try {
      return dotenv.env[key] ?? defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  /// URL de base de l'API
  static String get apiBaseUrl {
    final url = _getEnv('API_BASE_URL', 'http://localhost:8000');
    return _ensureHttps(url);
  }

  /// URL de base de l'API avec /api
  static String get apiUrl => '$apiBaseUrl/api';

  /// URL de stockage des fichiers
  static String get storageBaseUrl {
    final url = _getEnv('STORAGE_BASE_URL', '$apiBaseUrl/storage');
    return _ensureHttps(url);
  }

  /// Environnement actuel
  static String get environment => _getEnv('APP_ENV', 'development');

  /// Est-ce l'environnement de développement ?
  static bool get isDevelopment => environment == 'development';

  /// Est-ce l'environnement de staging ?
  static bool get isStaging => environment == 'staging';

  /// Est-ce l'environnement de production ?
  static bool get isProduction => environment == 'production';

  /// Mode debug activé ?
  static bool get debugMode {
    final value = _getEnv('DEBUG_MODE', 'false').toLowerCase();
    return value == 'true' || value == '1';
  }

  /// Forcer HTTPS ?
  static bool get forceHttps {
    // Toujours forcer HTTPS en production
    if (isProduction) return true;
    
    final value = _getEnv('FORCE_HTTPS', 'false').toLowerCase();
    return value == 'true' || value == '1';
  }

  /// Timeout de connexion
  static Duration get connectionTimeout {
    final ms = int.tryParse(_getEnv('CONNECTION_TIMEOUT', '30000')) ?? 30000;
    return Duration(milliseconds: ms);
  }

  /// Timeout de réception
  static Duration get receiveTimeout {
    final ms = int.tryParse(_getEnv('RECEIVE_TIMEOUT', '30000')) ?? 30000;
    return Duration(milliseconds: ms);
  }

  /// Clé API Google Maps
  static String get googleMapsApiKey {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  }

  /// Convertit HTTP en HTTPS si forceHttps est activé
  static String _ensureHttps(String url) {
    if (!forceHttps) return url;
    
    if (url.startsWith('http://localhost') || 
        url.startsWith('http://10.0.2.2') ||
        url.startsWith('http://127.0.0.1')) {
      // Ne pas convertir localhost en développement
      return url;
    }
    
    return url.replaceFirst('http://', 'https://');
  }

  /// Affiche la configuration actuelle (pour debug)
  static void printConfig() {
    if (!debugMode) return;
    
    // ignore: avoid_print - intentionnel pour debug au démarrage
    print('═══════════════════════════════════════\n'
        '🔧 DR-PHARMA Environment Configuration\n'
        '═══════════════════════════════════════\n'
        '   Environment: $environment\n'
        '   API URL: $apiUrl\n'
        '   Storage URL: $storageBaseUrl\n'
        '   Debug Mode: $debugMode\n'
        '   Force HTTPS: $forceHttps\n'
        '   Connection Timeout: ${connectionTimeout.inSeconds}s\n'
        '═══════════════════════════════════════');
  }
}
