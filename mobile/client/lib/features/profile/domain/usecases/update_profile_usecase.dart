import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';
import '../entities/update_profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase({required this.repository});

  Future<Either<Failure, ProfileEntity>> call(
    UpdateProfileEntity updateProfile,
  ) async {
    // Validation
    if (updateProfile.name != null && updateProfile.name!.trim().isEmpty) {
      return Left(
        ValidationFailure(
          message: 'Le nom est requis',
          errors: {'name': ['Le nom ne peut pas être vide']},
        ),
      );
    }

    if (updateProfile.email != null) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(updateProfile.email!)) {
        return Left(
          ValidationFailure(
            message: 'Email invalide',
            errors: {'email': ['Veuillez entrer un email valide']},
          ),
        );
      }
    }

    if (updateProfile.phone != null &&
        updateProfile.phone!.isNotEmpty &&
        updateProfile.phone!.length < 8) {
      return Left(
        ValidationFailure(
          message: 'Téléphone invalide',
          errors: {
            'phone': ['Le numéro doit contenir au moins 8 chiffres'],
          },
        ),
      );
    }

    if (updateProfile.hasPasswordChange) {
      if (updateProfile.currentPassword!.isEmpty) {
        return Left(
          ValidationFailure(
            message: 'Mot de passe actuel requis',
            errors: {
              'current_password': ['Le mot de passe actuel est requis'],
            },
          ),
        );
      }

      if (updateProfile.newPassword!.length < 8) {
        return Left(
          ValidationFailure(
            message: 'Mot de passe trop court',
            errors: {
              'password': ['Le mot de passe doit contenir au moins 8 caractères'],
            },
          ),
        );
      }

      if (updateProfile.newPassword != updateProfile.newPasswordConfirmation) {
        return Left(
          ValidationFailure(
            message: 'Les mots de passe ne correspondent pas',
            errors: {
              'password_confirmation': [
                'Les mots de passe ne correspondent pas',
              ],
            },
          ),
        );
      }
    }

    return await repository.updateProfile(updateProfile);
  }
}
