import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/pharmacy_entity.dart';
import '../repositories/pharmacies_repository.dart';

class GetFeaturedPharmaciesUseCase {
  final PharmaciesRepository repository;

  GetFeaturedPharmaciesUseCase(this.repository);

  Future<Either<Failure, List<PharmacyEntity>>> call() async {
    return await repository.getFeaturedPharmacies();
  }
}
