import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/products/domain/entities/product_entity.dart';
import 'package:drpharma_client/features/products/domain/entities/pharmacy_entity.dart';
import 'package:drpharma_client/features/products/domain/repositories/products_repository.dart';
import 'package:drpharma_client/features/products/domain/usecases/get_products_usecase.dart';

@GenerateMocks([ProductsRepository])
import 'get_products_usecase_test.mocks.dart';

void main() {
  late GetProductsUseCase useCase;
  late MockProductsRepository mockRepository;

  setUp(() {
    mockRepository = MockProductsRepository();
    useCase = GetProductsUseCase(mockRepository);
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

  group('GetProductsUseCase', () {
    group('validation', () {
      test('should return ValidationFailure when page is zero', () async {
        final result = await useCase(page: 0);

        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).message, 'Page number must be positive');
            expect(failure.errors['page'], contains('Page number must be positive'));
          },
          (_) => fail('Should return failure'),
        );

        verifyNever(mockRepository.getProducts(
          page: anyNamed('page'),
          perPage: anyNamed('perPage'),
        ));
      });

      test('should return ValidationFailure when page is negative', () async {
        final result = await useCase(page: -1);

        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).message, 'Page number must be positive');
          },
          (_) => fail('Should return failure'),
        );
      });

      test('should return ValidationFailure when perPage is zero', () async {
        final result = await useCase(perPage: 0);

        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).message, 'Per page must be between 1 and 100');
            expect(failure.errors['perPage'], contains('Per page must be between 1 and 100'));
          },
          (_) => fail('Should return failure'),
        );
      });

      test('should return ValidationFailure when perPage is negative', () async {
        final result = await useCase(perPage: -5);

        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
          },
          (_) => fail('Should return failure'),
        );
      });

      test('should return ValidationFailure when perPage exceeds 100', () async {
        final result = await useCase(perPage: 101);

        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).message, 'Per page must be between 1 and 100');
          },
          (_) => fail('Should return failure'),
        );
      });

      test('should return ValidationFailure when perPage is way too high', () async {
        final result = await useCase(perPage: 500);

        expect(result, isA<Left>());
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Should return failure'),
        );
      });
    });

    group('boundary values', () {
      test('should accept page = 1 (minimum valid)', () async {
        when(mockRepository.getProducts(page: 1, perPage: 20))
            .thenAnswer((_) async => const Right([]));

        final result = await useCase(page: 1);

        expect(result, isA<Right>());
        verify(mockRepository.getProducts(page: 1, perPage: 20)).called(1);
      });

      test('should accept perPage = 1 (minimum valid)', () async {
        when(mockRepository.getProducts(page: 1, perPage: 1))
            .thenAnswer((_) async => const Right([]));

        final result = await useCase(perPage: 1);

        expect(result, isA<Right>());
        verify(mockRepository.getProducts(page: 1, perPage: 1)).called(1);
      });

      test('should accept perPage = 100 (maximum valid)', () async {
        when(mockRepository.getProducts(page: 1, perPage: 100))
            .thenAnswer((_) async => const Right([]));

        final result = await useCase(perPage: 100);

        expect(result, isA<Right>());
        verify(mockRepository.getProducts(page: 1, perPage: 100)).called(1);
      });

      test('should accept high page numbers', () async {
        when(mockRepository.getProducts(page: 1000, perPage: 20))
            .thenAnswer((_) async => const Right([]));

        final result = await useCase(page: 1000);

        expect(result, isA<Right>());
        verify(mockRepository.getProducts(page: 1000, perPage: 20)).called(1);
      });
    });

    group('successful retrieval', () {
      test('should call repository with default values', () async {
        when(mockRepository.getProducts(page: 1, perPage: 20))
            .thenAnswer((_) async => const Right([]));

        await useCase();

        verify(mockRepository.getProducts(page: 1, perPage: 20)).called(1);
      });

      test('should return products from repository', () async {
        final products = [
          createTestProduct(id: 1, name: 'Product 1'),
          createTestProduct(id: 2, name: 'Product 2'),
          createTestProduct(id: 3, name: 'Product 3'),
        ];
        when(mockRepository.getProducts(page: 1, perPage: 20))
            .thenAnswer((_) async => Right(products));

        final result = await useCase();

        expect(result, isA<Right>());
        result.fold(
          (_) => fail('Should return success'),
          (data) {
            expect(data.length, 3);
            expect(data[0].name, 'Product 1');
            expect(data[1].name, 'Product 2');
            expect(data[2].name, 'Product 3');
          },
        );
      });

      test('should return empty list when no products', () async {
        when(mockRepository.getProducts(page: 1, perPage: 20))
            .thenAnswer((_) async => const Right([]));

        final result = await useCase();

        expect(result, isA<Right>());
        result.fold(
          (_) => fail('Should return success'),
          (data) => expect(data, isEmpty),
        );
      });
    });

    group('pagination', () {
      test('should pass custom page to repository', () async {
        when(mockRepository.getProducts(page: 5, perPage: 20))
            .thenAnswer((_) async => const Right([]));

        await useCase(page: 5);

        verify(mockRepository.getProducts(page: 5, perPage: 20)).called(1);
      });

      test('should pass custom perPage to repository', () async {
        when(mockRepository.getProducts(page: 1, perPage: 50))
            .thenAnswer((_) async => const Right([]));

        await useCase(perPage: 50);

        verify(mockRepository.getProducts(page: 1, perPage: 50)).called(1);
      });

      test('should pass both custom values', () async {
        when(mockRepository.getProducts(page: 3, perPage: 25))
            .thenAnswer((_) async => const Right([]));

        await useCase(page: 3, perPage: 25);

        verify(mockRepository.getProducts(page: 3, perPage: 25)).called(1);
      });
    });

    group('error handling', () {
      test('should return ServerFailure from repository', () async {
        when(mockRepository.getProducts(page: 1, perPage: 20))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Internal error')));

        final result = await useCase();

        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Internal error');
          },
          (_) => fail('Should return failure'),
        );
      });

      test('should return NetworkFailure from repository', () async {
        when(mockRepository.getProducts(page: 1, perPage: 20))
            .thenAnswer((_) async => const Left(NetworkFailure(message: 'No internet')));

        final result = await useCase();

        expect(result, isA<Left>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Should return failure'),
        );
      });

      test('should return CacheFailure from repository', () async {
        when(mockRepository.getProducts(page: 1, perPage: 20))
            .thenAnswer((_) async => const Left(CacheFailure(message: 'Cache error')));

        final result = await useCase();

        expect(result, isA<Left>());
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Should return failure'),
        );
      });
    });
  });
}
