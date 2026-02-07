import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../auth/domain/entities/pharmacy_entity.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepository {
  final ProfileRemoteDataSource _dataSource;

  ProfileRepository(this._dataSource);

  Future<Either<Failure, PharmacyEntity>> updatePharmacy(
      int id, dynamic data) async {
    try {
      final model = await _dataSource.updatePharmacy(id, data);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updateProfile(Map<String, dynamic> data) async {
    try {
      await _dataSource.updateProfile(data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepository(dataSource);
});
