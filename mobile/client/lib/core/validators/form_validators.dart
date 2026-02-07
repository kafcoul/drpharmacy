/// Service centralisé de validation des formulaires
/// Assure une validation cohérente à travers l'application
library;

/// Classe utilitaire pour la validation des formulaires
class FormValidators {
  FormValidators._();

  // ===== VALIDATION TÉLÉPHONE =====

  /// Valide un numéro de téléphone gabonais
  /// Format accepté : +241 XX XX XX XX ou 0X XX XX XX XX
  static String? validatePhone(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Le numéro de téléphone est requis' : null;
    }

    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Format gabonais : +241XXXXXXXX ou 0XXXXXXXX
    final gabonRegex = RegExp(r'^(\+241|00241|0)?[0-9]{8,9}$');
    
    if (!gabonRegex.hasMatch(cleaned)) {
      return 'Numéro de téléphone invalide';
    }

    return null;
  }

  /// Valide un numéro WhatsApp
  static String? validateWhatsApp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optionnel
    }
    return validatePhone(value, required: false);
  }

  // ===== VALIDATION EMAIL =====

  /// Valide une adresse email
  static String? validateEmail(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'L\'email est requis' : null;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Adresse email invalide';
    }

    return null;
  }

  // ===== VALIDATION MOT DE PASSE =====

  /// Valide un mot de passe
  /// - Au moins 6 caractères
  /// - Au moins une lettre et un chiffre (optionnel selon strength)
  static String? validatePassword(
    String? value, {
    bool required = true,
    PasswordStrength strength = PasswordStrength.medium,
  }) {
    if (value == null || value.isEmpty) {
      return required ? 'Le mot de passe est requis' : null;
    }

    switch (strength) {
      case PasswordStrength.weak:
        if (value.length < 4) {
          return 'Au moins 4 caractères';
        }
        break;
      case PasswordStrength.medium:
        if (value.length < 6) {
          return 'Au moins 6 caractères';
        }
        break;
      case PasswordStrength.strong:
        if (value.length < 8) {
          return 'Au moins 8 caractères';
        }
        if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
          return 'Au moins une lettre';
        }
        if (!RegExp(r'[0-9]').hasMatch(value)) {
          return 'Au moins un chiffre';
        }
        break;
    }

    return null;
  }

  /// Valide la confirmation du mot de passe
  static String? validatePasswordConfirmation(
    String? value,
    String? password,
  ) {
    if (value == null || value.isEmpty) {
      return 'Confirmez le mot de passe';
    }

    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null;
  }

  // ===== VALIDATION NOM =====

  /// Valide un nom (prénom ou nom de famille)
  static String? validateName(
    String? value, {
    bool required = true,
    int minLength = 2,
    int maxLength = 50,
    String fieldName = 'Ce champ',
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName est requis' : null;
    }

    final trimmed = value.trim();

    if (trimmed.length < minLength) {
      return '$fieldName doit avoir au moins $minLength caractères';
    }

    if (trimmed.length > maxLength) {
      return '$fieldName ne peut pas dépasser $maxLength caractères';
    }

    // Vérifier qu'il ne contient pas de caractères spéciaux
    if (RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]').hasMatch(trimmed)) {
      return '$fieldName contient des caractères invalides';
    }

    return null;
  }

  /// Valide un prénom
  static String? validateFirstName(String? value, {bool required = true}) {
    return validateName(
      value,
      required: required,
      fieldName: 'Le prénom',
    );
  }

  /// Valide un nom de famille
  static String? validateLastName(String? value, {bool required = true}) {
    return validateName(
      value,
      required: required,
      fieldName: 'Le nom',
    );
  }

  // ===== VALIDATION ADRESSE =====

  /// Valide une adresse
  static String? validateAddress(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'L\'adresse est requise' : null;
    }

    if (value.trim().length < 5) {
      return 'Adresse trop courte (5 caractères minimum)';
    }

    if (value.trim().length > 200) {
      return 'Adresse trop longue (200 caractères maximum)';
    }

    return null;
  }

  /// Valide un quartier
  static String? validateQuartier(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Le quartier est requis' : null;
    }

    if (value.trim().length < 2) {
      return 'Nom de quartier trop court';
    }

    return null;
  }

  /// Valide une ville
  static String? validateCity(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'La ville est requise' : null;
    }

    if (value.trim().length < 2) {
      return 'Nom de ville trop court';
    }

    return null;
  }

  // ===== VALIDATION CODE OTP =====

  /// Valide un code OTP
  static String? validateOTP(
    String? value, {
    int length = 6,
    bool required = true,
  }) {
    if (value == null || value.isEmpty) {
      return required ? 'Le code de vérification est requis' : null;
    }

    if (value.length != length) {
      return 'Le code doit contenir $length chiffres';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Le code ne doit contenir que des chiffres';
    }

    return null;
  }

  // ===== VALIDATION QUANTITÉ =====

  /// Valide une quantité
  static String? validateQuantity(
    String? value, {
    int min = 1,
    int max = 99,
    bool required = true,
  }) {
    if (value == null || value.isEmpty) {
      return required ? 'La quantité est requise' : null;
    }

    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Quantité invalide';
    }

    if (quantity < min) {
      return 'Quantité minimum : $min';
    }

    if (quantity > max) {
      return 'Quantité maximum : $max';
    }

    return null;
  }

  // ===== VALIDATION MONTANT =====

  /// Valide un montant monétaire
  static String? validateAmount(
    String? value, {
    double min = 0,
    double? max,
    bool required = true,
  }) {
    if (value == null || value.isEmpty) {
      return required ? 'Le montant est requis' : null;
    }

    final amount = double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), ''));
    if (amount == null) {
      return 'Montant invalide';
    }

    if (amount < min) {
      return 'Montant minimum : ${min.toStringAsFixed(0)} FCFA';
    }

    if (max != null && amount > max) {
      return 'Montant maximum : ${max.toStringAsFixed(0)} FCFA';
    }

    return null;
  }

  // ===== VALIDATION ORDONNANCE =====

  /// Valide les notes d'une ordonnance
  static String? validatePrescriptionNotes(
    String? value, {
    int maxLength = 500,
  }) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }

    if (value.length > maxLength) {
      return 'Notes trop longues ($maxLength caractères maximum)';
    }

    return null;
  }

  // ===== VALIDATION CHAMP REQUIS GÉNÉRIQUE =====

  /// Valide qu'un champ n'est pas vide
  static String? validateRequired(
    String? value, {
    String fieldName = 'Ce champ',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  /// Valide qu'une sélection a été faite
  static String? validateSelection<T>(
    T? value, {
    String fieldName = 'Veuillez faire une sélection',
  }) {
    if (value == null) {
      return fieldName;
    }
    return null;
  }
}

/// Niveaux de force du mot de passe
enum PasswordStrength {
  /// Mot de passe simple (4+ caractères)
  weak,

  /// Mot de passe standard (6+ caractères)
  medium,

  /// Mot de passe fort (8+ caractères, lettres et chiffres)
  strong,
}

/// Extension pour faciliter la validation dans les formulaires
extension FormValidatorExtensions on String? {
  /// Vérifie si la chaîne est vide ou null
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;

  /// Vérifie si la chaîne n'est pas vide
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Nettoie le numéro de téléphone
  String get cleanedPhone {
    if (this == null) return '';
    return this!.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }
}
