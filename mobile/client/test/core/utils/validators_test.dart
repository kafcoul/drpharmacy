import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('should return error when email is null', () {
        expect(Validators.email(null), 'L\'email est requis');
      });

      test('should return error when email is empty', () {
        expect(Validators.email(''), 'L\'email est requis');
      });

      test('should return error for invalid email without @', () {
        expect(Validators.email('invalidemail'), 'Veuillez entrer un email valide');
      });

      test('should return error for invalid email without domain', () {
        expect(Validators.email('test@'), 'Veuillez entrer un email valide');
      });

      test('should return error for invalid email without TLD', () {
        expect(Validators.email('test@domain'), 'Veuillez entrer un email valide');
      });

      test('should return null for valid email', () {
        expect(Validators.email('test@example.com'), isNull);
      });

      test('should return null for valid email with subdomain', () {
        expect(Validators.email('test@mail.example.com'), isNull);
      });

      test('should return null for valid email with plus sign', () {
        expect(Validators.email('test+label@example.com'), isNull);
      });

      test('should return null for valid email with dots', () {
        expect(Validators.email('first.last@example.com'), isNull);
      });
    });

    group('password', () {
      test('should return error when password is null', () {
        expect(Validators.password(null), 'Le mot de passe est requis');
      });

      test('should return error when password is empty', () {
        expect(Validators.password(''), 'Le mot de passe est requis');
      });

      test('should return error when password is too short', () {
        expect(Validators.password('12345'), 'Le mot de passe doit contenir au moins 6 caractères');
      });

      test('should return null for valid password', () {
        expect(Validators.password('123456'), isNull);
      });

      test('should return null for long password', () {
        expect(Validators.password('verylongpassword123'), isNull);
      });
    });

    group('passwordStrict', () {
      test('should return error when password is null', () {
        expect(Validators.passwordStrict(null), 'Le mot de passe est requis');
      });

      test('should return error when password is empty', () {
        expect(Validators.passwordStrict(''), 'Le mot de passe est requis');
      });

      test('should return error when password is too short', () {
        expect(Validators.passwordStrict('Pass1'), 'Le mot de passe doit contenir au moins 8 caractères');
      });

      test('should return error when password has no uppercase', () {
        expect(Validators.passwordStrict('password1'), 'Le mot de passe doit contenir au moins une majuscule');
      });

      test('should return error when password has no lowercase', () {
        expect(Validators.passwordStrict('PASSWORD1'), 'Le mot de passe doit contenir au moins une minuscule');
      });

      test('should return error when password has no digit', () {
        expect(Validators.passwordStrict('Passwordd'), 'Le mot de passe doit contenir au moins un chiffre');
      });

      test('should return null for valid strict password', () {
        expect(Validators.passwordStrict('Password1'), isNull);
      });

      test('should return null for complex password', () {
        expect(Validators.passwordStrict('MyP@ssw0rd123'), isNull);
      });
    });

    group('confirmPassword', () {
      test('should return error when confirmation is null', () {
        expect(Validators.confirmPassword(null, 'password'), 'Veuillez confirmer le mot de passe');
      });

      test('should return error when confirmation is empty', () {
        expect(Validators.confirmPassword('', 'password'), 'Veuillez confirmer le mot de passe');
      });

      test('should return error when passwords do not match', () {
        expect(Validators.confirmPassword('different', 'password'), 'Les mots de passe ne correspondent pas');
      });

      test('should return null when passwords match', () {
        expect(Validators.confirmPassword('password', 'password'), isNull);
      });
    });

    group('phone', () {
      test('should return error when phone is null', () {
        expect(Validators.phone(null), 'Le numéro de téléphone est requis');
      });

      test('should return error when phone is empty', () {
        expect(Validators.phone(''), 'Le numéro de téléphone est requis');
      });

      test('should return error for invalid phone', () {
        expect(Validators.phone('123'), 'Veuillez entrer un numéro de téléphone valide');
      });

      test('should return null for valid phone with leading zero', () {
        expect(Validators.phone('0101020304'), isNull);
      });

      test('should return null for valid phone with +225', () {
        expect(Validators.phone('+2250101020304'), isNull);
      });

      test('should return null for valid phone with 00225', () {
        expect(Validators.phone('002250101020304'), isNull);
      });

      test('should return null for phone with spaces', () {
        expect(Validators.phone('01 01 02 03 04'), isNull);
      });

      test('should return null for phone with dashes', () {
        expect(Validators.phone('01-01-02-03-04'), isNull);
      });
    });

    group('name', () {
      test('should return error when name is null', () {
        expect(Validators.name(null), 'Ce champ est requis');
      });

      test('should return error when name is empty', () {
        expect(Validators.name(''), 'Ce champ est requis');
      });

      test('should return error when name is too short', () {
        expect(Validators.name('A'), 'Le nom doit contenir au moins 2 caractères');
      });

      test('should return error when name is too long', () {
        final longName = 'A' * 51;
        expect(Validators.name(longName), 'Le nom ne doit pas dépasser 50 caractères');
      });

      test('should return null for valid name', () {
        expect(Validators.name('John Doe'), isNull);
      });

      test('should return null for name at minimum length', () {
        expect(Validators.name('Ab'), isNull);
      });

      test('should return null for name at maximum length', () {
        final maxName = 'A' * 50;
        expect(Validators.name(maxName), isNull);
      });
    });

    group('required', () {
      test('should return error when value is null', () {
        expect(Validators.required(null), 'Ce champ est requis');
      });

      test('should return error when value is empty', () {
        expect(Validators.required(''), 'Ce champ est requis');
      });

      test('should return error with custom field name when null', () {
        expect(Validators.required(null, 'Email'), 'Email est requis');
      });

      test('should return null when value is not empty', () {
        expect(Validators.required('value'), isNull);
      });
    });

    group('address', () {
      test('should return error when address is null', () {
        expect(Validators.address(null), 'L\'adresse est requise');
      });

      test('should return error when address is empty', () {
        expect(Validators.address(''), 'L\'adresse est requise');
      });

      test('should return error when address is too short', () {
        expect(Validators.address('abcd'), 'L\'adresse doit contenir au moins 5 caractères');
      });

      test('should return null for valid address', () {
        expect(Validators.address('123 Main Street'), isNull);
      });

      test('should return null for address at minimum length', () {
        expect(Validators.address('abcde'), isNull);
      });
    });

    group('otp', () {
      test('should return error when OTP is null', () {
        expect(Validators.otp(null), 'Le code est requis');
      });

      test('should return error when OTP is empty', () {
        expect(Validators.otp(''), 'Le code est requis');
      });

      test('should return error when OTP has wrong length', () {
        expect(Validators.otp('12345'), 'Le code doit contenir 6 chiffres');
      });

      test('should return error when OTP has wrong length with custom length', () {
        expect(Validators.otp('123', length: 4), 'Le code doit contenir 4 chiffres');
      });

      test('should return error when OTP contains non-digits', () {
        expect(Validators.otp('12a456'), 'Le code ne doit contenir que des chiffres');
      });

      test('should return null for valid OTP', () {
        expect(Validators.otp('123456'), isNull);
      });

      test('should return null for valid OTP with custom length', () {
        expect(Validators.otp('1234', length: 4), isNull);
      });
    });

    group('amount', () {
      test('should return error when amount is null', () {
        expect(Validators.amount(null), 'Le montant est requis');
      });

      test('should return error when amount is empty', () {
        expect(Validators.amount(''), 'Le montant est requis');
      });

      test('should return error for invalid amount', () {
        expect(Validators.amount('abc'), 'Veuillez entrer un montant valide');
      });

      test('should return error when amount is below minimum', () {
        expect(Validators.amount('-10', min: 0), 'Le montant minimum est de 0 FCFA');
      });

      test('should return error when amount exceeds maximum', () {
        expect(Validators.amount('1000', max: 500), 'Le montant maximum est de 500 FCFA');
      });

      test('should return null for valid amount', () {
        expect(Validators.amount('100'), isNull);
      });

      test('should return null for amount with spaces', () {
        expect(Validators.amount('1 000'), isNull);
      });

      test('should return null for amount with comma decimal', () {
        expect(Validators.amount('100,50'), isNull);
      });

      test('should return null for amount with period decimal', () {
        expect(Validators.amount('100.50'), isNull);
      });

      test('should return null for amount at minimum', () {
        expect(Validators.amount('100', min: 100), isNull);
      });

      test('should return null for amount at maximum', () {
        expect(Validators.amount('500', max: 500), isNull);
      });
    });

    group('quantity', () {
      test('should return error when quantity is null', () {
        expect(Validators.quantity(null), 'La quantité est requise');
      });

      test('should return error when quantity is empty', () {
        expect(Validators.quantity(''), 'La quantité est requise');
      });

      test('should return error for invalid quantity', () {
        expect(Validators.quantity('abc'), 'Veuillez entrer un nombre valide');
      });

      test('should return error when quantity is below minimum', () {
        expect(Validators.quantity('0', min: 1), 'La quantité minimum est 1');
      });

      test('should return error when quantity exceeds maximum', () {
        expect(Validators.quantity('100', max: 10), 'La quantité maximum est 10');
      });

      test('should return null for valid quantity', () {
        expect(Validators.quantity('5'), isNull);
      });

      test('should return null for quantity at minimum', () {
        expect(Validators.quantity('1', min: 1), isNull);
      });

      test('should return null for quantity at maximum', () {
        expect(Validators.quantity('10', max: 10), isNull);
      });
    });

    group('combine', () {
      test('should return first error from validators', () {
        final result = Validators.combine('', [
          Validators.required,
          Validators.email,
        ]);
        expect(result, 'Ce champ est requis');
      });

      test('should return second error if first passes', () {
        final result = Validators.combine('invalid', [
          Validators.required,
          Validators.email,
        ]);
        expect(result, 'Veuillez entrer un email valide');
      });

      test('should return null if all validators pass', () {
        final result = Validators.combine('test@example.com', [
          Validators.required,
          Validators.email,
        ]);
        expect(result, isNull);
      });

      test('should return null for empty validators list', () {
        final result = Validators.combine('any value', []);
        expect(result, isNull);
      });
    });
  });

  group('ValidatorExtensions', () {
    test('withMessage should replace error message', () {
      final customValidator = Validators.required.withMessage('Custom error');
      expect(customValidator(null), 'Custom error');
    });

    test('withMessage should return null when validation passes', () {
      final customValidator = Validators.required.withMessage('Custom error');
      expect(customValidator('value'), isNull);
    });
  });
}
