import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/pharmacy_entity.dart';
import '../repositories/pharmacies_repository.dart';

class GetPharmacyDetailsUseCase {
  final PharmaciesRepository repository;

  GetPharmacyDetailsUseCase(this.repository);

  Future<Either<Failure, PharmacyEntity>> call(int id) async {
    return await repository.getPharmacyDetails(id);
  }
}
