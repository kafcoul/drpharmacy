import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_local_datasource.dart';
import '../datasources/products_remote_datasource.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;
  final ProductsLocalDataSource localDataSource;

  ProductsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final products = await remoteDataSource.getProducts(
        page: page,
        perPage: perPage,
      );

      // Cache first page only
      if (page == 1) {
        await localDataSource.cacheProducts(products);
      }

      return Right(products.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      // Return cached products if available during network error
      if (page == 1) {
        final cachedProducts = await localDataSource.getCachedProducts();
        if (cachedProducts != null) {
          return Right(
            cachedProducts.map((model) => model.toEntity()).toList(),
          );
        }
      }
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts({
    required String query,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final products = await remoteDataSource.searchProducts(
        query: query,
        page: page,
        perPage: perPage,
      );

      return Right(products.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductDetails(int id) async {
    try {
      final product = await remoteDataSource.getProductDetails(id);

      // Cache product details
      await localDataSource.cacheProductDetails(product);

      return Right(product.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      // Return cached product if available during network error
      final cachedProduct = await localDataSource.getCachedProductDetails(id);
      if (cachedProduct != null) {
        return Right(cachedProduct.toEntity());
      }
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByPharmacy({
    required int pharmacyId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final products = await remoteDataSource.getProductsByPharmacy(
        pharmacyId: pharmacyId,
        page: page,
        perPage: perPage,
      );

      return Right(products.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory({
    required String category,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final products = await remoteDataSource.getProductsByCategory(
        category: category,
        page: page,
        perPage: perPage,
      );

      return Right(products.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
