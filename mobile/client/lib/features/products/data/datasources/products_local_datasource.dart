import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product_model.dart';

abstract class ProductsLocalDataSource {
  Future<void> cacheProducts(List<ProductModel> products);
  Future<List<ProductModel>?> getCachedProducts();
  Future<void> cacheProductDetails(ProductModel product);
  Future<ProductModel?> getCachedProductDetails(int productId);
  Future<void> clearCache();
}

class ProductsLocalDataSourceImpl implements ProductsLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String productsKey = 'cached_products';
  static const String productDetailsPrefix = 'cached_product_';

  ProductsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final productsJson =
        products.map((product) => product.toJson()).toList();
    await sharedPreferences.setString(
      productsKey,
      jsonEncode(productsJson),
    );
  }

  @override
  Future<List<ProductModel>?> getCachedProducts() async {
    final productsString = sharedPreferences.getString(productsKey);
    if (productsString != null) {
      final List<dynamic> productsJson = jsonDecode(productsString);
      return productsJson.map((json) => ProductModel.fromJson(json)).toList();
    }
    return null;
  }

  @override
  Future<void> cacheProductDetails(ProductModel product) async {
    await sharedPreferences.setString(
      '$productDetailsPrefix${product.id}',
      jsonEncode(product.toJson()),
    );
  }

  @override
  Future<ProductModel?> getCachedProductDetails(int productId) async {
    final productString =
        sharedPreferences.getString('$productDetailsPrefix$productId');
    if (productString != null) {
      return ProductModel.fromJson(jsonDecode(productString));
    }
    return null;
  }

  @override
  Future<void> clearCache() async {
    final keys = sharedPreferences.getKeys();
    for (final key in keys) {
      if (key.startsWith(productDetailsPrefix) || key == productsKey) {
        await sharedPreferences.remove(key);
      }
    }
  }
}
