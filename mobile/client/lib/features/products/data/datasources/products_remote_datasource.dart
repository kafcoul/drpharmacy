import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/product_model.dart';

abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts({int page = 1, int perPage = 20});

  Future<List<ProductModel>> searchProducts({
    required String query,
    int page = 1,
    int perPage = 20,
  });

  Future<ProductModel> getProductDetails(int id);

  Future<List<ProductModel>> getProductsByPharmacy({
    required int pharmacyId,
    int page = 1,
    int perPage = 20,
  });

  Future<List<ProductModel>> getProductsByCategory({
    required String category,
    int page = 1,
    int perPage = 20,
  });
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final ApiClient apiClient;

  ProductsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await apiClient.get(
      ApiConstants.products,
      queryParameters: {'page': page, 'per_page': perPage},
    );

    final List<dynamic> productsJson = response.data['data']['products'];
    return productsJson.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> searchProducts({
    required String query,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await apiClient.get(
      ApiConstants.searchProducts,
      queryParameters: {'search': query, 'page': page, 'per_page': perPage},
    );

    final List<dynamic> productsJson = response.data['data']['products'];
    return productsJson.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<ProductModel> getProductDetails(int id) async {
    final response = await apiClient.get(ApiConstants.productDetails(id));

    // L'API retourne { data: { product: {...} } }
    final productJson = response.data['data']['product'] ?? response.data['data'];
    return ProductModel.fromJson(productJson);
  }

  @override
  Future<List<ProductModel>> getProductsByPharmacy({
    required int pharmacyId,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await apiClient.get(
      ApiConstants.products,
      queryParameters: {
        'pharmacy_id': pharmacyId,
        'page': page,
        'per_page': perPage,
      },
    );

    final List<dynamic> productsJson = response.data['data']['products'];
    return productsJson.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> getProductsByCategory({
    required String category,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await apiClient.get(
      ApiConstants.products,
      queryParameters: {
        'category': category,
        'page': page,
        'per_page': perPage,
      },
    );

    final List<dynamic> productsJson = response.data['data']['products'];
    return productsJson.map((json) => ProductModel.fromJson(json)).toList();
  }
}
