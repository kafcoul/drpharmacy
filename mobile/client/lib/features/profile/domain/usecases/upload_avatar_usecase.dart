import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

class UploadAvatarUseCase {
  final ProfileRepository repository;

  UploadAvatarUseCase({required this.repository});

  Future<Either<Failure, String>> call(Uint8List imageBytes) async {
    // Validation de la taille (max 5MB)
    if (imageBytes.isEmpty) {
      return Left(
        ValidationFailure(
          message: 'Image invalide',
          errors: {'avatar': ['Aucune image sélectionnée']},
        ),
      );
    }

    const maxSize = 5 * 1024 * 1024; // 5MB
    if (imageBytes.length > maxSize) {
      return Left(
        ValidationFailure(
          message: 'Image trop volumineuse',
          errors: {
            'avatar': ['L\'image ne doit pas dépasser 5MB'],
          },
        ),
      );
    }

    return await repository.uploadAvatar(imageBytes);
  }
}
