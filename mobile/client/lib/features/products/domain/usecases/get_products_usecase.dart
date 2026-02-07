import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/products_repository.dart';

class GetProductsUseCase {
  final ProductsRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> call({
    int page = 1,
    int perPage = 20,
  }) async {
    if (page < 1) {
      return Left(ValidationFailure(
        message: 'Page number must be positive',
        errors: {'page': ['Page number must be positive']},
      ));
    }

    if (perPage < 1 || perPage > 100) {
      return Left(ValidationFailure(
        message: 'Per page must be between 1 and 100',
        errors: {'perPage': ['Per page must be between 1 and 100']},
      ));
    }

    return await repository.getProducts(page: page, perPage: perPage);
  }
}
