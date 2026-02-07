import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/pharmacy_entity.dart';
import '../repositories/pharmacies_repository.dart';

class GetPharmaciesUseCase {
  final PharmaciesRepository repository;

  GetPharmaciesUseCase(this.repository);

  Future<Either<Failure, List<PharmacyEntity>>> call({
    int page = 1,
    int perPage = 20,
  }) async {
    return await repository.getPharmacies(
      page: page,
      perPage: perPage,
    );
  }
}
