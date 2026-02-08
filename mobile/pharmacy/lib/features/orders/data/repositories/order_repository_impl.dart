import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final NetworkInfo networkInfo;

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.authLocalDataSource,
    required this.networkInfo,
  });

  Future<String> _getToken() async {
    final token = await authLocalDataSource.getToken();
    if (token == null) throw UnauthorizedException();
    return token;
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders({String? status}) async {
    if (await networkInfo.isConnected) {
      try {
        await _getToken(); // Ensure auth
        // Note: The ApiClient interceptor handles token injection if set
        // But our RemoteDataSource doesn't natively access LocalDataSource to set it on ApiClient
        // For now ApiClient interceptor in main.dart or AuthProvider logic should handle caching
        // However, a robust way is to pass token or have ApiClient read from storage.
        // Assuming ApiClient has the token or we rely on Interceptor injecting it from memory.

        final models = await remoteDataSource.getOrders(status: status);
        return Right(models.map((e) => e.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }
    return const Left(NetworkFailure('No internet connection'));
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetails(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final model = await remoteDataSource.getOrderDetails(id);
        return Right(model.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }
    return const Left(NetworkFailure('No internet connection'));
  }

  @override
  Future<Either<Failure, void>> confirmOrder(int id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.confirmOrder(id);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }
    return const Left(NetworkFailure('No internet connection'));
  }

  @override
  Future<Either<Failure, void>> markOrderReady(int id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markOrderReady(id);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }
    return const Left(NetworkFailure('No internet connection'));
  }

  @override
  Future<Either<Failure, void>> markOrderDelivered(int id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markOrderDelivered(id);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }
    return const Left(NetworkFailure('No internet connection'));
  }

  @override
  Future<Either<Failure, void>> addNotes(int id, String notes) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addNotes(id, notes);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }
    return const Left(NetworkFailure('No internet connection'));
  }

  @override
  Future<Either<Failure, void>> rejectOrder(int id, {String? reason}) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.rejectOrder(id, reason: reason);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }
    return const Left(NetworkFailure('No internet connection'));
  }
}
