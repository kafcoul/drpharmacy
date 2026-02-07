/// Fonctions de validation pour les formulaires
class Validators {
  Validators._();
  
  /// Valide un email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer un email valide';
    }
    return null;
  }
  
  /// Valide un mot de passe
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }
  
  /// Valide un mot de passe avec règles strictes
  static String? passwordStrict(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Le mot de passe doit contenir au moins une majuscule';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Le mot de passe doit contenir au moins une minuscule';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }
    return null;
  }
  
  /// Valide la confirmation du mot de passe
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer le mot de passe';
    }
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }
  
  /// Valide un numéro de téléphone
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est requis';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\.]'), '');
    // Accepte les formats: 0X XX XX XX XX, +225 XX XX XX XX XX, 00225XXXXXXXXXX
    final phoneRegex = RegExp(r'^(\+225|00225|0)?[0-9]{10}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Veuillez entrer un numéro de téléphone valide';
    }
    return null;
  }
  
  /// Valide un nom
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    if (value.length > 50) {
      return 'Le nom ne doit pas dépasser 50 caractères';
    }
    return null;
  }
  
  /// Valide un champ requis
  static String? required(String? value, [String fieldName = 'Ce champ']) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }
  
  /// Valide une adresse
  static String? address(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'adresse est requise';
    }
    if (value.length < 5) {
      return 'L\'adresse doit contenir au moins 5 caractères';
    }
    return null;
  }
  
  /// Valide un code OTP
  static String? otp(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'Le code est requis';
    }
    if (value.length != length) {
      return 'Le code doit contenir $length chiffres';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Le code ne doit contenir que des chiffres';
    }
    return null;
  }
  
  /// Valide un montant
  static String? amount(String? value, {double min = 0, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Le montant est requis';
    }
    final amount = double.tryParse(value.replaceAll(' ', '').replaceAll(',', '.'));
    if (amount == null) {
      return 'Veuillez entrer un montant valide';
    }
    if (amount < min) {
      return 'Le montant minimum est de ${min.toStringAsFixed(0)} FCFA';
    }
    if (max != null && amount > max) {
      return 'Le montant maximum est de ${max.toStringAsFixed(0)} FCFA';
    }
    return null;
  }
  
  /// Valide une quantité
  static String? quantity(String? value, {int min = 1, int? max}) {
    if (value == null || value.isEmpty) {
      return 'La quantité est requise';
    }
    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Veuillez entrer un nombre valide';
    }
    if (quantity < min) {
      return 'La quantité minimum est $min';
    }
    if (max != null && quantity > max) {
      return 'La quantité maximum est $max';
    }
    return null;
  }
  
  /// Combine plusieurs validateurs
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}

/// Extension pour créer des validateurs avec message personnalisé
extension ValidatorExtensions on String? Function(String?) {
  String? Function(String?) withMessage(String message) {
    return (value) {
      final result = this(value);
      return result != null ? message : null;
    };
  }
}
