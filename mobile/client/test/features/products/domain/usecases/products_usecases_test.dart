import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/products/domain/usecases/get_products_usecase.dart';
import 'package:drpharma_client/features/products/domain/usecases/get_product_details_usecase.dart';
import 'package:drpharma_client/features/products/domain/usecases/search_products_usecase.dart';
import 'package:drpharma_client/features/products/domain/usecases/get_products_by_category_usecase.dart';
import 'package:drpharma_client/features/products/domain/repositories/products_repository.dart';
import 'package:drpharma_client/features/products/domain/entities/product_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/pharmacy_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/category_entity.dart';

@GenerateMocks([ProductsRepository])
import 'products_usecases_test.mocks.dart';

void main() {
  late MockProductsRepository mockRepository;

  setUp(() {
    mockRepository = MockProductsRepository();
  });

  // === Test data ===
  const testPharmacy = PharmacyEntity(
    id: 1,
    name: 'Pharmacie Centrale',
    address: 'Cocody, Abidjan',
    phone: '+2250700000000',
    status: 'active',
    isOpen: true,
  );

  const testCategory = CategoryEntity(
    id: 1,
    name: 'Médicaments',
    description: 'Médicaments génériques et spécialisés',
  );

  final testProducts = [
    ProductEntity(
      id: 1,
      name: 'Paracétamol 500mg',
      description: 'Antidouleur et antipyrétique',
      price: 1500.0,
      stockQuantity: 50,
      requiresPrescription: false,
      pharmacy: testPharmacy,
      category: testCategory,
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
    ),
    ProductEntity(
      id: 2,
      name: 'Amoxicilline 1g',
      description: 'Antibiotique',
      price: 5000.0,
      stockQuantity: 20,
      requiresPrescription: true,
      pharmacy: testPharmacy,
      category: testCategory,
      createdAt: DateTime(2024, 1, 14),
      updatedAt: DateTime(2024, 1, 14),
    ),
    ProductEntity(
      id: 3,
      name: 'Vitamine C 1000mg',
      description: null,
      price: 2500.0,
      stockQuantity: 0, // Out of stock
      requiresPrescription: false,
      pharmacy: testPharmacy,
      createdAt: DateTime(2024, 1, 13),
      updatedAt: DateTime(2024, 1, 13),
    ),
  ];

  group('GetProductsUseCase', () {
    late GetProductsUseCase useCase;

    setUp(() {
      useCase = GetProductsUseCase(mockRepository);
    });

    test('should get products successfully with default pagination', () async {
      // Arrange
      when(mockRepository.getProducts(page: 1, perPage: 20))
          .thenAnswer((_) async => Right(testProducts));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (products) {
          expect(products.length, 3);
          expect(products[0].name, 'Paracétamol 500mg');
          expect(products[1].requiresPrescription, isTrue);
        },
      );
      verify(mockRepository.getProducts(page: 1, perPage: 20)).called(1);
    });

    test('should get products with custom pagination', () async {
      // Arrange
      when(mockRepository.getProducts(page: 2, perPage: 10))
          .thenAnswer((_) async => Right(testProducts));

      // Act
      final result = await useCase.call(page: 2, perPage: 10);

      // Assert
      expect(result.isRight(), isTrue);
      verify(mockRepository.getProducts(page: 2, perPage: 10)).called(1);
    });

    test('should return validation failure for invalid page (0)', () async {
      // Act
      final result = await useCase.call(page: 0);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).errors['page'], isNotEmpty);
        },
        (_) => fail('Should be Left'),
      );
    });

    test('should return validation failure for negative page', () async {
      // Act
      final result = await useCase.call(page: -1);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    test('should return validation failure for perPage < 1', () async {
      // Act
      final result = await useCase.call(perPage: 0);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).errors['perPage'], isNotEmpty);
        },
        (_) => fail('Should be Left'),
      );
    });

    test('should return validation failure for perPage > 100', () async {
      // Act
      final result = await useCase.call(perPage: 101);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    test('should return empty list when no products', () async {
      // Arrange
      when(mockRepository.getProducts(page: 1, perPage: 20))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (products) => expect(products, isEmpty),
      );
    });

    test('should return failure when server error', () async {
      // Arrange
      when(mockRepository.getProducts(page: 1, perPage: 20))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('GetProductDetailsUseCase', () {
    late GetProductDetailsUseCase useCase;

    setUp(() {
      useCase = GetProductDetailsUseCase(mockRepository);
    });

    test('should get product details successfully', () async {
      // Arrange
      when(mockRepository.getProductDetails(1))
          .thenAnswer((_) async => Right(testProducts[0]));

      // Act
      final result = await useCase.call(1);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (product) {
          expect(product.id, 1);
          expect(product.name, 'Paracétamol 500mg');
          expect(product.price, 1500.0);
          expect(product.pharmacy.name, 'Pharmacie Centrale');
        },
      );
      verify(mockRepository.getProductDetails(1)).called(1);
    });

    test('should return validation failure for invalid id (0)', () async {
      // Act
      final result = await useCase.call(0);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).errors['productId'], isNotEmpty);
        },
        (_) => fail('Should be Left'),
      );
    });

    test('should return validation failure for negative id', () async {
      // Act
      final result = await useCase.call(-5);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    test('should return failure when product not found', () async {
      // Arrange
      when(mockRepository.getProductDetails(999))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Not found')));

      // Act
      final result = await useCase.call(999);

      // Assert
      expect(result.isLeft(), isTrue);
      verify(mockRepository.getProductDetails(999)).called(1);
    });
  });

  group('SearchProductsUseCase', () {
    late SearchProductsUseCase useCase;

    setUp(() {
      useCase = SearchProductsUseCase(mockRepository);
    });

    test('should search products successfully', () async {
      // Arrange
      when(mockRepository.searchProducts(query: 'paracétamol', page: 1, perPage: 20))
          .thenAnswer((_) async => Right([testProducts[0]]));

      // Act
      final result = await useCase.call(query: 'paracétamol');

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (products) {
          expect(products.length, 1);
          expect(products[0].name, contains('Paracétamol'));
        },
      );
      verify(mockRepository.searchProducts(query: 'paracétamol', page: 1, perPage: 20)).called(1);
    });

    test('should trim search query', () async {
      // Arrange
      when(mockRepository.searchProducts(query: 'test', page: 1, perPage: 20))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase.call(query: '  test  ');

      // Assert
      expect(result.isRight(), isTrue);
      verify(mockRepository.searchProducts(query: 'test', page: 1, perPage: 20)).called(1);
    });

    test('should return validation failure for empty query', () async {
      // Act
      final result = await useCase.call(query: '');

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).errors['query'], isNotEmpty);
        },
        (_) => fail('Should be Left'),
      );
    });

    test('should return validation failure for whitespace-only query', () async {
      // Act
      final result = await useCase.call(query: '   ');

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    test('should return validation failure for query too short', () async {
      // Act
      final result = await useCase.call(query: 'a');

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).message, contains('2 characters'));
        },
        (_) => fail('Should be Left'),
      );
    });

    test('should return empty list when no results', () async {
      // Arrange
      when(mockRepository.searchProducts(query: 'nonexistent', page: 1, perPage: 20))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase.call(query: 'nonexistent');

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (products) => expect(products, isEmpty),
      );
    });
  });

  group('GetProductsByCategoryUseCase', () {
    late GetProductsByCategoryUseCase useCase;

    setUp(() {
      useCase = GetProductsByCategoryUseCase(mockRepository);
    });

    test('should get products by category successfully', () async {
      // Arrange
      when(mockRepository.getProductsByCategory(category: 'medicaments', page: 1, perPage: 20))
          .thenAnswer((_) async => Right(testProducts));

      // Act
      final result = await useCase.call(category: 'medicaments');

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (products) => expect(products.length, 3),
      );
      verify(mockRepository.getProductsByCategory(category: 'medicaments', page: 1, perPage: 20)).called(1);
    });

    test('should get all products when category is null', () async {
      // Arrange
      when(mockRepository.getProducts(page: 1, perPage: 20))
          .thenAnswer((_) async => Right(testProducts));

      // Act
      final result = await useCase.call(category: null);

      // Assert
      expect(result.isRight(), isTrue);
      verify(mockRepository.getProducts(page: 1, perPage: 20)).called(1);
      verifyNever(mockRepository.getProductsByCategory(category: anyNamed('category'), page: anyNamed('page'), perPage: anyNamed('perPage')));
    });

    test('should return failure when server error', () async {
      // Arrange
      when(mockRepository.getProductsByCategory(category: 'invalid', page: 1, perPage: 20))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      // Act
      final result = await useCase.call(category: 'invalid');

      // Assert
      expect(result.isLeft(), isTrue);
    });
  });

  group('ProductEntity', () {
    test('should create entity with required fields', () {
      // Arrange & Act
      final product = ProductEntity(
        id: 1,
        name: 'Test Product',
        price: 1000.0,
        stockQuantity: 10,
        requiresPrescription: false,
        pharmacy: testPharmacy,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      // Assert
      expect(product.id, 1);
      expect(product.name, 'Test Product');
      expect(product.description, isNull);
      expect(product.category, isNull);
    });

    test('isAvailable should return true when stock > 0', () {
      final product = ProductEntity(
        id: 1,
        name: 'Test',
        price: 1000,
        stockQuantity: 50,
        requiresPrescription: false,
        pharmacy: testPharmacy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(product.isAvailable, isTrue);
      expect(product.isOutOfStock, isFalse);
    });

    test('isOutOfStock should return true when stock == 0', () {
      final product = ProductEntity(
        id: 1,
        name: 'Test',
        price: 1000,
        stockQuantity: 0,
        requiresPrescription: false,
        pharmacy: testPharmacy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(product.isAvailable, isFalse);
      expect(product.isOutOfStock, isTrue);
    });

    test('isLowStock should return true when 0 < stock <= 10', () {
      final lowStock = ProductEntity(
        id: 1,
        name: 'Test',
        price: 1000,
        stockQuantity: 5,
        requiresPrescription: false,
        pharmacy: testPharmacy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final normalStock = ProductEntity(
        id: 2,
        name: 'Test',
        price: 1000,
        stockQuantity: 50,
        requiresPrescription: false,
        pharmacy: testPharmacy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(lowStock.isLowStock, isTrue);
      expect(normalStock.isLowStock, isFalse);
    });

    test('should support equality', () {
      final p1 = ProductEntity(
        id: 1,
        name: 'Test',
        price: 1000,
        stockQuantity: 10,
        requiresPrescription: false,
        pharmacy: testPharmacy,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      final p2 = ProductEntity(
        id: 1,
        name: 'Test',
        price: 1000,
        stockQuantity: 10,
        requiresPrescription: false,
        pharmacy: testPharmacy,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      final p3 = ProductEntity(
        id: 2,
        name: 'Different',
        price: 2000,
        stockQuantity: 10,
        requiresPrescription: false,
        pharmacy: testPharmacy,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      expect(p1, equals(p2));
      expect(p1, isNot(equals(p3)));
    });
  });

  group('PharmacyEntity', () {
    test('should create entity with required fields', () {
      const pharmacy = PharmacyEntity(
        id: 1,
        name: 'Test Pharmacy',
        address: 'Test Address',
        phone: '+2250700000000',
        status: 'active',
        isOpen: true,
      );

      expect(pharmacy.id, 1);
      expect(pharmacy.name, 'Test Pharmacy');
      expect(pharmacy.email, isNull);
      expect(pharmacy.latitude, isNull);
    });

    test('should support equality', () {
      const p1 = PharmacyEntity(
        id: 1,
        name: 'Test',
        address: 'Address',
        phone: '+2250700000000',
        status: 'active',
        isOpen: true,
      );

      const p2 = PharmacyEntity(
        id: 1,
        name: 'Test',
        address: 'Address',
        phone: '+2250700000000',
        status: 'active',
        isOpen: true,
      );

      expect(p1, equals(p2));
    });
  });
}
