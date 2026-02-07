import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/products/domain/entities/product_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/pharmacy_entity.dart';
import 'package:drpharma_client/features/products/domain/repositories/products_repository.dart';
import 'package:drpharma_client/features/products/domain/usecases/search_products_usecase.dart';

@GenerateMocks([ProductsRepository])
import 'search_products_usecase_test.mocks.dart';

void main() {
  late SearchProductsUseCase useCase;
  late MockProductsRepository mockRepository;

  setUp(() {
    mockRepository = MockProductsRepository();
    useCase = SearchProductsUseCase(mockRepository);
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

  group('SearchProductsUseCase', () {
    group('validation', () {
      test('should return ValidationFailure when query is empty', () async {
        final result = await useCase(query: '');

        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).message, 'Search query cannot be empty');
            expect(failure.errors['query'], contains('Search query cannot be empty'));
          },
          (_) => fail('Should return failure'),
        );

        verifyNever(mockRepository.searchProducts(
          query: anyNamed('query'),
          page: anyNamed('page'),
          perPage: anyNamed('perPage'),
        ));
      });

      test('should return ValidationFailure when query is only whitespace', () async {
        final result = await useCase(query: '   ');

        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).message, 'Search query cannot be empty');
          },
          (_) => fail('Should return failure'),
        );
      });

      test('should return ValidationFailure when query is too short', () async {
        final result = await useCase(query: 'a');

        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).message, 'Search query must be at least 2 characters');
            expect(failure.errors['query'], contains('Search query must be at least 2 characters'));
          },
          (_) => fail('Should return failure'),
        );
      });

      test('should return ValidationFailure when trimmed query is too short', () async {
        final result = await useCase(query: ' a ');

        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
          },
          (_) => fail('Should return failure'),
        );
      });
    });

    group('successful search', () {
      test('should call repository with trimmed query', () async {
        final products = [createTestProduct()];
        when(mockRepository.searchProducts(
          query: 'test',
          page: 1,
          perPage: 20,
        )).thenAnswer((_) async => Right(products));

        await useCase(query: '  test  ');

        verify(mockRepository.searchProducts(
          query: 'test',
          page: 1,
          perPage: 20,
        )).called(1);
      });

      test('should return products on successful search', () async {
        final products = [
          createTestProduct(id: 1, name: 'Aspirin'),
          createTestProduct(id: 2, name: 'Paracetamol'),
        ];
        when(mockRepository.searchProducts(
          query: 'pain',
          page: 1,
          perPage: 20,
        )).thenAnswer((_) async => Right(products));

        final result = await useCase(query: 'pain');

        expect(result, isA<Right>());
        result.fold(
          (_) => fail('Should return success'),
          (data) {
            expect(data.length, 2);
            expect(data[0].name, 'Aspirin');
            expect(data[1].name, 'Paracetamol');
          },
        );
      });

      test('should return empty list when no products found', () async {
        when(mockRepository.searchProducts(
          query: 'nonexistent',
          page: 1,
          perPage: 20,
        )).thenAnswer((_) async => const Right([]));

        final result = await useCase(query: 'nonexistent');

        expect(result, isA<Right>());
        result.fold(
          (_) => fail('Should return success'),
          (data) => expect(data, isEmpty),
        );
      });

      test('should accept minimum valid query length', () async {
        final products = [createTestProduct()];
        when(mockRepository.searchProducts(
          query: 'ab',
          page: 1,
          perPage: 20,
        )).thenAnswer((_) async => Right(products));

        final result = await useCase(query: 'ab');

        expect(result, isA<Right>());
      });
    });

    group('pagination', () {
      test('should use default pagination values', () async {
        when(mockRepository.searchProducts(
          query: 'test',
          page: 1,
          perPage: 20,
        )).thenAnswer((_) async => const Right([]));

        await useCase(query: 'test');

        verify(mockRepository.searchProducts(
          query: 'test',
          page: 1,
          perPage: 20,
        )).called(1);
      });

      test('should pass custom page number', () async {
        when(mockRepository.searchProducts(
          query: 'test',
          page: 3,
          perPage: 20,
        )).thenAnswer((_) async => const Right([]));

        await useCase(query: 'test', page: 3);

        verify(mockRepository.searchProducts(
          query: 'test',
          page: 3,
          perPage: 20,
        )).called(1);
      });

      test('should pass custom perPage value', () async {
        when(mockRepository.searchProducts(
          query: 'test',
          page: 1,
          perPage: 50,
        )).thenAnswer((_) async => const Right([]));

        await useCase(query: 'test', perPage: 50);

        verify(mockRepository.searchProducts(
          query: 'test',
          page: 1,
          perPage: 50,
        )).called(1);
      });

      test('should pass both custom page and perPage', () async {
        when(mockRepository.searchProducts(
          query: 'test',
          page: 5,
          perPage: 10,
        )).thenAnswer((_) async => const Right([]));

        await useCase(query: 'test', page: 5, perPage: 10);

        verify(mockRepository.searchProducts(
          query: 'test',
          page: 5,
          perPage: 10,
        )).called(1);
      });
    });

    group('error handling', () {
      test('should return ServerFailure from repository', () async {
        when(mockRepository.searchProducts(
          query: 'test',
          page: 1,
          perPage: 20,
        )).thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

        final result = await useCase(query: 'test');

        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Server error');
          },
          (_) => fail('Should return failure'),
        );
      });

      test('should return NetworkFailure from repository', () async {
        when(mockRepository.searchProducts(
          query: 'test',
          page: 1,
          perPage: 20,
        )).thenAnswer((_) async => const Left(NetworkFailure(message: 'No connection')));

        final result = await useCase(query: 'test');

        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
          },
          (_) => fail('Should return failure'),
        );
      });
    });
  });
}
