/// Service de sanitisation des entrées utilisateur
/// Protège contre les injections XSS, SQL et autres attaques
library;

/// Classe utilitaire pour la sanitisation des entrées
class InputSanitizer {
  InputSanitizer._();

  // ===== PATTERNS DANGEREUX =====

  /// Patterns XSS courants
  static final List<RegExp> _xssPatterns = [
    RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true),
    RegExp(r'javascript:', caseSensitive: false),
    RegExp(r'on\w+\s*=', caseSensitive: false), // onclick, onerror, etc.
    RegExp(r'<iframe[^>]*>', caseSensitive: false),
    RegExp(r'<object[^>]*>', caseSensitive: false),
    RegExp(r'<embed[^>]*>', caseSensitive: false),
    RegExp(r'<link[^>]*>', caseSensitive: false),
    RegExp(r'<style[^>]*>.*?</style>', caseSensitive: false, dotAll: true),
    RegExp(r'expression\s*\(', caseSensitive: false),
    RegExp(r'url\s*\(', caseSensitive: false),
    RegExp(r'data:', caseSensitive: false),
    RegExp(r'vbscript:', caseSensitive: false),
  ];

  /// Patterns d'injection SQL
  static final List<RegExp> _sqlPatterns = [
    // Pattern: ['"]? (or|and) ['"]? 1=1
    RegExp(r'[\x27\x22]?\s*(or|and)\s*[\x27\x22]?1\s*=\s*1', caseSensitive: false),
    RegExp(r';\s*(drop|delete|truncate|alter|update|insert)', caseSensitive: false),
    RegExp(r'union\s+(all\s+)?select', caseSensitive: false),
    RegExp(r'--\s*$', multiLine: true),
    RegExp(r'/\*.*?\*/', dotAll: true),
  ];

  /// Caractères dangereux
  static const String _dangerousChars = '<>"\'/\\`';

  // ===== SANITISATION DE BASE =====

  /// Sanitise une chaîne de texte générique
  /// Supprime les balises HTML et les caractères dangereux
  static String sanitize(String? input) {
    if (input == null || input.isEmpty) return '';

    String sanitized = input;

    // Supprimer les balises HTML
    sanitized = _stripHtmlTags(sanitized);

    // Encoder les caractères spéciaux HTML
    sanitized = _encodeHtmlEntities(sanitized);

    // Supprimer les patterns XSS
    sanitized = _removeXssPatterns(sanitized);

    // Trim et normaliser les espaces
    sanitized = _normalizeWhitespace(sanitized);

    return sanitized;
  }

  /// Sanitise un texte pour affichage (préserve certains caractères)
  static String sanitizeForDisplay(String? input) {
    if (input == null || input.isEmpty) return '';

    String sanitized = input;

    // Supprimer uniquement les patterns dangereux
    sanitized = _removeXssPatterns(sanitized);
    sanitized = _stripHtmlTags(sanitized);

    return sanitized.trim();
  }

  /// Sanitise un email
  static String sanitizeEmail(String? input) {
    if (input == null || input.isEmpty) return '';

    // Supprimer les espaces et convertir en minuscules
    String sanitized = input.trim().toLowerCase();

    // Supprimer les caractères non autorisés dans un email
    sanitized = sanitized.replaceAll(RegExp(r'[^\w.@+-]'), '');

    return sanitized;
  }

  /// Sanitise un numéro de téléphone
  static String sanitizePhone(String? input) {
    if (input == null || input.isEmpty) return '';

    // Garder uniquement les chiffres et le +
    return input.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Sanitise un nom (prénom ou nom de famille)
  static String sanitizeName(String? input) {
    if (input == null || input.isEmpty) return '';

    String sanitized = input.trim();

    // Supprimer les chiffres et caractères spéciaux
    sanitized = sanitized.replaceAll(RegExp(r'[0-9!@#$%^&*(),.?":{}|<>\\\/\[\]]'), '');

    // Normaliser les espaces
    sanitized = _normalizeWhitespace(sanitized);

    // Capitaliser
    if (sanitized.isNotEmpty) {
      sanitized = sanitized
          .split(' ')
          .map((word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : word)
          .join(' ');
    }

    return sanitized;
  }

  /// Sanitise une adresse
  static String sanitizeAddress(String? input) {
    if (input == null || input.isEmpty) return '';

    String sanitized = input.trim();

    // Supprimer les balises HTML et patterns dangereux
    sanitized = _stripHtmlTags(sanitized);
    sanitized = _removeXssPatterns(sanitized);

    // Autoriser lettres, chiffres, espaces et ponctuation basique
    // Supprimer: < > " ' \ [ ] { } | ^ `
    sanitized = sanitized.replaceAll(RegExp(r'[<>\x22\x27\\{}\[\]|^`]'), '');

    return _normalizeWhitespace(sanitized);
  }

  /// Sanitise une URL
  static String? sanitizeUrl(String? input) {
    if (input == null || input.isEmpty) return null;

    String sanitized = input.trim();

    // Vérifier le protocole
    if (!sanitized.startsWith('http://') && !sanitized.startsWith('https://')) {
      // Ajouter https:// par défaut si pas de protocole
      if (!sanitized.contains('://')) {
        sanitized = 'https://$sanitized';
      } else {
        // Protocole non autorisé (javascript:, data:, etc.)
        return null;
      }
    }

    // Vérifier les patterns dangereux
    if (_containsXss(sanitized) || _containsSqlInjection(sanitized)) {
      return null;
    }

    try {
      final uri = Uri.parse(sanitized);
      if (uri.host.isEmpty) return null;
      return uri.toString();
    } catch (_) {
      return null;
    }
  }

  /// Sanitise un montant
  static String sanitizeAmount(String? input) {
    if (input == null || input.isEmpty) return '';

    // Garder uniquement les chiffres et le point décimal
    String sanitized = input.replaceAll(RegExp(r'[^\d.]'), '');

    // S'assurer qu'il n'y a qu'un seul point
    final parts = sanitized.split('.');
    if (parts.length > 2) {
      sanitized = '${parts[0]}.${parts.sublist(1).join('')}';
    }

    return sanitized;
  }

  /// Sanitise un code OTP
  static String sanitizeOtp(String? input) {
    if (input == null || input.isEmpty) return '';

    // Garder uniquement les chiffres
    return input.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Sanitise du contenu pour un champ de recherche
  static String sanitizeSearchQuery(String? input) {
    if (input == null || input.isEmpty) return '';

    String sanitized = input.trim();

    // Supprimer les patterns dangereux
    sanitized = _removeXssPatterns(sanitized);
    sanitized = _removeSqlPatterns(sanitized);

    // Limiter la longueur
    if (sanitized.length > 100) {
      sanitized = sanitized.substring(0, 100);
    }

    return sanitized;
  }

  // ===== VALIDATION DE SÉCURITÉ =====

  /// Vérifie si une chaîne contient des patterns XSS
  static bool _containsXss(String input) {
    for (final pattern in _xssPatterns) {
      if (pattern.hasMatch(input)) return true;
    }
    return false;
  }

  /// Vérifie si une chaîne contient des patterns d'injection SQL
  static bool _containsSqlInjection(String input) {
    for (final pattern in _sqlPatterns) {
      if (pattern.hasMatch(input)) return true;
    }
    return false;
  }

  /// Vérifie si l'entrée est potentiellement malveillante
  static bool isMalicious(String? input) {
    if (input == null || input.isEmpty) return false;
    return _containsXss(input) || _containsSqlInjection(input);
  }

  /// Vérifie si une chaîne contient des caractères dangereux
  static bool containsDangerousChars(String? input) {
    if (input == null || input.isEmpty) return false;
    
    for (int i = 0; i < _dangerousChars.length; i++) {
      if (input.contains(_dangerousChars[i])) return true;
    }
    return false;
  }

  // ===== HELPERS PRIVÉS =====

  /// Supprime les balises HTML
  static String _stripHtmlTags(String input) {
    return input.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Encode les entités HTML
  static String _encodeHtmlEntities(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  /// Supprime les patterns XSS
  static String _removeXssPatterns(String input) {
    String result = input;
    for (final pattern in _xssPatterns) {
      result = result.replaceAll(pattern, '');
    }
    return result;
  }

  /// Supprime les patterns SQL dangereux
  static String _removeSqlPatterns(String input) {
    String result = input;
    for (final pattern in _sqlPatterns) {
      result = result.replaceAll(pattern, '');
    }
    return result;
  }

  /// Normalise les espaces (supprime les multiples espaces)
  static String _normalizeWhitespace(String input) {
    return input.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

/// Extension pour faciliter la sanitisation
extension SanitizationExtension on String? {
  /// Sanitise la chaîne
  String get sanitized => InputSanitizer.sanitize(this);

  /// Sanitise pour affichage
  String get sanitizedForDisplay => InputSanitizer.sanitizeForDisplay(this);

  /// Sanitise comme email
  String get sanitizedEmail => InputSanitizer.sanitizeEmail(this);

  /// Sanitise comme téléphone
  String get sanitizedPhone => InputSanitizer.sanitizePhone(this);

  /// Sanitise comme nom
  String get sanitizedName => InputSanitizer.sanitizeName(this);

  /// Sanitise comme adresse
  String get sanitizedAddress => InputSanitizer.sanitizeAddress(this);

  /// Sanitise comme montant
  String get sanitizedAmount => InputSanitizer.sanitizeAmount(this);

  /// Vérifie si potentiellement malveillant
  bool get isMalicious => InputSanitizer.isMalicious(this);
}

/// Service de validation sécurisée combinant validation et sanitisation
class SecureValidator {
  SecureValidator._();

  /// Valide et sanitise un email
  static ValidationResult validateEmail(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required
          ? ValidationResult.invalid('L\'email est requis')
          : ValidationResult.valid('');
    }

    final sanitized = InputSanitizer.sanitizeEmail(value);

    if (InputSanitizer.isMalicious(value)) {
      return ValidationResult.invalid('Contenu non autorisé détecté');
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(sanitized)) {
      return ValidationResult.invalid('Adresse email invalide');
    }

    return ValidationResult.valid(sanitized);
  }

  /// Valide et sanitise un téléphone
  static ValidationResult validatePhone(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required
          ? ValidationResult.invalid('Le numéro de téléphone est requis')
          : ValidationResult.valid('');
    }

    final sanitized = InputSanitizer.sanitizePhone(value);

    // Format gabonais
    final gabonRegex = RegExp(r'^(\+241|00241|0)?[0-9]{8,9}$');

    if (!gabonRegex.hasMatch(sanitized)) {
      return ValidationResult.invalid('Numéro de téléphone invalide');
    }

    return ValidationResult.valid(sanitized);
  }

  /// Valide et sanitise un nom
  static ValidationResult validateName(
    String? value, {
    bool required = true,
    String fieldName = 'Ce champ',
    int minLength = 2,
    int maxLength = 50,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required
          ? ValidationResult.invalid('$fieldName est requis')
          : ValidationResult.valid('');
    }

    if (InputSanitizer.isMalicious(value)) {
      return ValidationResult.invalid('Contenu non autorisé détecté');
    }

    final sanitized = InputSanitizer.sanitizeName(value);

    if (sanitized.length < minLength) {
      return ValidationResult.invalid(
          '$fieldName doit avoir au moins $minLength caractères');
    }

    if (sanitized.length > maxLength) {
      return ValidationResult.invalid(
          '$fieldName ne peut pas dépasser $maxLength caractères');
    }

    return ValidationResult.valid(sanitized);
  }

  /// Valide et sanitise une adresse
  static ValidationResult validateAddress(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required
          ? ValidationResult.invalid('L\'adresse est requise')
          : ValidationResult.valid('');
    }

    if (InputSanitizer.isMalicious(value)) {
      return ValidationResult.invalid('Contenu non autorisé détecté');
    }

    final sanitized = InputSanitizer.sanitizeAddress(value);

    if (sanitized.length < 5) {
      return ValidationResult.invalid('Adresse trop courte');
    }

    if (sanitized.length > 200) {
      return ValidationResult.invalid('Adresse trop longue');
    }

    return ValidationResult.valid(sanitized);
  }

  /// Valide et sanitise un OTP
  static ValidationResult validateOtp(
    String? value, {
    int length = 6,
    bool required = true,
  }) {
    if (value == null || value.isEmpty) {
      return required
          ? ValidationResult.invalid('Le code est requis')
          : ValidationResult.valid('');
    }

    final sanitized = InputSanitizer.sanitizeOtp(value);

    if (sanitized.length != length) {
      return ValidationResult.invalid('Le code doit contenir $length chiffres');
    }

    return ValidationResult.valid(sanitized);
  }

  /// Valide et sanitise un montant
  static ValidationResult validateAmount(
    String? value, {
    double min = 0,
    double? max,
    bool required = true,
  }) {
    if (value == null || value.isEmpty) {
      return required
          ? ValidationResult.invalid('Le montant est requis')
          : ValidationResult.valid('');
    }

    final sanitized = InputSanitizer.sanitizeAmount(value);
    final amount = double.tryParse(sanitized);

    if (amount == null) {
      return ValidationResult.invalid('Montant invalide');
    }

    if (amount < min) {
      return ValidationResult.invalid('Montant minimum : ${min.toStringAsFixed(0)} FCFA');
    }

    if (max != null && amount > max) {
      return ValidationResult.invalid('Montant maximum : ${max.toStringAsFixed(0)} FCFA');
    }

    return ValidationResult.valid(sanitized);
  }

  /// Valide et sanitise une recherche
  static ValidationResult validateSearchQuery(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationResult.valid('');
    }

    final sanitized = InputSanitizer.sanitizeSearchQuery(value);

    return ValidationResult.valid(sanitized);
  }
}

/// Résultat de validation avec valeur sanitisée
class ValidationResult {
  final bool isValid;
  final String? error;
  final String sanitizedValue;

  const ValidationResult._({
    required this.isValid,
    this.error,
    required this.sanitizedValue,
  });

  factory ValidationResult.valid(String sanitizedValue) {
    return ValidationResult._(
      isValid: true,
      sanitizedValue: sanitizedValue,
    );
  }

  factory ValidationResult.invalid(String error) {
    return ValidationResult._(
      isValid: false,
      error: error,
      sanitizedValue: '',
    );
  }

  /// Retourne l'erreur ou null si valide (pour les formulaires)
  String? get errorOrNull => isValid ? null : error;
}
