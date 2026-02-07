import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/app_logger.dart';
import '../../domain/entities/prescription_entity.dart';
import '../../domain/repositories/prescriptions_repository.dart';
import '../datasources/prescriptions_remote_datasource.dart';
import '../models/prescription_model.dart';

class PrescriptionsRepositoryImpl implements PrescriptionsRepository {
  final PrescriptionsRemoteDataSource remoteDataSource;

  PrescriptionsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, PrescriptionEntity>> uploadPrescription({
    required List<XFile> images,
    String? notes,
  }) async {
    try {
      final response = await remoteDataSource.uploadPrescription(
        images: images,
        notes: notes,
      );
      
      final model = PrescriptionModel.fromJson(response);
      return Right(model.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(
        message: e.errors.values.expand((v) => v).join('\n'),
        errors: e.errors,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('[PrescriptionsRepository] Upload error', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: 'Erreur lors de l\'envoi: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PrescriptionEntity>>> getPrescriptions() async {
    try {
      final data = await remoteDataSource.getPrescriptions();
      
      final prescriptions = data
          .map((json) => PrescriptionModel.fromJson(json).toEntity())
          .toList();
      
      return Right(prescriptions);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('[PrescriptionsRepository] GetPrescriptions error', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: 'Erreur lors du chargement des ordonnances'));
    }
  }

  @override
  Future<Either<Failure, PrescriptionEntity>> getPrescriptionDetails(int id) async {
    try {
      final data = await remoteDataSource.getPrescriptionDetails(id);
      
      final model = PrescriptionModel.fromJson(data);
      return Right(model.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('[PrescriptionsRepository] GetDetails error', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: 'Erreur lors du chargement des détails'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> payPrescription({
    required int prescriptionId,
    required String paymentMethod,
  }) async {
    try {
      final response = await remoteDataSource.payPrescription(
        prescriptionId,
        paymentMethod,
      );
      return Right(response);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(
        message: e.errors.values.expand((v) => v).join('\n'),
        errors: e.errors,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('[PrescriptionsRepository] Pay error', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(message: 'Erreur lors du paiement'));
    }
  }
}
