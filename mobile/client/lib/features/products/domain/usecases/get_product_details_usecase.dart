import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/products_repository.dart';

class GetProductDetailsUseCase {
  final ProductsRepository repository;

  GetProductDetailsUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> call(int productId) async {
    if (productId < 1) {
      return Left(ValidationFailure(
        message: 'Invalid product ID',
        errors: {'productId': ['Product ID must be positive']},
      ));
    }

    return await repository.getProductDetails(productId);
  }
}
