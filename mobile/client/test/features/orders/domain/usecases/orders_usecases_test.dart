import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/orders/domain/entities/order_entity.dart';
import 'package:drpharma_client/features/orders/domain/entities/order_item_entity.dart';
import 'package:drpharma_client/features/orders/domain/entities/delivery_address_entity.dart';
import 'package:drpharma_client/features/orders/domain/repositories/orders_repository.dart';
import 'package:drpharma_client/features/orders/domain/usecases/create_order_usecase.dart';
import 'package:drpharma_client/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:drpharma_client/features/orders/domain/usecases/get_order_details_usecase.dart';
import 'package:drpharma_client/features/orders/domain/usecases/cancel_order_usecase.dart';

import 'orders_usecases_test.mocks.dart';

@GenerateMocks([OrdersRepository])
void main() {
  late MockOrdersRepository mockRepository;
  late CreateOrderUseCase createOrderUseCase;
  late GetOrdersUseCase getOrdersUseCase;
  late GetOrderDetailsUseCase getOrderDetailsUseCase;
  late CancelOrderUseCase cancelOrderUseCase;

  setUp(() {
    mockRepository = MockOrdersRepository();
    createOrderUseCase = CreateOrderUseCase(mockRepository);
    getOrdersUseCase = GetOrdersUseCase(mockRepository);
    getOrderDetailsUseCase = GetOrderDetailsUseCase(mockRepository);
    cancelOrderUseCase = CancelOrderUseCase(mockRepository);
  });

  // Test data
  const testDeliveryAddress = DeliveryAddressEntity(
    address: '123 Test Street, Libreville',
    city: 'Libreville',
    phone: '+24107123456',
    latitude: 0.4162,
    longitude: 9.4673,
  );

  const testOrderItems = <OrderItemEntity>[
    OrderItemEntity(
      id: 1,
      productId: 1,
      name: 'Paracétamol 500mg',
      quantity: 2,
      unitPrice: 1500.0,
      totalPrice: 3000.0,
    ),
  ];

  final testOrder = OrderEntity(
    id: 1,
    reference: 'ORD-001',
    status: OrderStatus.pending,
    paymentMode: PaymentMode.onDelivery,
    pharmacyId: 1,
    pharmacyName: 'Pharmacie Test',
    items: testOrderItems,
    subtotal: 3000.0,
    deliveryFee: 500.0,
    totalAmount: 3500.0,
    deliveryAddress: testDeliveryAddress,
    createdAt: DateTime.now(),
    currency: 'XOF',
    paymentStatus: 'pending',
  );

  group('CreateOrderUseCase', () {
    test('should return ValidationFailure when pharmacyId is invalid', () async {
      // Act
      final result = await createOrderUseCase(
        pharmacyId: 0,
        items: testOrderItems,
        deliveryAddress: testDeliveryAddress,
        paymentMode: 'on_delivery',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).errors.containsKey('pharmacyId'), true);
        },
        (_) => fail('Should have returned failure'),
      );
    });

    test('should return ValidationFailure when items list is empty', () async {
      // Act
      final result = await createOrderUseCase(
        pharmacyId: 1,
        items: [],
        deliveryAddress: testDeliveryAddress,
        paymentMode: 'on_delivery',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).errors.containsKey('items'), true);
        },
        (_) => fail('Should have returned failure'),
      );
    });

    test('should return ValidationFailure when item quantity is 0', () async {
      // Act
      final result = await createOrderUseCase(
        pharmacyId: 1,
        items: const <OrderItemEntity>[
          OrderItemEntity(
            id: 1,
            productId: 1,
            name: 'Test',
            quantity: 0,
            unitPrice: 1000.0,
            totalPrice: 0.0,
          ),
        ],
        deliveryAddress: testDeliveryAddress,
        paymentMode: 'on_delivery',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (_) => fail('Should have returned failure'),
      );
    });

    test('should call repository when validation passes', () async {
      // Arrange
      when(mockRepository.createOrder(
        pharmacyId: anyNamed('pharmacyId'),
        items: anyNamed('items'),
        deliveryAddress: anyNamed('deliveryAddress'),
        paymentMode: anyNamed('paymentMode'),
        prescriptionImage: anyNamed('prescriptionImage'),
        customerNotes: anyNamed('customerNotes'),
        prescriptionId: anyNamed('prescriptionId'),
      )).thenAnswer((_) async => Right(testOrder));

      // Act
      final result = await createOrderUseCase(
        pharmacyId: 1,
        items: testOrderItems,
        deliveryAddress: testDeliveryAddress,
        paymentMode: 'on_delivery',
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockRepository.createOrder(
        pharmacyId: 1,
        items: testOrderItems,
        deliveryAddress: testDeliveryAddress,
        paymentMode: 'on_delivery',
        prescriptionImage: null,
        customerNotes: null,
        prescriptionId: null,
      )).called(1);
    });

    test('should return order on successful creation', () async {
      // Arrange
      when(mockRepository.createOrder(
        pharmacyId: anyNamed('pharmacyId'),
        items: anyNamed('items'),
        deliveryAddress: anyNamed('deliveryAddress'),
        paymentMode: anyNamed('paymentMode'),
        prescriptionImage: anyNamed('prescriptionImage'),
        customerNotes: anyNamed('customerNotes'),
        prescriptionId: anyNamed('prescriptionId'),
      )).thenAnswer((_) async => Right(testOrder));

      // Act
      final result = await createOrderUseCase(
        pharmacyId: 1,
        items: testOrderItems,
        deliveryAddress: testDeliveryAddress,
        paymentMode: 'on_delivery',
      );

      // Assert
      result.fold(
        (failure) => fail('Should have returned order'),
        (order) {
          expect(order.id, testOrder.id);
          expect(order.reference, testOrder.reference);
        },
      );
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(mockRepository.createOrder(
        pharmacyId: anyNamed('pharmacyId'),
        items: anyNamed('items'),
        deliveryAddress: anyNamed('deliveryAddress'),
        paymentMode: anyNamed('paymentMode'),
        prescriptionImage: anyNamed('prescriptionImage'),
        customerNotes: anyNamed('customerNotes'),
        prescriptionId: anyNamed('prescriptionId'),
      )).thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      // Act
      final result = await createOrderUseCase(
        pharmacyId: 1,
        items: testOrderItems,
        deliveryAddress: testDeliveryAddress,
        paymentMode: 'on_delivery',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should have returned failure'),
      );
    });
  });

  group('GetOrdersUseCase', () {
    test('should return list of orders on success', () async {
      // Arrange
      when(mockRepository.getOrders(
        status: anyNamed('status'),
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => Right([testOrder]));

      // Act
      final result = await getOrdersUseCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should have returned orders'),
        (orders) {
          expect(orders.length, 1);
          expect(orders.first.id, testOrder.id);
        },
      );
    });

    test('should pass status filter to repository', () async {
      // Arrange
      when(mockRepository.getOrders(
        status: anyNamed('status'),
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => Right([testOrder]));

      // Act
      await getOrdersUseCase(status: 'pending');

      // Assert
      verify(mockRepository.getOrders(
        status: 'pending',
        page: 1,
        perPage: 20,
      )).called(1);
    });

    test('should return failure on repository error', () async {
      // Arrange
      when(mockRepository.getOrders(
        status: anyNamed('status'),
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => const Left(NetworkFailure(message: 'No connection')));

      // Act
      final result = await getOrdersUseCase();

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('GetOrderDetailsUseCase', () {
    test('should return order details on success', () async {
      // Arrange
      when(mockRepository.getOrderDetails(any))
          .thenAnswer((_) async => Right(testOrder));

      // Act
      final result = await getOrderDetailsUseCase(1);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should have returned order'),
        (order) => expect(order.id, 1),
      );
    });

    test('should call repository with correct orderId', () async {
      // Arrange
      when(mockRepository.getOrderDetails(any))
          .thenAnswer((_) async => Right(testOrder));

      // Act
      await getOrderDetailsUseCase(42);

      // Assert
      verify(mockRepository.getOrderDetails(42)).called(1);
    });

    test('should return failure when order not found', () async {
      // Arrange
      when(mockRepository.getOrderDetails(any))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Order not found', statusCode: 404)));

      // Act
      final result = await getOrderDetailsUseCase(999);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).statusCode, 404);
        },
        (_) => fail('Should have returned failure'),
      );
    });
  });

  group('CancelOrderUseCase', () {
    test('should return success on cancellation', () async {
      // Arrange
      when(mockRepository.cancelOrder(any, any))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await cancelOrderUseCase(1, 'Changed my mind');

      // Assert
      expect(result.isRight(), true);
    });

    test('should pass correct parameters to repository', () async {
      // Arrange
      when(mockRepository.cancelOrder(any, any))
          .thenAnswer((_) async => const Right(null));

      // Act
      await cancelOrderUseCase(42, 'Found better price');

      // Assert
      verify(mockRepository.cancelOrder(42, 'Found better price')).called(1);
    });

    test('should return failure when cancellation not allowed', () async {
      // Arrange
      when(mockRepository.cancelOrder(any, any))
          .thenAnswer((_) async => const Left(
            ValidationFailure(
              message: 'Cannot cancel delivered order',
              errors: {'order': ['Cannot cancel delivered order']},
            ),
          ));

      // Act
      final result = await cancelOrderUseCase(1, 'Test reason here');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should have returned failure'),
      );
    });

    test('should return ValidationFailure for invalid orderId', () async {
      // Act
      final result = await cancelOrderUseCase(0, 'Valid reason');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).errors.containsKey('orderId'), true);
        },
        (_) => fail('Should have returned failure'),
      );
    });

    test('should return ValidationFailure for empty reason', () async {
      // Act
      final result = await cancelOrderUseCase(1, '');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should have returned failure'),
      );
    });

    test('should return ValidationFailure for reason too short', () async {
      // Act
      final result = await cancelOrderUseCase(1, 'ab');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (_) => fail('Should have returned failure'),
      );
    });
  });
}
