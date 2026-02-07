/// Classe utilitaire pour gérer tous les messages d'erreur de l'application
/// Permet une gestion centralisée et cohérente des messages d'erreur
class ErrorMessages {
  // ============================================
  // ERREURS D'AUTHENTIFICATION
  // ============================================
  
  static const String invalidCredentials = 
      'Email ou mot de passe incorrect. Veuillez vérifier vos identifiants.';
  
  static const String accountNotFound = 
      'Aucun compte trouvé avec cet email. Voulez-vous créer un compte ?';
  
  static const String accountDisabled = 
      'Votre compte a été désactivé. Contactez le support pour plus d\'informations.';
  
  static const String accountNotVerified = 
      'Votre compte n\'est pas encore vérifié. Vérifiez votre email pour le lien de confirmation.';
  
  static const String pharmacyNotApproved = 
      'Votre pharmacie n\'est pas encore approuvée. Veuillez patienter ou contacter le support.';
  
  static const String sessionExpired = 
      'Votre session a expiré. Veuillez vous reconnecter.';
  
  static const String tooManyAttempts = 
      'Trop de tentatives de connexion. Veuillez réessayer dans quelques minutes.';

  static const String passwordTooWeak = 
      'Le mot de passe doit contenir au moins 8 caractères, une majuscule, une minuscule et un chiffre.';
  
  static const String passwordMismatch = 
      'Les mots de passe ne correspondent pas.';
  
  static const String emailAlreadyExists = 
      'Un compte existe déjà avec cet email. Voulez-vous vous connecter ?';
  
  static const String phoneAlreadyExists = 
      'Ce numéro de téléphone est déjà associé à un autre compte.';

  // ============================================
  // ERREURS RÉSEAU / CONNEXION
  // ============================================
  
  static const String noInternet = 
      'Pas de connexion internet. Vérifiez votre connexion et réessayez.';
  
  static const String connectionTimeout = 
      'La connexion a pris trop de temps. Vérifiez votre connexion internet.';
  
  static const String serverUnavailable = 
      'Le serveur est temporairement indisponible. Veuillez réessayer dans quelques instants.';
  
  static const String serverError = 
      'Une erreur est survenue sur le serveur. Notre équipe a été notifiée.';
  
  static const String unknownError = 
      'Une erreur inattendue est survenue. Veuillez réessayer.';

  // ============================================
  // ERREURS DE VALIDATION FORMULAIRE
  // ============================================
  
  static const String fieldRequired = 'Ce champ est obligatoire.';
  
  static const String invalidEmail = 
      'Veuillez entrer une adresse email valide (ex: nom@example.com).';
  
  static const String invalidPhone = 
      'Veuillez entrer un numéro de téléphone valide (ex: +225 07 XX XX XX XX).';
  
  static const String invalidPrice = 
      'Veuillez entrer un prix valide (nombre positif).';
  
  static const String invalidQuantity = 
      'Veuillez entrer une quantité valide (nombre entier positif).';
  
  static const String invalidDate = 
      'Veuillez sélectionner une date valide.';
  
  static const String dateInPast = 
      'La date ne peut pas être dans le passé.';
  
  static const String minLength = 
      'Ce champ doit contenir au moins {min} caractères.';
  
  static const String maxLength = 
      'Ce champ ne peut pas dépasser {max} caractères.';

  // ============================================
  // ERREURS INVENTAIRE / PRODUITS
  // ============================================
  
  static const String productNotFound = 
      'Produit introuvable. Il a peut-être été supprimé.';
  
  static const String productAlreadyExists = 
      'Un produit avec ce code-barres existe déjà dans votre inventaire.';
  
  static const String insufficientStock = 
      'Stock insuffisant pour cette opération.';
  
  static const String invalidBarcode = 
      'Le code-barres scanné n\'est pas valide ou n\'a pas pu être lu.';
  
  static const String categoryNotFound = 
      'Catégorie introuvable. Veuillez en sélectionner une autre.';
  
  static const String productExpired = 
      'Ce produit est expiré et ne peut pas être vendu.';

  static const String addProductFailed = 
      'Impossible d\'ajouter le produit. Vérifiez les informations et réessayez.';
  
  static const String updateProductFailed = 
      'Impossible de mettre à jour le produit. Veuillez réessayer.';
  
  static const String deleteProductFailed = 
      'Impossible de supprimer le produit. Veuillez réessayer.';

  // ============================================
  // ERREURS COMMANDES
  // ============================================
  
  static const String orderNotFound = 
      'Commande introuvable. Elle a peut-être été annulée.';
  
  static const String orderAlreadyProcessed = 
      'Cette commande a déjà été traitée.';
  
  static const String orderCancellationFailed = 
      'Impossible d\'annuler la commande. Elle est peut-être déjà en préparation.';
  
  static const String orderConfirmationFailed = 
      'Impossible de confirmer la commande. Veuillez réessayer.';
  
  static const String noOrdersFound = 
      'Aucune commande trouvée pour cette période.';
  
  static const String orderItemUnavailable = 
      'Un ou plusieurs produits de cette commande ne sont plus disponibles.';

  // ============================================
  // ERREURS WALLET / PAIEMENTS
  // ============================================
  
  static const String insufficientBalance = 
      'Solde insuffisant pour effectuer cette opération.';
  
  static const String withdrawalFailed = 
      'Le retrait a échoué. Vérifiez vos informations bancaires.';
  
  static const String minimumWithdrawal = 
      'Le montant minimum de retrait est de {amount} FCFA.';
  
  static const String invalidPin = 
      'Code PIN incorrect. Il vous reste {attempts} tentative(s).';
  
  static const String pinLocked = 
      'Compte verrouillé suite à trop de tentatives. Réessayez dans {minutes} minutes.';
  
  static const String transactionFailed = 
      'La transaction a échoué. Veuillez réessayer.';

  // ============================================
  // ERREURS ORDONNANCES
  // ============================================
  
  static const String prescriptionNotFound = 
      'Ordonnance introuvable.';
  
  static const String prescriptionExpired = 
      'Cette ordonnance a expiré et ne peut plus être traitée.';
  
  static const String prescriptionAlreadyProcessed = 
      'Cette ordonnance a déjà été traitée.';
  
  static const String invalidPrescription = 
      'L\'ordonnance n\'est pas valide ou n\'a pas pu être lue.';

  // ============================================
  // ERREURS FICHIERS / IMAGES
  // ============================================
  
  static const String imageUploadFailed = 
      'Impossible d\'envoyer l\'image. Vérifiez votre connexion.';
  
  static const String imageTooLarge = 
      'L\'image est trop volumineuse. Taille maximum: 5 Mo.';
  
  static const String invalidImageFormat = 
      'Format d\'image non supporté. Utilisez JPG, PNG ou WebP.';
  
  static const String cameraPermissionDenied = 
      'Permission caméra refusée. Activez-la dans les paramètres de l\'application.';
  
  static const String galleryPermissionDenied = 
      'Permission galerie refusée. Activez-la dans les paramètres de l\'application.';

  // ============================================
  // MÉTHODES UTILITAIRES
  // ============================================

  /// Convertit un message d'erreur technique en message lisible
  static String fromException(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    // Erreurs réseau
    if (errorStr.contains('socketexception') || 
        errorStr.contains('no internet') ||
        errorStr.contains('network')) {
      return noInternet;
    }
    
    if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
      return connectionTimeout;
    }
    
    if (errorStr.contains('500') || errorStr.contains('internal server')) {
      return serverError;
    }
    
    if (errorStr.contains('503') || errorStr.contains('service unavailable')) {
      return serverUnavailable;
    }
    
    // Erreurs d'authentification
    if (errorStr.contains('401') || errorStr.contains('unauthorized') || 
        errorStr.contains('unauthenticated')) {
      return sessionExpired;
    }
    
    if (errorStr.contains('403') || errorStr.contains('forbidden')) {
      return accountDisabled;
    }
    
    if (errorStr.contains('invalid credentials') || 
        errorStr.contains('identifiants invalides') ||
        errorStr.contains('mot de passe incorrect') ||
        errorStr.contains('email ou mot de passe')) {
      return invalidCredentials;
    }
    
    if (errorStr.contains('too many') || errorStr.contains('rate limit') ||
        errorStr.contains('trop de tentatives')) {
      return tooManyAttempts;
    }
    
    if (errorStr.contains('email already') || errorStr.contains('email existe')) {
      return emailAlreadyExists;
    }
    
    if (errorStr.contains('not verified') || errorStr.contains('non vérifié')) {
      return accountNotVerified;
    }
    
    if (errorStr.contains('not approved') || errorStr.contains('non approuvé') ||
        errorStr.contains('pas encore approuvée')) {
      return pharmacyNotApproved;
    }
    
    // Erreurs de stock
    if (errorStr.contains('insufficient stock') || errorStr.contains('stock insuffisant')) {
      return insufficientStock;
    }
    
    if (errorStr.contains('product not found') || errorStr.contains('produit introuvable')) {
      return productNotFound;
    }
    
    // Erreurs de paiement
    if (errorStr.contains('insufficient balance') || errorStr.contains('solde insuffisant')) {
      return insufficientBalance;
    }
    
    // Message par défaut
    return unknownError;
  }

  /// Retourne un message avec des paramètres remplacés
  static String withParams(String message, Map<String, dynamic> params) {
    String result = message;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }

  /// Retourne le message de validation pour une longueur minimum
  static String minLengthMessage(int min) {
    return withParams(minLength, {'min': min});
  }

  /// Retourne le message de validation pour une longueur maximum
  static String maxLengthMessage(int max) {
    return withParams(maxLength, {'max': max});
  }

  /// Alias pour fromException - pour compatibilité
  static String getReadableMessage(String error) {
    return fromException(error);
  }

  /// Retourne un message d'erreur lisible pour les opérations d'inventaire
  static String getInventoryError(String error) {
    final errorLower = error.toLowerCase();
    
    if (errorLower.contains('catégorie') || errorLower.contains('category')) {
      return categoryNotFound;
    }
    
    if (errorLower.contains('barcode') || errorLower.contains('code-barres')) {
      if (errorLower.contains('existe') || errorLower.contains('already')) {
        return productAlreadyExists;
      }
      return invalidBarcode;
    }
    
    if (errorLower.contains('stock')) {
      return insufficientStock;
    }
    
    if (errorLower.contains('product') || errorLower.contains('produit')) {
      if (errorLower.contains('not found') || errorLower.contains('introuvable')) {
        return productNotFound;
      }
      if (errorLower.contains('add') || errorLower.contains('ajouter')) {
        return addProductFailed;
      }
      if (errorLower.contains('update') || errorLower.contains('modifier')) {
        return updateProductFailed;
      }
      if (errorLower.contains('delete') || errorLower.contains('supprimer')) {
        return deleteProductFailed;
      }
    }
    
    if (errorLower.contains('expir')) {
      return productExpired;
    }
    
    // Message par défaut pour l'inventaire
    return fromException(error);
  }
}

/// Types d'erreur pour le style d'affichage
enum ErrorType {
  error,      // Erreur critique - Rouge
  warning,    // Avertissement - Orange
  info,       // Information - Bleu
  success,    // Succès - Vert
}

/// Extension pour obtenir les couleurs selon le type
extension ErrorTypeExtension on ErrorType {
  String get icon {
    switch (this) {
      case ErrorType.error: return '❌';
      case ErrorType.warning: return '⚠️';
      case ErrorType.info: return 'ℹ️';
      case ErrorType.success: return '✅';
    }
  }
  
  String get title {
    switch (this) {
      case ErrorType.error: return 'Erreur';
      case ErrorType.warning: return 'Attention';
      case ErrorType.info: return 'Information';
      case ErrorType.success: return 'Succès';
    }
  }
}
