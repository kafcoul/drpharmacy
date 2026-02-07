import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_response_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, AuthResponseEntity>> call({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? address,
  }) async {
    // Validation
    if (name.isEmpty) {
      return Left(
        ValidationFailure(
          message: 'Le nom est requis',
          errors: {
            'name': ['Le nom est requis'],
          },
        ),
      );
    }

    if (email.isEmpty || !_isValidEmail(email)) {
      return Left(
        ValidationFailure(
          message: 'Format d\'email invalide',
          errors: {
            'email': ['Format d\'email invalide'],
          },
        ),
      );
    }

    if (phone.isEmpty || !_isValidPhone(phone)) {
      return Left(
        ValidationFailure(
          message: 'Numéro de téléphone invalide',
          errors: {
            'phone': ['Numéro de téléphone invalide'],
          },
        ),
      );
    }

    if (password.isEmpty || password.length < 6) {
      return Left(
        ValidationFailure(
          message: 'Le mot de passe doit contenir au moins 6 caractères',
          errors: {
            'password': ['Le mot de passe doit contenir au moins 6 caractères'],
          },
        ),
      );
    }

    if (password != passwordConfirmation) {
      return Left(
        ValidationFailure(
          message: 'Les mots de passe ne correspondent pas',
          errors: {
            'password': ['Les mots de passe ne correspondent pas'],
          },
        ),
      );
    }

    return await repository.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      address: address,
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    // Accept international phone formats: at least 8 digits, may start with + or country code
    // Supports: +22890123456, 0511223344, 90123456, +225 01 23 45 67 89
    final cleanPhone = phone.replaceAll(RegExp(r'\s'), '');
    final phoneRegex = RegExp(r'^[+]?[0-9]{8,15}$');
    return phoneRegex.hasMatch(cleanPhone);
  }
}
