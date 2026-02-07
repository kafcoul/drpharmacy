import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/products/domain/usecases/get_product_details_usecase.dart';
import 'package:drpharma_client/features/products/domain/repositories/products_repository.dart';

class MockProductsRepository extends Mock implements ProductsRepository {}

void main() {
  late GetProductDetailsUseCase useCase;
  late MockProductsRepository mockRepository;

  setUp(() {
    mockRepository = MockProductsRepository();
    useCase = GetProductDetailsUseCase(mockRepository);
  });

  group('GetProductDetailsUseCase Tests', () {
    test('should return ValidationFailure for invalid product ID', () async {
      final result = await useCase.call(0);
      
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return ValidationFailure for negative product ID', () async {
      final result = await useCase.call(-1);
      
      expect(result.isLeft(), true);
    });

    test('should call repository with valid product ID', () async {
      when(() => mockRepository.getProductDetails(any()))
          .thenAnswer((_) async => Left(ServerFailure(message: 'Not found')));
      
      await useCase.call(1);
      
      verify(() => mockRepository.getProductDetails(1)).called(1);
    });
  });
}
