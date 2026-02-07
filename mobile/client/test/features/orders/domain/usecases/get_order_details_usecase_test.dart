import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/orders/domain/usecases/get_order_details_usecase.dart';
import 'package:drpharma_client/features/orders/domain/repositories/orders_repository.dart';
import 'package:drpharma_client/features/orders/domain/entities/order_entity.dart';
import 'package:drpharma_client/features/orders/domain/entities/delivery_address_entity.dart';

@GenerateMocks([OrdersRepository])
import 'get_order_details_usecase_test.mocks.dart';

void main() {
  late GetOrderDetailsUseCase useCase;
  late MockOrdersRepository mockRepository;

  setUp(() {
    mockRepository = MockOrdersRepository();
    useCase = GetOrderDetailsUseCase(mockRepository);
  });

  group('GetOrderDetailsUseCase', () {
    final testOrder = OrderEntity(
      id: 1,
      reference: 'ORD-001',
      status: OrderStatus.pending,
      subtotal: 5000.0,
      deliveryFee: 500.0,
      totalAmount: 5500.0,
      paymentMode: PaymentMode.onDelivery,
      deliveryAddress: const DeliveryAddressEntity(
        address: '123 Rue Test',
        city: 'Libreville',
        latitude: 0.4162,
        longitude: 9.4673,
        phone: '+24177123456',
      ),
      pharmacyId: 1,
      pharmacyName: 'Pharmacie Test',
      items: const [],
      createdAt: DateTime(2024, 1, 15),
    );

    test('should get order details successfully', () async {
      // Arrange
      when(mockRepository.getOrderDetails(1))
          .thenAnswer((_) async => Right(testOrder));

      // Act
      final result = await useCase.call(1);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (order) {
          expect(order.id, 1);
          expect(order.reference, 'ORD-001');
          expect(order.status, OrderStatus.pending);
        },
      );
      verify(mockRepository.getOrderDetails(1)).called(1);
    });

    test('should return order with all details', () async {
      // Arrange
      when(mockRepository.getOrderDetails(1))
          .thenAnswer((_) async => Right(testOrder));

      // Act
      final result = await useCase.call(1);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (order) {
          expect(order.subtotal, 5000.0);
          expect(order.deliveryFee, 500.0);
          expect(order.totalAmount, 5500.0);
          expect(order.pharmacyName, 'Pharmacie Test');
          expect(order.deliveryAddress.address, '123 Rue Test');
        },
      );
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(mockRepository.getOrderDetails(1))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      // Act
      final result = await useCase.call(1);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    test('should return not found failure when order does not exist', () async {
      // Arrange
      when(mockRepository.getOrderDetails(999))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Order not found')));

      // Act
      final result = await useCase.call(999);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    group('Validation', () {
      test('should return validation failure for orderId <= 0', () async {
        // Act
        final result = await useCase.call(0);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['orderId'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
        verifyNever(mockRepository.getOrderDetails(any));
      });

      test('should return validation failure for negative orderId', () async {
        // Act
        final result = await useCase.call(-1);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Should be Left'),
        );
        verifyNever(mockRepository.getOrderDetails(any));
      });

      test('should return validation failure for orderId -100', () async {
        // Act
        final result = await useCase.call(-100);

        // Assert
        expect(result.isLeft(), isTrue);
        verifyNever(mockRepository.getOrderDetails(any));
      });

      test('should accept valid positive orderId', () async {
        // Arrange
        when(mockRepository.getOrderDetails(1))
            .thenAnswer((_) async => Right(testOrder));

        // Act
        final result = await useCase.call(1);

        // Assert
        expect(result.isRight(), isTrue);
        verify(mockRepository.getOrderDetails(1)).called(1);
      });

      test('should accept large valid orderId', () async {
        // Arrange
        when(mockRepository.getOrderDetails(999999))
            .thenAnswer((_) async => Right(testOrder));

        // Act
        final result = await useCase.call(999999);

        // Assert
        expect(result.isRight(), isTrue);
        verify(mockRepository.getOrderDetails(999999)).called(1);
      });
    });
  });
}
