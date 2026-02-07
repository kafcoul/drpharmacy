import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetOrderDetailsUseCase {
  final OrdersRepository repository;

  GetOrderDetailsUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(int orderId) async {
    if (orderId <= 0) {
      return Left(
        ValidationFailure(
          message: 'Invalid order ID',
          errors: {
            'orderId': ['Invalid order ID'],
          },
        ),
      );
    }

    return await repository.getOrderDetails(orderId);
  }
}
