import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failure.dart';
import '../datasources/prescription_remote_datasource.dart';
import '../models/prescription_model.dart';
import '../../../../core/errors/exceptions.dart';

class PrescriptionRepository {
  final PrescriptionRemoteDataSource _dataSource;

  PrescriptionRepository(this._dataSource);

  Future<Either<Failure, List<PrescriptionModel>>> getPrescriptions() async {
    try {
      final result = await _dataSource.getPrescriptions();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, PrescriptionModel>> getPrescription(int id) async {
    try {
      final result = await _dataSource.getPrescription(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, PrescriptionModel>> updateStatus(
    int id,
    String status, {
    String? notes,
    double? quoteAmount,
  }) async {
    try {
      final result = await _dataSource.updateStatus(id, status, notes: notes, quoteAmount: quoteAmount);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

final prescriptionRepositoryProvider = Provider<PrescriptionRepository>((ref) {
  final dataSource = ref.watch(prescriptionRemoteDataSourceProvider);
  return PrescriptionRepository(dataSource);
});
