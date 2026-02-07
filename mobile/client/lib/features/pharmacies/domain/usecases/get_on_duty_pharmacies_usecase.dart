import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/pharmacy_entity.dart';
import '../repositories/pharmacies_repository.dart';

class GetOnDutyPharmaciesUseCase {
  final PharmaciesRepository repository;

  GetOnDutyPharmaciesUseCase(this.repository);

  Future<Either<Failure, List<PharmacyEntity>>> call({
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    return await repository.getOnDutyPharmacies(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
  }
}
