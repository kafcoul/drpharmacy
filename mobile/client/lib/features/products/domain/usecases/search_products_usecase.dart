import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/products_repository.dart';

class SearchProductsUseCase {
  final ProductsRepository repository;

  SearchProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> call({
    required String query,
    int page = 1,
    int perPage = 20,
  }) async {
    if (query.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Search query cannot be empty',
        errors: {'query': ['Search query cannot be empty']},
      ));
    }

    if (query.trim().length < 2) {
      return Left(ValidationFailure(
        message: 'Search query must be at least 2 characters',
        errors: {'query': ['Search query must be at least 2 characters']},
      ));
    }

    return await repository.searchProducts(
      query: query.trim(),
      page: page,
      perPage: perPage,
    );
  }
}
