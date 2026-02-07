import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/core/validators/form_validators.dart';

void main() {
  group('FormValidators - Phone', () {
    test('should return error for empty phone when required', () {
      // Act
      final result = FormValidators.validatePhone('', required: true);

      // Assert
      expect(result, isNotNull);
      expect(result, contains('requis'));
    });

    test('should return null for empty phone when not required', () {
      // Act
      final result = FormValidators.validatePhone('', required: false);

      // Assert
      expect(result, isNull);
    });

    test('should accept valid Gabonese phone with +241', () {
      // Act
      final result = FormValidators.validatePhone('+24112345678');

      // Assert
      expect(result, isNull);
    });

    test('should accept valid Gabonese phone with 0', () {
      // Act
      final result = FormValidators.validatePhone('012345678');

      // Assert
      expect(result, isNull);
    });

    test('should accept phone with spaces', () {
      // Act
      final result = FormValidators.validatePhone('+241 12 34 56 78');

      // Assert
      expect(result, isNull);
    });

    test('should reject invalid phone format', () {
      // Act
      final result = FormValidators.validatePhone('123');

      // Assert
      expect(result, isNotNull);
      expect(result, contains('invalide'));
    });

    test('should reject phone with letters', () {
      // Act
      final result = FormValidators.validatePhone('abc12345678');

      // Assert
      expect(result, isNotNull);
    });
  });

  group('FormValidators - WhatsApp', () {
    test('should return null for empty whatsapp (optional)', () {
      // Act
      final result = FormValidators.validateWhatsApp('');

      // Assert
      expect(result, isNull);
    });

    test('should accept valid whatsapp number', () {
      // Act
      final result = FormValidators.validateWhatsApp('+24112345678');

      // Assert
      expect(result, isNull);
    });
  });

  group('FormValidators - Email', () {
    test('should return error for empty email when required', () {
      // Act
      final result = FormValidators.validateEmail('', required: true);

      // Assert
      expect(result, isNotNull);
      expect(result, contains('requis'));
    });

    test('should return null for empty email when not required', () {
      // Act
      final result = FormValidators.validateEmail('', required: false);

      // Assert
      expect(result, isNull);
    });

    test('should accept valid email', () {
      // Act
      final result = FormValidators.validateEmail('test@example.com');

      // Assert
      expect(result, isNull);
    });

    test('should accept email with subdomain', () {
      // Act
      final result = FormValidators.validateEmail('test@mail.example.com');

      // Assert
      expect(result, isNull);
    });

    test('should accept email with plus sign', () {
      // Act
      final result = FormValidators.validateEmail('test+tag@example.com');

      // Assert
      expect(result, isNull);
    });

    test('should reject email without @', () {
      // Act
      final result = FormValidators.validateEmail('testexample.com');

      // Assert
      expect(result, isNotNull);
      expect(result, contains('invalide'));
    });

    test('should reject email without domain', () {
      // Act
      final result = FormValidators.validateEmail('test@');

      // Assert
      expect(result, isNotNull);
    });

    test('should reject email with spaces', () {
      // Act
      final result = FormValidators.validateEmail('test @example.com');

      // Assert
      expect(result, isNotNull);
    });
  });

  group('FormValidators - Password', () {
    test('should return error for empty password when required', () {
      // Act
      final result = FormValidators.validatePassword('', required: true);

      // Assert
      expect(result, isNotNull);
      expect(result, contains('requis'));
    });

    test('should return null for empty password when not required', () {
      // Act
      final result = FormValidators.validatePassword('', required: false);

      // Assert
      expect(result, isNull);
    });

    test('should accept weak password with 4 characters', () {
      // Act
      final result = FormValidators.validatePassword(
        'abcd',
        strength: PasswordStrength.weak,
      );

      // Assert
      expect(result, isNull);
    });

    test('should reject weak password with less than 4 characters', () {
      // Act
      final result = FormValidators.validatePassword(
        'abc',
        strength: PasswordStrength.weak,
      );

      // Assert
      expect(result, isNotNull);
      expect(result, contains('4'));
    });

    test('should accept medium password with 6 characters', () {
      // Act
      final result = FormValidators.validatePassword(
        'abcdef',
        strength: PasswordStrength.medium,
      );

      // Assert
      expect(result, isNull);
    });

    test('should reject medium password with less than 6 characters', () {
      // Act
      final result = FormValidators.validatePassword(
        'abcde',
        strength: PasswordStrength.medium,
      );

      // Assert
      expect(result, isNotNull);
      expect(result, contains('6'));
    });

    test('should accept strong password with 8+ chars, letter and digit', () {
      // Act
      final result = FormValidators.validatePassword(
        'abcdef12',
        strength: PasswordStrength.strong,
      );

      // Assert
      expect(result, isNull);
    });

    test('should reject strong password without letter', () {
      // Act
      final result = FormValidators.validatePassword(
        '12345678',
        strength: PasswordStrength.strong,
      );

      // Assert
      expect(result, isNotNull);
      expect(result, contains('lettre'));
    });

    test('should reject strong password without digit', () {
      // Act
      final result = FormValidators.validatePassword(
        'abcdefgh',
        strength: PasswordStrength.strong,
      );

      // Assert
      expect(result, isNotNull);
      expect(result, contains('chiffre'));
    });
  });

  group('FormValidators - Password Confirmation', () {
    test('should return error for empty confirmation', () {
      // Act
      final result = FormValidators.validatePasswordConfirmation('', 'password');

      // Assert
      expect(result, isNotNull);
      expect(result, contains('Confirmez'));
    });

    test('should return error when passwords do not match', () {
      // Act
      final result = FormValidators.validatePasswordConfirmation('pass1', 'pass2');

      // Assert
      expect(result, isNotNull);
      expect(result, contains('correspondent pas'));
    });

    test('should return null when passwords match', () {
      // Act
      final result = FormValidators.validatePasswordConfirmation('password', 'password');

      // Assert
      expect(result, isNull);
    });
  });

  group('FormValidators - Name', () {
    test('should return error for empty name when required', () {
      // Act
      final result = FormValidators.validateName('', required: true);

      // Assert
      expect(result, isNotNull);
      expect(result, contains('requis'));
    });

    test('should return null for empty name when not required', () {
      // Act
      final result = FormValidators.validateName('', required: false);

      // Assert
      expect(result, isNull);
    });

    test('should accept valid name', () {
      // Act
      final result = FormValidators.validateName('Jean');

      // Assert
      expect(result, isNull);
    });

    test('should reject name with less than min length', () {
      // Act
      final result = FormValidators.validateName('A', minLength: 2);

      // Assert
      expect(result, isNotNull);
      expect(result, contains('au moins'));
    });

    test('should reject name with more than max length', () {
      // Act
      final result = FormValidators.validateName('A' * 51, maxLength: 50);

      // Assert
      expect(result, isNotNull);
      expect(result, contains('dépasser'));
    });

    test('should reject name with numbers', () {
      // Act
      final result = FormValidators.validateName('Jean123');

      // Assert
      expect(result, isNotNull);
      expect(result, contains('invalides'));
    });

    test('should reject name with special characters', () {
      // Act
      final result = FormValidators.validateName('Jean@#');

      // Assert
      expect(result, isNotNull);
      expect(result, contains('invalides'));
    });

    test('should accept name with accents', () {
      // Act
      final result = FormValidators.validateName('André');

      // Assert
      expect(result, isNull);
    });

    test('should accept name with hyphen', () {
      // Act
      final result = FormValidators.validateName('Jean-Pierre');

      // Assert
      expect(result, isNull);
    });
  });

  group('FormValidators - FirstName', () {
    test('should validate first name', () {
      // Act
      final result = FormValidators.validateFirstName('Jean');

      // Assert
      expect(result, isNull);
    });

    test('should return error with correct field name', () {
      // Act
      final result = FormValidators.validateFirstName('');

      // Assert
      expect(result, contains('prénom'));
    });
  });

  group('FormValidators - LastName', () {
    test('should validate last name', () {
      // Act
      final result = FormValidators.validateLastName('Dupont');

      // Assert
      expect(result, isNull);
    });

    test('should return error with correct field name', () {
      // Act
      final result = FormValidators.validateLastName('');

      // Assert
      expect(result, contains('nom'));
    });
  });

  group('FormValidators - Address', () {
    test('should return error for empty address when required', () {
      // Act
      final result = FormValidators.validateAddress('', required: true);

      // Assert
      expect(result, isNotNull);
      expect(result, contains('requise'));
    });

    test('should return null for empty address when not required', () {
      // Act
      final result = FormValidators.validateAddress('', required: false);

      // Assert
      expect(result, isNull);
    });

    test('should accept valid address', () {
      // Act
      final result = FormValidators.validateAddress('123 Rue de la Paix');

      // Assert
      expect(result, isNull);
    });

    test('should reject too short address', () {
      // Act
      final result = FormValidators.validateAddress('abc');

      // Assert
      expect(result, isNotNull);
      expect(result, contains('trop courte'));
    });

    test('should reject too long address', () {
      // Act
      final result = FormValidators.validateAddress('A' * 201);

      // Assert
      expect(result, isNotNull);
      expect(result, contains('trop longue'));
    });
  });

  group('FormValidators - Quartier', () {
    test('should return error for empty quartier when required', () {
      // Act
      final result = FormValidators.validateQuartier('', required: true);

      // Assert
      expect(result, isNotNull);
      expect(result, contains('requis'));
    });

    test('should accept valid quartier', () {
      // Act
      final result = FormValidators.validateQuartier('Akebe');

      // Assert
      expect(result, isNull);
    });

    test('should reject too short quartier', () {
      // Act
      final result = FormValidators.validateQuartier('A');

      // Assert
      expect(result, isNotNull);
      expect(result, contains('trop court'));
    });
  });

  group('FormValidators - City', () {
    test('should return error for empty city when required', () {
      // Act
      final result = FormValidators.validateCity('', required: true);

      // Assert
      expect(result, isNotNull);
      expect(result, contains('requise'));
    });

    test('should accept valid city', () {
      // Act
      final result = FormValidators.validateCity('Libreville');

      // Assert
      expect(result, isNull);
    });

    test('should reject too short city', () {
      // Act
      final result = FormValidators.validateCity('A');

      // Assert
      expect(result, isNotNull);
      expect(result, contains('trop court'));
    });
  });

  group('FormValidators - OTP', () {
    test('should return error for empty OTP when required', () {
      // Act
      final result = FormValidators.validateOTP('', required: true);

      // Assert
      expect(result, isNotNull);
      expect(result, contains('requis'));
    });

    test('should return null for empty OTP when not required', () {
      // Act
      final result = FormValidators.validateOTP('', required: false);

      // Assert
      expect(result, isNull);
    });

    test('should accept valid 6-digit OTP', () {
      // Act
      final result = FormValidators.validateOTP('123456');

      // Assert
      expect(result, isNull);
    });

    test('should reject OTP with wrong length', () {
      // Act
      final result = FormValidators.validateOTP('12345');

      // Assert
      expect(result, isNotNull);
      expect(result, contains('6'));
    });

    test('should accept 4-digit OTP when specified', () {
      // Act
      final result = FormValidators.validateOTP('1234', length: 4);

      // Assert
      expect(result, isNull);
    });

    test('should reject OTP with letters', () {
      // Act
      final result = FormValidators.validateOTP('12345a');

      // Assert
      expect(result, isNotNull);
      expect(result, contains('chiffres'));
    });
  });

  group('FormValidators - Quantity', () {
    test('should return error for empty quantity when required', () {
      // Act
      final result = FormValidators.validateQuantity('', required: true);

      // Assert
      expect(result, isNotNull);
      expect(result, contains('requise'));
    });

    test('should return null for empty quantity when not required', () {
      // Act
      final result = FormValidators.validateQuantity('', required: false);

      // Assert
      expect(result, isNull);
    });

    test('should accept valid quantity', () {
      // Act
      final result = FormValidators.validateQuantity('5');

      // Assert
      expect(result, isNull);
    });

    test('should reject quantity below minimum', () {
      // Act
      final result = FormValidators.validateQuantity('0', min: 1);

      // Assert
      expect(result, isNotNull);
      expect(result, contains('minimum'));
    });

    test('should reject quantity above maximum', () {
      // Act
      final result = FormValidators.validateQuantity('100', max: 99);

      // Assert
      expect(result, isNotNull);
      expect(result, contains('maximum'));
    });

    test('should reject non-numeric quantity', () {
      // Act
      final result = FormValidators.validateQuantity('abc');

      // Assert
      expect(result, isNotNull);
      expect(result, contains('invalide'));
    });
  });

  group('FormValidators - Amount', () {
    test('should return error for empty amount when required', () {
      // Act
      final result = FormValidators.validateAmount('', required: true);

      // Assert
      expect(result, isNotNull);
      expect(result, contains('requis'));
    });

    test('should return null for empty amount when not required', () {
      // Act
      final result = FormValidators.validateAmount('', required: false);

      // Assert
      expect(result, isNull);
    });

    test('should accept valid amount', () {
      // Act
      final result = FormValidators.validateAmount('1000');

      // Assert
      expect(result, isNull);
    });

    test('should accept amount with decimal', () {
      // Act
      final result = FormValidators.validateAmount('1000.50');

      // Assert
      expect(result, isNull);
    });

    test('should reject amount below minimum', () {
      // Act
      final result = FormValidators.validateAmount('50', min: 100);

      // Assert
      expect(result, isNotNull);
      expect(result, contains('minimum'));
    });

    test('should reject amount above maximum', () {
      // Act
      final result = FormValidators.validateAmount('10000', max: 5000);

      // Assert
      expect(result, isNotNull);
      expect(result, contains('maximum'));
    });

    test('should reject non-numeric amount', () {
      // Act
      final result = FormValidators.validateAmount('abc');

      // Assert
      expect(result, isNotNull);
      expect(result, contains('invalide'));
    });
  });

  group('FormValidators - Prescription Notes', () {
    test('should return null for empty notes (optional)', () {
      // Act
      final result = FormValidators.validatePrescriptionNotes('');

      // Assert
      expect(result, isNull);
    });

    test('should accept valid notes', () {
      // Act
      final result = FormValidators.validatePrescriptionNotes(
        'Prendre 2 fois par jour',
      );

      // Assert
      expect(result, isNull);
    });

    test('should reject notes exceeding max length', () {
      // Act
      final result = FormValidators.validatePrescriptionNotes(
        'A' * 501,
        maxLength: 500,
      );

      // Assert
      expect(result, isNotNull);
      expect(result, contains('trop longues'));
    });
  });

  group('FormValidators - Required', () {
    test('should return error for empty value', () {
      // Act
      final result = FormValidators.validateRequired('');

      // Assert
      expect(result, isNotNull);
      expect(result, contains('requis'));
    });

    test('should return error with custom field name', () {
      // Act
      final result = FormValidators.validateRequired(
        '',
        fieldName: 'Le champ test',
      );

      // Assert
      expect(result, contains('Le champ test'));
    });

    test('should return null for non-empty value', () {
      // Act
      final result = FormValidators.validateRequired('some value');

      // Assert
      expect(result, isNull);
    });
  });

  group('FormValidators - Selection', () {
    test('should return error for null selection', () {
      // Act
      final result = FormValidators.validateSelection<String>(null);

      // Assert
      expect(result, isNotNull);
    });

    test('should return error with custom message', () {
      // Act
      final result = FormValidators.validateSelection<String>(
        null,
        fieldName: 'Veuillez choisir une option',
      );

      // Assert
      expect(result, 'Veuillez choisir une option');
    });

    test('should return null for valid selection', () {
      // Act
      final result = FormValidators.validateSelection<String>('selected');

      // Assert
      expect(result, isNull);
    });
  });

  group('FormValidatorExtensions - isNullOrEmpty', () {
    test('should return true for null', () {
      // Arrange
      const String? value = null;

      // Act & Assert
      expect(value.isNullOrEmpty, isTrue);
    });

    test('should return true for empty string', () {
      // Arrange
      const value = '';

      // Act & Assert
      expect(value.isNullOrEmpty, isTrue);
    });

    test('should return true for whitespace only', () {
      // Arrange
      const value = '   ';

      // Act & Assert
      expect(value.isNullOrEmpty, isTrue);
    });

    test('should return false for non-empty string', () {
      // Arrange
      const value = 'hello';

      // Act & Assert
      expect(value.isNullOrEmpty, isFalse);
    });
  });

  group('FormValidatorExtensions - isNotNullOrEmpty', () {
    test('should return false for null', () {
      // Arrange
      const String? value = null;

      // Act & Assert
      expect(value.isNotNullOrEmpty, isFalse);
    });

    test('should return true for non-empty string', () {
      // Arrange
      const value = 'hello';

      // Act & Assert
      expect(value.isNotNullOrEmpty, isTrue);
    });
  });

  group('FormValidatorExtensions - cleanedPhone', () {
    test('should return empty for null', () {
      // Arrange
      const String? value = null;

      // Act & Assert
      expect(value.cleanedPhone, isEmpty);
    });

    test('should remove spaces from phone', () {
      // Arrange
      const value = '+241 12 34 56 78';

      // Act & Assert
      expect(value.cleanedPhone, '+24112345678');
    });

    test('should remove dashes from phone', () {
      // Arrange
      const value = '+241-12-34-56-78';

      // Act & Assert
      expect(value.cleanedPhone, '+24112345678');
    });

    test('should remove parentheses from phone', () {
      // Arrange
      const value = '(+241) 12345678';

      // Act & Assert
      expect(value.cleanedPhone, '+24112345678');
    });
  });

  group('PasswordStrength enum', () {
    test('should have three values', () {
      // Assert
      expect(PasswordStrength.values.length, 3);
    });

    test('should contain weak, medium, strong', () {
      // Assert
      expect(PasswordStrength.values, contains(PasswordStrength.weak));
      expect(PasswordStrength.values, contains(PasswordStrength.medium));
      expect(PasswordStrength.values, contains(PasswordStrength.strong));
    });
  });
}
