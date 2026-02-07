import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/pharmacy_entity.dart';
import '../../domain/repositories/pharmacies_repository.dart';
import '../datasources/pharmacies_remote_datasource.dart';

class PharmaciesRepositoryImpl implements PharmaciesRepository {
  final PharmaciesRemoteDataSource remoteDataSource;

  PharmaciesRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<PharmacyEntity>>> getPharmacies({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final pharmacies = await remoteDataSource.getPharmacies(
        page: page,
        perPage: perPage,
      );
      return Right(pharmacies.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PharmacyEntity>>> getNearbyPharmacies({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  }) async {
    try {
      final pharmacies = await remoteDataSource.getNearbyPharmacies(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      return Right(pharmacies.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PharmacyEntity>>> getOnDutyPharmacies({
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      final pharmacies = await remoteDataSource.getOnDutyPharmacies(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      return Right(pharmacies.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PharmacyEntity>> getPharmacyDetails(int id) async {
    try {
      final pharmacy = await remoteDataSource.getPharmacyDetails(id);
      return Right(pharmacy.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PharmacyEntity>>> getFeaturedPharmacies() async {
    try {
      final pharmacies = await remoteDataSource.getFeaturedPharmacies();
      return Right(pharmacies.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
