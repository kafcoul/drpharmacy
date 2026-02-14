import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_session_service.dart';

class AuthInterceptor extends Interceptor {
  /// Routes exclues de la gestion automatique du 401
  /// (login et register ne doivent pas déclencher une expiration de session)
  static const _excludedPaths = [
    '/auth/login',
    '/auth/register/courier',
  ];

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    options.headers['Accept'] = 'application/json';

    super.onRequest(options, handler);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final path = err.requestOptions.path;
    final statusCode = err.response?.statusCode;

    if (statusCode == 401 && !_isExcludedPath(path)) {
      // Token expiré ou invalide → nettoyer et notifier l'UI
      debugPrint('🔐 [API ERROR 401] Session expirée sur: $path');
      debugPrint('   → Déclenchement du nettoyage de session');
      AuthSessionService.instance.onSessionExpired();
    } else if (statusCode == 401) {
      debugPrint('🔐 [API ERROR 401] Identifiants invalides sur: $path');
    } else if (statusCode == 404) {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('❌ [API ERROR 404] Endpoint non trouvé');
      debugPrint('   URL: ${err.requestOptions.baseUrl}${err.requestOptions.path}');
      debugPrint('   Method: ${err.requestOptions.method}');
      debugPrint('   Message: ${err.response?.data?['message'] ?? 'Resource not found'}');
      debugPrint('═══════════════════════════════════════════════════════════');
    } else if (statusCode == 500) {
      debugPrint('🔥 [API ERROR 500] Erreur serveur');
      debugPrint('   URL: $path');
      debugPrint('   Message: ${err.response?.data?['message'] ?? 'Internal server error'}');
    } else if (err.type == DioExceptionType.connectionError) {
      debugPrint('🌐 [API ERROR] Impossible de se connecter au serveur');
      debugPrint('   URL tentée: ${err.requestOptions.baseUrl}');
      debugPrint('   Vérifiez que le serveur est démarré et accessible');
    }
    
    super.onError(err, handler);
  }

  /// Vérifie si le path est exclu de la gestion automatique du 401
  bool _isExcludedPath(String path) {
    return _excludedPaths.any((excluded) => path.contains(excluded));
  }
}
