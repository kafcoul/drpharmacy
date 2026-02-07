import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/prescription_entity.dart';
import '../repositories/prescriptions_repository.dart';

/// UseCase pour récupérer les détails d'une ordonnance
class GetPrescriptionDetailsUseCase {
  final PrescriptionsRepository repository;

  GetPrescriptionDetailsUseCase(this.repository);

  Future<Either<Failure, PrescriptionEntity>> call(int prescriptionId) async {
    if (prescriptionId <= 0) {
      return Left(
        ValidationFailure(
          message: 'ID ordonnance invalide',
          errors: {'id': ['ID ordonnance invalide']},
        ),
      );
    }

    return await repository.getPrescriptionDetails(prescriptionId);
  }
}
