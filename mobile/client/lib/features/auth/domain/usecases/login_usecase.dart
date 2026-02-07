import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_response_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthResponseEntity>> call({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return Left(
        ValidationFailure(
          message: 'Identifiant et mot de passe requis',
          errors: {
            'form': ['Identifiant et mot de passe requis'],
          },
        ),
      );
    }

    // Accept either email or phone number format
    if (!_isValidEmail(email) && !_isValidPhone(email)) {
      return Left(
        ValidationFailure(
          message: 'Format d\'identifiant invalide',
          errors: {
            'email': ['Veuillez entrer un email ou numéro de téléphone valide'],
          },
        ),
      );
    }

    if (password.length < 6) {
      return Left(
        ValidationFailure(
          message: 'Le mot de passe doit contenir au moins 6 caractères',
          errors: {
            'password': ['Le mot de passe doit contenir au moins 6 caractères'],
          },
        ),
      );
    }

    return await repository.login(email: email, password: password);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    // Accept phone numbers: at least 8 digits, may start with + or 0
    // Supports formats like: +22890123456, 0511223344, 90123456
    final phoneRegex = RegExp(r'^[+]?[0-9]{8,15}$');
    return phoneRegex.hasMatch(phone);
  }
}
