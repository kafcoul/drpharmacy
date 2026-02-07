import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
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
    // Log détaillé des erreurs 404 pour le debug
    if (err.response?.statusCode == 404) {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('❌ [API ERROR 404] Endpoint non trouvé');
      debugPrint('   URL: ${err.requestOptions.baseUrl}${err.requestOptions.path}');
      debugPrint('   Method: ${err.requestOptions.method}');
      debugPrint('   Message: ${err.response?.data?['message'] ?? 'Resource not found'}');
      debugPrint('═══════════════════════════════════════════════════════════');
    } else if (err.response?.statusCode == 401) {
      debugPrint('🔐 [API ERROR 401] Non authentifié - Token invalide ou expiré');
      debugPrint('   URL: ${err.requestOptions.path}');
    } else if (err.response?.statusCode == 500) {
      debugPrint('🔥 [API ERROR 500] Erreur serveur');
      debugPrint('   URL: ${err.requestOptions.path}');
      debugPrint('   Message: ${err.response?.data?['message'] ?? 'Internal server error'}');
    } else if (err.type == DioExceptionType.connectionError) {
      debugPrint('🌐 [API ERROR] Impossible de se connecter au serveur');
      debugPrint('   URL tentée: ${err.requestOptions.baseUrl}');
      debugPrint('   Vérifiez que le serveur est démarré et accessible');
    }
    
    super.onError(err, handler);
  }
}
