import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/products_repository.dart';

class GetProductsByCategoryUseCase {
  final ProductsRepository repository;

  GetProductsByCategoryUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> call({
    required String? category,
    int page = 1,
    int perPage = 20,
  }) async {
    // If category is null, get all products
    if (category == null) {
      return await repository.getProducts(page: page, perPage: perPage);
    }
    
    // Otherwise, filter by category
    return await repository.getProductsByCategory(
      category: category,
      page: page,
      perPage: perPage,
    );
  }
}
