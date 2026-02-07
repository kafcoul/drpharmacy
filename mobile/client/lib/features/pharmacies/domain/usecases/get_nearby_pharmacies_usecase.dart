import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/pharmacy_entity.dart';
import '../repositories/pharmacies_repository.dart';

class GetNearbyPharmaciesUseCase {
  final PharmaciesRepository repository;

  GetNearbyPharmaciesUseCase(this.repository);

  Future<Either<Failure, List<PharmacyEntity>>> call({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  }) async {
    return await repository.getNearbyPharmacies(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
  }
}
