import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/orders/domain/usecases/cancel_order_usecase.dart';
import 'package:drpharma_client/features/orders/domain/repositories/orders_repository.dart';

@GenerateMocks([OrdersRepository])
import 'cancel_order_usecase_test.mocks.dart';

void main() {
  late CancelOrderUseCase useCase;
  late MockOrdersRepository mockRepository;

  setUp(() {
    mockRepository = MockOrdersRepository();
    useCase = CancelOrderUseCase(mockRepository);
  });

  group('CancelOrderUseCase', () {
    const testOrderId = 1;
    const testReason = 'Changed my mind';

    test('should cancel order successfully', () async {
      // Arrange
      when(mockRepository.cancelOrder(testOrderId, testReason))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call(testOrderId, testReason);

      // Assert
      expect(result.isRight(), isTrue);
      verify(mockRepository.cancelOrder(testOrderId, testReason)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(mockRepository.cancelOrder(testOrderId, testReason))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      // Act
      final result = await useCase.call(testOrderId, testReason);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    group('Validation', () {
      test('should return validation failure for invalid order ID (0)', () async {
        // Act
        final result = await useCase.call(0, testReason);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['orderId'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
        verifyNever(mockRepository.cancelOrder(any, any));
      });

      test('should return validation failure for negative order ID', () async {
        // Act
        final result = await useCase.call(-1, testReason);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Should be Left'),
        );
        verifyNever(mockRepository.cancelOrder(any, any));
      });

      test('should return validation failure for empty reason', () async {
        // Act
        final result = await useCase.call(testOrderId, '');

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['reason'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
        verifyNever(mockRepository.cancelOrder(any, any));
      });

      test('should return validation failure for whitespace-only reason', () async {
        // Act
        final result = await useCase.call(testOrderId, '   ');

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Should be Left'),
        );
        verifyNever(mockRepository.cancelOrder(any, any));
      });

      test('should return validation failure for reason less than 3 characters', () async {
        // Act
        final result = await useCase.call(testOrderId, 'ab');

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).message, contains('3 characters'));
          },
          (_) => fail('Should be Left'),
        );
        verifyNever(mockRepository.cancelOrder(any, any));
      });

      test('should accept reason with exactly 3 characters', () async {
        // Arrange
        when(mockRepository.cancelOrder(testOrderId, 'abc'))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase.call(testOrderId, 'abc');

        // Assert
        expect(result.isRight(), isTrue);
        verify(mockRepository.cancelOrder(testOrderId, 'abc')).called(1);
      });
    });
  });
}
