import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/orders_repository.dart';

class CancelOrderUseCase {
  final OrdersRepository repository;

  CancelOrderUseCase(this.repository);

  Future<Either<Failure, void>> call(int orderId, String reason) async {
    // Validation
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

    if (reason.trim().isEmpty) {
      return Left(
        ValidationFailure(
          message: 'Cancellation reason is required',
          errors: {
            'reason': ['Cancellation reason is required'],
          },
        ),
      );
    }

    if (reason.trim().length < 3) {
      return Left(
        ValidationFailure(
          message: 'Reason must be at least 3 characters',
          errors: {
            'reason': ['Reason must be at least 3 characters'],
          },
        ),
      );
    }

    return await repository.cancelOrder(orderId, reason);
  }
}
