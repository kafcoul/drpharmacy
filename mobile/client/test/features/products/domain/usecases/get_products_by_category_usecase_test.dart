import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/products/domain/entities/product_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/pharmacy_entity.dart';
import 'package:drpharma_client/features/products/domain/repositories/products_repository.dart';
import 'package:drpharma_client/features/products/domain/usecases/get_products_by_category_usecase.dart';

@GenerateMocks([ProductsRepository])
import 'get_products_by_category_usecase_test.mocks.dart';

void main() {
  late GetProductsByCategoryUseCase useCase;
  late MockProductsRepository mockRepository;

  setUp(() {
    mockRepository = MockProductsRepository();
    useCase = GetProductsByCategoryUseCase(mockRepository);
  });

  PharmacyEntity createTestPharmacy() {
    return const PharmacyEntity(
      id: 1,
      name: 'Test Pharmacy',
      address: '123 Test St',
      phone: '1234567890',
      latitude: 0.0,
      longitude: 0.0,
      status: 'active',
      isOpen: true,
    );
  }

  ProductEntity createTestProduct({
    int id = 1,
    String name = 'Test Product',
    double price = 10.0,
  }) {
    return ProductEntity(
      id: id,
      name: name,
      price: price,
      stockQuantity: 10,
      requiresPrescription: false,
      pharmacy: createTestPharmacy(),
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
  }

  group('GetProductsByCategoryUseCase', () {
    group('null category (get all products)', () {
      test('should call getProducts when category is null', () async {
        when(mockRepository.getProducts(page: 1, perPage: 20))
            .thenAnswer((_) async => const Right([]));

        await useCase(category: null);

        verify(mockRepository.getProducts(page: 1, perPage: 20)).called(1);
        verifyNever(mockRepository.getProductsByCategory(
          category: anyNamed('category'),
          page: anyNamed('page'),
          perPage: anyNamed('perPage'),
        ));
      });

      test('should return all products when category is null', () async {
        final products = [
          createTestProduct(id: 1, name: 'Product A'),
          createTestProduct(id: 2, name: 'Product B'),
          createTestProduct(id: 3, name: 'Product C'),
        ];
        when(mockRepository.getProducts(page: 1, perPage: 20))
            .thenAnswer((_) async => Right(products));

        final result = await useCase(category: null);

        expect(result, isA<Right>());
        result.fold(
          (_) => fail('Should return success'),
          (data) {
            expect(data.length, 3);
          },
        );
      });

      test('should pass custom pagination to getProducts', () async {
        when(mockRepository.getProducts(page: 2, perPage: 50))
            .thenAnswer((_) async => const Right([]));

        await useCase(category: null, page: 2, perPage: 50);

        verify(mockRepository.getProducts(page: 2, perPage: 50)).called(1);
      });
    });

    group('with category filter', () {
      test('should call getProductsByCategory when category is provided', () async {
        when(mockRepository.getProductsByCategory(
          category: 'medicines',
          page: 1,
          perPage: 20,
        )).thenAnswer((_) async => const Right([]));

        await useCase(category: 'medicines');

        verify(mockRepository.getProductsByCategory(
          category: 'medicines',
          page: 1,
          perPage: 20,
        )).called(1);
        verifyNever(mockRepository.getProducts(
          page: anyNamed('page'),
          perPage: anyNamed('perPage'),
        ));
      });

      test('should return filtered products', () async {
        final products = [
          createTestProduct(id: 1, name: 'Aspirin'),
          createTestProduct(id: 2, name: 'Ibuprofen'),
        ];
        when(mockRepository.getProductsByCategory(
          category: 'painkillers',
          page: 1,
          perPage: 20,
        )).thenAnswer((_) async => Right(products));

        final result = await useCase(category: 'painkillers');

        expect(result, isA<Right>());
        result.fold(
          (_) => fail('Should return success'),
          (data) {
            expect(data.length, 2);
            expect(data[0].name, 'Aspirin');
            expect(data[1].name, 'Ibuprofen');
          },
        );
      });

      test('should return empty list for category with no products', () async {
        when(mockRepository.getProductsByCategory(
          category: 'empty-category',
          page: 1,
          perPage: 20,
        )).thenAnswer((_) async => const Right([]));

        final result = await useCase(category: 'empty-category');

        expect(result, isA<Right>());
        result.fold(
          (_) => fail('Should return success'),
          (data) => expect(data, isEmpty),
        );
      });

      test('should handle various category names', () async {
        final categories = [
          'vitamins',
          'antibiotics',
          'skincare',
          'baby-products',
          'medical_devices',
          'Category With Spaces',
        ];

        for (final category in categories) {
          when(mockRepository.getProductsByCategory(
            category: category,
            page: 1,
            perPage: 20,
          )).thenAnswer((_) async => const Right([]));

          await useCase(category: category);

          verify(mockRepository.getProductsByCategory(
            category: category,
            page: 1,
            perPage: 20,
          )).called(1);
        }
      });
    });

    group('pagination', () {
      test('should use default pagination values', () async {
        when(mockRepository.getProductsByCategory(
          category: 'test',
          page: 1,
          perPage: 20,
        )).thenAnswer((_) async => const Right([]));

        await useCase(category: 'test');

        verify(mockRepository.getProductsByCategory(
          category: 'test',
          page: 1,
          perPage: 20,
        )).called(1);
      });

      test('should pass custom page number', () async {
        when(mockRepository.getProductsByCategory(
          category: 'test',
          page: 5,
          perPage: 20,
        )).thenAnswer((_) async => const Right([]));

        await useCase(category: 'test', page: 5);

        verify(mockRepository.getProductsByCategory(
          category: 'test',
          page: 5,
          perPage: 20,
        )).called(1);
      });

      test('should pass custom perPage value', () async {
        when(mockRepository.getProductsByCategory(
          category: 'test',
          page: 1,
          perPage: 100,
        )).thenAnswer((_) async => const Right([]));

        await useCase(category: 'test', perPage: 100);

        verify(mockRepository.getProductsByCategory(
          category: 'test',
          page: 1,
          perPage: 100,
        )).called(1);
      });

      test('should pass both custom pagination values', () async {
        when(mockRepository.getProductsByCategory(
          category: 'test',
          page: 3,
          perPage: 25,
        )).thenAnswer((_) async => const Right([]));

        await useCase(category: 'test', page: 3, perPage: 25);

        verify(mockRepository.getProductsByCategory(
          category: 'test',
          page: 3,
          perPage: 25,
        )).called(1);
      });
    });

    group('error handling', () {
      test('should return ServerFailure from getProductsByCategory', () async {
        when(mockRepository.getProductsByCategory(
          category: 'test',
          page: 1,
          perPage: 20,
        )).thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

        final result = await useCase(category: 'test');

        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Server error');
          },
          (_) => fail('Should return failure'),
        );
      });

      test('should return ServerFailure from getProducts when category is null', () async {
        when(mockRepository.getProducts(page: 1, perPage: 20))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Server down')));

        final result = await useCase(category: null);

        expect(result, isA<Left>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Should return failure'),
        );
      });

      test('should return NetworkFailure', () async {
        when(mockRepository.getProductsByCategory(
          category: 'test',
          page: 1,
          perPage: 20,
        )).thenAnswer((_) async => const Left(NetworkFailure(message: 'No connection')));

        final result = await useCase(category: 'test');

        expect(result, isA<Left>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Should return failure'),
        );
      });

      test('should return CacheFailure', () async {
        when(mockRepository.getProductsByCategory(
          category: 'test',
          page: 1,
          perPage: 20,
        )).thenAnswer((_) async => const Left(CacheFailure(message: 'Cache miss')));

        final result = await useCase(category: 'test');

        expect(result, isA<Left>());
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Should return failure'),
        );
      });
    });
  });
}
