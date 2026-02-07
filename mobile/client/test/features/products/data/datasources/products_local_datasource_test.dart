import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:drpharma_client/features/products/data/datasources/products_local_datasource.dart';
import 'package:drpharma_client/features/products/data/models/product_model.dart';
import 'package:drpharma_client/features/products/data/models/pharmacy_model.dart';
import 'package:drpharma_client/features/products/data/models/category_model.dart';

@GenerateMocks([SharedPreferences])
import 'products_local_datasource_test.mocks.dart';

void main() {
  late MockSharedPreferences mockSharedPreferences;
  late ProductsLocalDataSourceImpl dataSource;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = ProductsLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  // Helper to create a test product
  ProductModel createTestProduct({
    int id = 1,
    String name = 'Test Product',
    double price = 1000.0,
  }) {
    return ProductModel(
      id: id,
      name: name,
      description: 'Description',
      price: price,
      imageUrl: null,
      image: null,
      stockQuantity: 10,
      manufacturer: 'Manufacturer',
      requiresPrescription: false,
      category: CategoryModel(id: 1, name: 'Category', description: null),
      pharmacy: PharmacyModel(
        id: 1,
        name: 'Pharmacy',
        address: 'Address',
        phone: '123456',
        email: null,
        latitude: null,
        longitude: null,
        status: 'active',
        isOpen: true,
      ),
      createdAt: '2024-01-01T00:00:00Z',
      updatedAt: '2024-01-01T00:00:00Z',
    );
  }

  group('ProductsLocalDataSourceImpl', () {
    group('cacheProducts', () {
      test('should save products to SharedPreferences', () async {
        // Arrange
        final products = [
          createTestProduct(id: 1, name: 'Product 1'),
          createTestProduct(id: 2, name: 'Product 2'),
        ];
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.cacheProducts(products);

        // Assert
        verify(mockSharedPreferences.setString(
          'cached_products',
          argThat(isA<String>()),
        )).called(1);
      });
    });

    group('getCachedProducts', () {
      test('should return cached products', () async {
        // Arrange
        final products = [
          createTestProduct(id: 1, name: 'Product 1'),
        ];
        final productsJson = jsonEncode(
          products.map((p) => p.toJson()).toList(),
        );
        when(mockSharedPreferences.getString('cached_products'))
            .thenReturn(productsJson);

        // Act
        final result = await dataSource.getCachedProducts();

        // Assert
        expect(result, isNotNull);
        expect(result!.length, 1);
        expect(result[0].name, 'Product 1');
      });

      test('should return null when no cached products', () async {
        // Arrange
        when(mockSharedPreferences.getString('cached_products'))
            .thenReturn(null);

        // Act
        final result = await dataSource.getCachedProducts();

        // Assert
        expect(result, isNull);
      });
    });

    group('cacheProductDetails', () {
      test('should save product details to SharedPreferences', () async {
        // Arrange
        final product = createTestProduct(id: 42);
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.cacheProductDetails(product);

        // Assert
        verify(mockSharedPreferences.setString(
          'cached_product_42',
          argThat(isA<String>()),
        )).called(1);
      });
    });

    group('getCachedProductDetails', () {
      test('should return cached product details', () async {
        // Arrange
        final product = createTestProduct(id: 42, name: 'Cached Product');
        final productJson = jsonEncode(product.toJson());
        when(mockSharedPreferences.getString('cached_product_42'))
            .thenReturn(productJson);

        // Act
        final result = await dataSource.getCachedProductDetails(42);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, 42);
        expect(result.name, 'Cached Product');
      });

      test('should return null when no cached product details', () async {
        // Arrange
        when(mockSharedPreferences.getString('cached_product_99'))
            .thenReturn(null);

        // Act
        final result = await dataSource.getCachedProductDetails(99);

        // Assert
        expect(result, isNull);
      });
    });

    group('clearCache', () {
      test('should clear all product-related keys', () async {
        // Arrange
        when(mockSharedPreferences.getKeys()).thenReturn({
          'cached_products',
          'cached_product_1',
          'cached_product_2',
          'other_key',
        });
        when(mockSharedPreferences.remove(any)).thenAnswer((_) async => true);

        // Act
        await dataSource.clearCache();

        // Assert
        verify(mockSharedPreferences.remove('cached_products')).called(1);
        verify(mockSharedPreferences.remove('cached_product_1')).called(1);
        verify(mockSharedPreferences.remove('cached_product_2')).called(1);
        verifyNever(mockSharedPreferences.remove('other_key'));
      });

      test('should not fail when no keys exist', () async {
        // Arrange
        when(mockSharedPreferences.getKeys()).thenReturn({});

        // Act
        await dataSource.clearCache();

        // Assert
        verifyNever(mockSharedPreferences.remove(any));
      });
    });
  });
}
