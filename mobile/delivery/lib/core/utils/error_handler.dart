import 'package:dio/dio.dart';

/// Classe utilitaire pour convertir les erreurs techniques en messages compréhensibles
class ErrorHandler {
  /// Convertit une erreur Dio en message user-friendly
  static String getReadableMessage(dynamic error, {String? defaultMessage}) {
    if (error is DioException) {
      return _handleDioError(error, defaultMessage: defaultMessage);
    }
    
    final errorString = error.toString().toLowerCase();
    
    // Erreurs réseau
    if (errorString.contains('socketexception') ||
        errorString.contains('connection refused') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('xmlhttprequest')) {
      return 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
    }
    
    // Timeout
    if (errorString.contains('timeout')) {
      return 'La connexion a pris trop de temps. Veuillez réessayer.';
    }
    
    return defaultMessage ?? 'Une erreur est survenue. Veuillez réessayer.';
  }

  static String _handleDioError(DioException error, {String? defaultMessage}) {
    // Essayer d'abord de récupérer le message du serveur
    final serverMessage = _extractServerMessage(error);
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'La connexion a pris trop de temps. Vérifiez votre connexion.';
        
      case DioExceptionType.connectionError:
        return 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
        
      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode, serverMessage, defaultMessage);
        
      case DioExceptionType.cancel:
        return 'Requête annulée.';
        
      case DioExceptionType.badCertificate:
        return 'Erreur de sécurité. Contactez le support.';
        
      case DioExceptionType.unknown:
        if (error.error.toString().contains('SocketException') ||
            error.error.toString().contains('XMLHttpRequest')) {
          return 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
        }
        return defaultMessage ?? 'Une erreur est survenue. Veuillez réessayer.';
    }
  }

  static String? _extractServerMessage(DioException error) {
    try {
      final data = error.response?.data;
      if (data is Map) {
        return data['message'] as String?;
      }
    } catch (_) {}
    return null;
  }

  static String _handleStatusCode(int? statusCode, String? serverMessage, String? defaultMessage) {
    switch (statusCode) {
      case 400:
        return serverMessage ?? 'Requête invalide. Vérifiez les informations saisies.';
      case 401:
        return 'Session expirée. Veuillez vous reconnecter.';
      case 403:
        return serverMessage ?? 'Accès refusé. Vous n\'avez pas les droits nécessaires.';
      case 404:
        return serverMessage ?? 'Élément introuvable.';
      case 409:
        return serverMessage ?? 'Cette action ne peut pas être effectuée actuellement.';
      case 422:
        return serverMessage ?? 'Données invalides. Vérifiez les informations saisies.';
      case 429:
        return 'Trop de requêtes. Veuillez patienter quelques instants.';
      case 500:
      case 502:
      case 503:
        return 'Le serveur rencontre des difficultés. Veuillez réessayer plus tard.';
      default:
        return serverMessage ?? defaultMessage ?? 'Une erreur est survenue. Veuillez réessayer.';
    }
  }

  /// Messages spécifiques pour les livraisons
  static String getDeliveryErrorMessage(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final serverMessage = _extractServerMessage(error);
      final errorCode = error.response?.data?['error_code'];
      
      if (statusCode == 403) {
        if (errorCode == 'COURIER_PROFILE_NOT_FOUND') {
          return 'Votre profil coursier n\'est pas configuré. Contactez le support.';
        }
        return serverMessage ?? 'Vous n\'êtes pas autorisé à effectuer cette action.';
      }
      
      if (statusCode == 404) {
        return 'Livraison introuvable ou déjà prise en charge par un autre coursier.';
      }
      
      if (statusCode == 409) {
        return serverMessage ?? 'Cette livraison n\'est plus disponible.';
      }
    }
    
    return getReadableMessage(error, defaultMessage: 'Impossible de traiter la livraison.');
  }

  /// Messages spécifiques pour le profil
  static String getProfileErrorMessage(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final errorCode = error.response?.data?['error_code'];
      
      if (statusCode == 403 && errorCode == 'COURIER_PROFILE_NOT_FOUND') {
        return 'Profil coursier non trouvé. Ce compte n\'est pas configuré comme livreur.';
      }
      
      if (statusCode == 401) {
        return 'Session expirée. Veuillez vous reconnecter.';
      }
    }
    
    return getReadableMessage(error, defaultMessage: 'Impossible de charger le profil.');
  }

  /// Messages spécifiques pour les messages/chat
  static String getChatErrorMessage(dynamic error) {
    return getReadableMessage(error, defaultMessage: 'Impossible d\'envoyer le message.');
  }
}
