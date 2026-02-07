import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetOrdersUseCase {
  final OrdersRepository repository;

  GetOrdersUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    // Validation
    if (page < 1) {
      return Left(
        ValidationFailure(
          message: 'Page must be >= 1',
          errors: {
            'page': ['Page must be >= 1'],
          },
        ),
      );
    }

    if (perPage < 1 || perPage > 100) {
      return Left(
        ValidationFailure(
          message: 'Items per page must be between 1 and 100',
          errors: {
            'perPage': ['Items per page must be between 1 and 100'],
          },
        ),
      );
    }

    if (status != null && status.trim().isEmpty) {
      return Left(
        ValidationFailure(
          message: 'Status cannot be empty',
          errors: {
            'status': ['Status cannot be empty'],
          },
        ),
      );
    }

    return await repository.getOrders(
      status: status,
      page: page,
      perPage: perPage,
    );
  }
}
