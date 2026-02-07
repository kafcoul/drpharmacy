import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:drpharma_client/features/orders/domain/repositories/orders_repository.dart';
import 'package:drpharma_client/features/orders/domain/entities/order_entity.dart';
import 'package:drpharma_client/features/orders/domain/entities/delivery_address_entity.dart';

@GenerateMocks([OrdersRepository])
import 'get_orders_usecase_test.mocks.dart';

void main() {
  late GetOrdersUseCase useCase;
  late MockOrdersRepository mockRepository;

  setUp(() {
    mockRepository = MockOrdersRepository();
    useCase = GetOrdersUseCase(mockRepository);
  });

  group('GetOrdersUseCase', () {
    final testOrders = [
      OrderEntity(
        id: 1,
        reference: 'ORD-001',
        status: OrderStatus.pending,
        subtotal: 5000.0,
        deliveryFee: 500.0,
        totalAmount: 5500.0,
        paymentMode: PaymentMode.onDelivery,
        deliveryAddress: const DeliveryAddressEntity(
          address: '123 Rue Test',
        ),
        pharmacyId: 1,
        pharmacyName: 'Pharmacie Test',
        items: const [],
        createdAt: DateTime(2024, 1, 15),
      ),
      OrderEntity(
        id: 2,
        reference: 'ORD-002',
        status: OrderStatus.delivered,
        subtotal: 3000.0,
        deliveryFee: 500.0,
        totalAmount: 3500.0,
        paymentMode: PaymentMode.platform,
        deliveryAddress: const DeliveryAddressEntity(
          address: '456 Avenue Test',
        ),
        pharmacyId: 1,
        pharmacyName: 'Pharmacie Test',
        items: const [],
        createdAt: DateTime(2024, 1, 14),
      ),
    ];

    test('should get orders successfully with default parameters', () async {
      // Arrange
      when(mockRepository.getOrders(
        status: null,
        page: 1,
        perPage: 20,
      )).thenAnswer((_) async => Right(testOrders));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (orders) => expect(orders.length, 2),
      );
      verify(mockRepository.getOrders(
        status: null,
        page: 1,
        perPage: 20,
      )).called(1);
    });

    test('should get orders with status filter', () async {
      // Arrange
      when(mockRepository.getOrders(
        status: 'pending',
        page: 1,
        perPage: 20,
      )).thenAnswer((_) async => Right([testOrders[0]]));

      // Act
      final result = await useCase.call(status: 'pending');

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (orders) {
          expect(orders.length, 1);
          expect(orders.first.status, OrderStatus.pending);
        },
      );
    });

    test('should get orders with custom pagination', () async {
      // Arrange
      when(mockRepository.getOrders(
        status: null,
        page: 2,
        perPage: 10,
      )).thenAnswer((_) async => Right(testOrders));

      // Act
      final result = await useCase.call(page: 2, perPage: 10);

      // Assert
      expect(result.isRight(), isTrue);
      verify(mockRepository.getOrders(
        status: null,
        page: 2,
        perPage: 10,
      )).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(mockRepository.getOrders(
        status: null,
        page: 1,
        perPage: 20,
      )).thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    group('Validation', () {
      test('should return validation failure for page < 1', () async {
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
        verifyNever(mockRepository.getOrders(
          status: anyNamed('status'),
          page: anyNamed('page'),
          perPage: anyNamed('perPage'),
        ));
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

      test('should accept perPage at boundary 100', () async {
        // Arrange
        when(mockRepository.getOrders(
          status: null,
          page: 1,
          perPage: 100,
        )).thenAnswer((_) async => Right(testOrders));

        // Act
        final result = await useCase.call(perPage: 100);

        // Assert
        expect(result.isRight(), isTrue);
      });

      test('should return validation failure for empty status', () async {
        // Act
        final result = await useCase.call(status: '');

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['status'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
      });

      test('should return validation failure for whitespace-only status', () async {
        // Act
        final result = await useCase.call(status: '   ');

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Should be Left'),
        );
      });
    });
  });
}
