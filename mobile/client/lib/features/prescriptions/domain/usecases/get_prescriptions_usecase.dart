import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/prescription_entity.dart';
import '../repositories/prescriptions_repository.dart';

/// UseCase pour récupérer la liste des ordonnances
class GetPrescriptionsUseCase {
  final PrescriptionsRepository repository;

  GetPrescriptionsUseCase(this.repository);

  Future<Either<Failure, List<PrescriptionEntity>>> call() async {
    return await repository.getPrescriptions();
  }
}
