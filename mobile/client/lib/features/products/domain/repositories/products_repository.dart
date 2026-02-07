import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductsRepository {
  /// Get paginated list of products
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int page = 1,
    int perPage = 20,
  });

  /// Search products by name
  Future<Either<Failure, List<ProductEntity>>> searchProducts({
    required String query,
    int page = 1,
    int perPage = 20,
  });

  /// Get product details by ID
  Future<Either<Failure, ProductEntity>> getProductDetails(int id);

  /// Get products by pharmacy ID
  Future<Either<Failure, List<ProductEntity>>> getProductsByPharmacy({
    required int pharmacyId,
    int page = 1,
    int perPage = 20,
  });

  /// Get products by category
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory({
    required String category,
    int page = 1,
    int perPage = 20,
  });
}
