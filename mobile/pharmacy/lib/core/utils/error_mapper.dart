/// Mapper les codes d'erreur API vers des messages UX français
/// 
/// Usage:
/// ```dart
/// final userMessage = ErrorMapper.toUserMessage(apiErrorCode, fallbackMessage);
/// ```
class ErrorMapper {
  ErrorMapper._();

  /// Map des codes d'erreur API vers messages UX
  static const Map<String, String> _errorMessages = {
    // Authentification
    'INVALID_CREDENTIALS': 'Email ou mot de passe incorrect',
    'UNAUTHORIZED': 'Vous devez vous connecter pour accéder à cette fonctionnalité',
    'SESSION_EXPIRED': 'Votre session a expiré. Veuillez vous reconnecter',
    'TOKEN_INVALID': 'Session invalide. Veuillez vous reconnecter',
    
    // Compte pharmacie
    'ACCOUNT_PENDING': 'Votre compte est en attente d\'approbation par l\'administrateur',
    'ACCOUNT_SUSPENDED': 'Votre compte a été suspendu. Contactez le support',
    'ACCOUNT_REJECTED': 'Votre demande d\'inscription a été refusée',
    'ACCOUNT_NOT_PHARMACY': 'Ce compte n\'est pas un compte pharmacie',
    
    // Validation
    'EMAIL_ALREADY_EXISTS': 'Cette adresse email est déjà utilisée',
    'PHONE_ALREADY_EXISTS': 'Ce numéro de téléphone est déjà utilisé',
    'LICENSE_ALREADY_EXISTS': 'Ce numéro de licence est déjà enregistré',
    'INVALID_EMAIL_FORMAT': 'Format d\'email invalide',
    'PASSWORD_TOO_SHORT': 'Le mot de passe doit contenir au moins 8 caractères',
    
    // Réseau
    'NETWORK_ERROR': 'Erreur de connexion. Vérifiez votre connexion internet',
    'SERVER_ERROR': 'Une erreur serveur s\'est produite. Réessayez plus tard',
    'TIMEOUT': 'Le serveur met trop de temps à répondre. Réessayez',
    
    // Commandes
    'ORDER_NOT_FOUND': 'Commande introuvable',
    'ORDER_ALREADY_ASSIGNED': 'Cette commande a déjà été assignée',
    'ORDER_CANCELLED': 'Cette commande a été annulée',
    
    // Paiement
    'PAYMENT_FAILED': 'Le paiement a échoué. Veuillez réessayer',
    'INSUFFICIENT_FUNDS': 'Solde insuffisant',
  };

  /// Convertit un code d'erreur API en message utilisateur
  /// 
  /// [errorCode] - Code d'erreur de l'API (ex: INVALID_CREDENTIALS)
  /// [fallbackMessage] - Message par défaut si le code n'est pas mappé
  static String toUserMessage(String? errorCode, [String? fallbackMessage]) {
    if (errorCode == null) {
      return fallbackMessage ?? 'Une erreur s\'est produite';
    }
    
    return _errorMessages[errorCode] ?? fallbackMessage ?? 'Une erreur s\'est produite';
  }

  /// Détecte si un message contient des termes techniques à remplacer
  static String cleanTechnicalMessage(String message) {
    // Remplacer les termes techniques courants
    return message
        .replaceAll('Unauthenticated', 'Session expirée')
        .replaceAll('Unauthorized', 'Non autorisé')
        .replaceAll('Internal Server Error', 'Erreur serveur')
        .replaceAll('Bad Request', 'Requête invalide')
        .replaceAll('Not Found', 'Ressource introuvable')
        .replaceAll('Validation Error', 'Erreur de validation')
        .replaceAll('Connection refused', 'Connexion impossible')
        .replaceAll('Connection timed out', 'Délai de connexion dépassé');
  }

  /// Combine le mapping et le nettoyage
  static String format(String? errorCode, String? message) {
    // Priorité au code d'erreur si connu
    if (errorCode != null && _errorMessages.containsKey(errorCode)) {
      return _errorMessages[errorCode]!;
    }
    
    // Sinon nettoyer le message technique
    if (message != null) {
      return cleanTechnicalMessage(message);
    }
    
    return 'Une erreur s\'est produite';
  }
}
