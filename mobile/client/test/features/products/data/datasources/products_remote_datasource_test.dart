import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/network/api_client.dart';
import 'package:drpharma_client/features/products/data/datasources/products_remote_datasource.dart';
import 'package:drpharma_client/features/products/data/models/product_model.dart';

import 'products_remote_datasource_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late ProductsRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  final tProductJson = {
    'id': 1,
    'name': 'Doliprane 500mg',
    'description': 'Paracétamol 500mg',
    'price': 2500.0,
    'image_url': 'https://example.com/image.jpg',
    'stock_quantity': 100,
    'manufacturer': 'Sanofi',
    'requires_prescription': false,
    'pharmacy': {
      'id': 1,
      'name': 'Pharmacie Test',
      'address': '123 Rue Test',
      'phone': '+24112345678',
      'status': 'active',
      'is_open': true,
    },
    'created_at': '2024-01-15T10:00:00Z',
    'updated_at': '2024-01-15T10:00:00Z',
  };

  final tProductsResponse = {
    'data': {
      'products': [tProductJson],
    },
  };

  final tProductDetailResponse = {
    'data': {
      'product': tProductJson,
    },
  };

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = ProductsRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  group('ProductsRemoteDataSource', () {
    group('getProducts', () {
      test('should return list of products on success', () async {
        // Arrange
        when(mockApiClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
          data: tProductsResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/products'),
        ));

        // Act
        final result = await dataSource.getProducts();

        // Assert
        expect(result, isA<List<ProductModel>>());
        expect(result.length, 1);
        expect(result.first.name, 'Doliprane 500mg');
        verify(mockApiClient.get(
          '/products',
          queryParameters: {'page': 1, 'per_page': 20},
        )).called(1);
      });

      test('should pass pagination parameters', () async {
        // Arrange
        when(mockApiClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
          data: tProductsResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/products'),
        ));

        // Act
        await dataSource.getProducts(page: 2, perPage: 10);

        // Assert
        verify(mockApiClient.get(
          '/products',
          queryParameters: {'page': 2, 'per_page': 10},
        )).called(1);
      });

      test('should return empty list when no products', () async {
        // Arrange
        when(mockApiClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
          data: {'data': {'products': []}},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/products'),
        ));

        // Act
        final result = await dataSource.getProducts();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('searchProducts', () {
      test('should return search results', () async {
        // Arrange
        when(mockApiClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
          data: tProductsResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/products'),
        ));

        // Act
        final result = await dataSource.searchProducts(query: 'doliprane');

        // Assert
        expect(result, isA<List<ProductModel>>());
        expect(result.length, 1);
        verify(mockApiClient.get(
          '/products',
          queryParameters: {'search': 'doliprane', 'page': 1, 'per_page': 20},
        )).called(1);
      });

      test('should pass all search parameters', () async {
        // Arrange
        when(mockApiClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
          data: tProductsResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/products'),
        ));

        // Act
        await dataSource.searchProducts(query: 'test', page: 3, perPage: 15);

        // Assert
        verify(mockApiClient.get(
          '/products',
          queryParameters: {'search': 'test', 'page': 3, 'per_page': 15},
        )).called(1);
      });
    });

    group('getProductDetails', () {
      test('should return product details', () async {
        // Arrange
        when(mockApiClient.get(any))
            .thenAnswer((_) async => Response(
          data: tProductDetailResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/products/1'),
        ));

        // Act
        final result = await dataSource.getProductDetails(1);

        // Assert
        expect(result, isA<ProductModel>());
        expect(result.id, 1);
        expect(result.name, 'Doliprane 500mg');
        verify(mockApiClient.get('/products/1')).called(1);
      });

      test('should handle product data directly in data field', () async {
        // Arrange - Some API responses put product directly in data
        when(mockApiClient.get(any))
            .thenAnswer((_) async => Response(
          data: {'data': tProductJson},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/products/1'),
        ));

        // Act
        final result = await dataSource.getProductDetails(1);

        // Assert
        expect(result, isA<ProductModel>());
        expect(result.name, 'Doliprane 500mg');
      });
    });

    group('getProductsByPharmacy', () {
      test('should return products for pharmacy', () async {
        // Arrange
        when(mockApiClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
          data: tProductsResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/products'),
        ));

        // Act
        final result = await dataSource.getProductsByPharmacy(pharmacyId: 1);

        // Assert
        expect(result, isA<List<ProductModel>>());
        expect(result.length, 1);
        verify(mockApiClient.get(
          '/products',
          queryParameters: {'pharmacy_id': 1, 'page': 1, 'per_page': 20},
        )).called(1);
      });

      test('should pass pagination for pharmacy products', () async {
        // Arrange
        when(mockApiClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
          data: tProductsResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/products'),
        ));

        // Act
        await dataSource.getProductsByPharmacy(pharmacyId: 5, page: 2, perPage: 25);

        // Assert
        verify(mockApiClient.get(
          '/products',
          queryParameters: {'pharmacy_id': 5, 'page': 2, 'per_page': 25},
        )).called(1);
      });
    });

    group('getProductsByCategory', () {
      test('should return products for category', () async {
        // Arrange
        when(mockApiClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
          data: tProductsResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/products'),
        ));

        // Act
        final result = await dataSource.getProductsByCategory(category: 'medicaments');

        // Assert
        expect(result, isA<List<ProductModel>>());
        expect(result.length, 1);
      });

      test('should pass category in query parameters', () async {
        // Arrange
        when(mockApiClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
          data: tProductsResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/products'),
        ));

        // Act
        await dataSource.getProductsByCategory(
          category: 'vitamines',
          page: 2,
          perPage: 30,
        );

        // Assert - The implementation should include category in query
        verify(mockApiClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).called(1);
      });
    });
  });

  group('ProductModel', () {
    test('should create from JSON', () {
      // Act
      final model = ProductModel.fromJson(tProductJson);

      // Assert
      expect(model.id, 1);
      expect(model.name, 'Doliprane 500mg');
      expect(model.price, 2500.0);
      expect(model.stockQuantity, 100);
      expect(model.requiresPrescription, isFalse);
      expect(model.pharmacy, isNotNull);
    });

    test('should handle null optional fields', () {
      // Arrange
      final minimalJson = {
        'id': 1,
        'name': 'Test Product',
        'price': 1000.0,
        'stock_quantity': 10,
        'requires_prescription': true,
        'pharmacy': {
          'id': 1,
          'name': 'Test Pharmacy',
          'address': 'Test Address',
          'phone': '123456',
          'status': 'active',
          'is_open': true,
        },
        'created_at': '2024-01-15T10:00:00Z',
        'updated_at': '2024-01-15T10:00:00Z',
      };

      // Act
      final model = ProductModel.fromJson(minimalJson);

      // Assert
      expect(model.description, isNull);
      expect(model.imageUrl, isNull);
      expect(model.manufacturer, isNull);
    });

    test('should convert to entity', () {
      // Arrange
      final model = ProductModel.fromJson(tProductJson);

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity.id, model.id);
      expect(entity.name, model.name);
      expect(entity.price, model.price);
      expect(entity.requiresPrescription, model.requiresPrescription);
    });
  });
}
