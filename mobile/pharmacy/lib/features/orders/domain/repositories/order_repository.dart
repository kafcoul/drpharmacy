import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getOrders({String? status});
  Future<Either<Failure, OrderEntity>> getOrderDetails(int id);
  Future<Either<Failure, void>> confirmOrder(int id);
  Future<Either<Failure, void>> markOrderReady(int id);
  Future<Either<Failure, void>> markOrderDelivered(int id);
  Future<Either<Failure, void>> rejectOrder(int id, {String? reason});
  Future<Either<Failure, void>> addNotes(int id, String notes);
}
