import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../entities/prescription_entity.dart';
import '../repositories/prescriptions_repository.dart';

/// UseCase pour uploader une ordonnance
class UploadPrescriptionUseCase {
  final PrescriptionsRepository repository;

  UploadPrescriptionUseCase(this.repository);

  Future<Either<Failure, PrescriptionEntity>> call({
    required List<XFile> images,
    String? notes,
  }) async {
    // Validation
    if (images.isEmpty) {
      return Left(
        ValidationFailure(
          message: 'Au moins une image est requise',
          errors: {'images': ['Au moins une image est requise']},
        ),
      );
    }

    // Vérifier taille des images (max 5MB chacune)
    for (final image in images) {
      final bytes = await image.length();
      if (bytes > 5 * 1024 * 1024) {
        return Left(
          ValidationFailure(
            message: 'Une image dépasse la taille maximale de 5MB',
            errors: {'images': ['Taille maximale: 5MB par image']},
          ),
        );
      }
    }

    return await repository.uploadPrescription(
      images: images,
      notes: notes,
    );
  }
}
