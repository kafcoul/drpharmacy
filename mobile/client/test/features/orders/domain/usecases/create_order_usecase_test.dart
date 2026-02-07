import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/orders/domain/usecases/create_order_usecase.dart';
import 'package:drpharma_client/features/orders/domain/repositories/orders_repository.dart';
import 'package:drpharma_client/features/orders/domain/entities/order_entity.dart';
import 'package:drpharma_client/features/orders/domain/entities/order_item_entity.dart';
import 'package:drpharma_client/features/orders/domain/entities/delivery_address_entity.dart';

@GenerateMocks([OrdersRepository])
import 'create_order_usecase_test.mocks.dart';

void main() {
  late CreateOrderUseCase useCase;
  late MockOrdersRepository mockRepository;

  setUp(() {
    mockRepository = MockOrdersRepository();
    useCase = CreateOrderUseCase(mockRepository);
  });

  group('CreateOrderUseCase', () {
    const testDeliveryAddress = DeliveryAddressEntity(
      address: '123 Rue Test',
      city: 'Libreville',
      latitude: 0.4162,
      longitude: 9.4673,
      phone: '+24177123456',
    );

    const testItems = [
      OrderItemEntity(
        productId: 1,
        name: 'Paracetamol 500mg',
        quantity: 2,
        unitPrice: 1500.0,
        totalPrice: 3000.0,
      ),
      OrderItemEntity(
        productId: 2,
        name: 'Ibuprofène 400mg',
        quantity: 1,
        unitPrice: 2000.0,
        totalPrice: 2000.0,
      ),
    ];

    final testOrder = OrderEntity(
      id: 1,
      reference: 'ORD-001',
      status: OrderStatus.pending,
      subtotal: 5000.0,
      deliveryFee: 500.0,
      totalAmount: 5500.0,
      paymentMode: PaymentMode.onDelivery,
      deliveryAddress: testDeliveryAddress,
      pharmacyId: 1,
      pharmacyName: 'Pharmacie Test',
      items: testItems,
      createdAt: DateTime(2024, 1, 15),
    );

    test('should create order successfully with on_delivery payment', () async {
      // Arrange
      when(mockRepository.createOrder(
        pharmacyId: 1,
        items: testItems,
        deliveryAddress: testDeliveryAddress,
        paymentMode: 'on_delivery',
        prescriptionImage: null,
        customerNotes: null,
        prescriptionId: null,
      )).thenAnswer((_) async => Right(testOrder));

      // Act
      final result = await useCase.call(
        pharmacyId: 1,
        items: testItems,
        deliveryAddress: testDeliveryAddress,
        paymentMode: 'on_delivery',
      );

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
    });

    test('should create order successfully with platform payment', () async {
      // Arrange
      when(mockRepository.createOrder(
        pharmacyId: 1,
        items: testItems,
        deliveryAddress: testDeliveryAddress,
        paymentMode: 'platform',
        prescriptionImage: null,
        customerNotes: null,
        prescriptionId: null,
      )).thenAnswer((_) async => Right(testOrder));

      // Act
      final result = await useCase.call(
        pharmacyId: 1,
        items: testItems,
        deliveryAddress: testDeliveryAddress,
        paymentMode: 'platform',
      );

      // Assert
      expect(result.isRight(), isTrue);
    });

    test('should create order with prescription image', () async {
      // Arrange
      when(mockRepository.createOrder(
        pharmacyId: 1,
        items: testItems,
        deliveryAddress: testDeliveryAddress,
        paymentMode: 'on_delivery',
        prescriptionImage: '/path/to/prescription.jpg',
        customerNotes: null,
        prescriptionId: null,
      )).thenAnswer((_) async => Right(testOrder));

      // Act
      final result = await useCase.call(
        pharmacyId: 1,
        items: testItems,
        deliveryAddress: testDeliveryAddress,
        paymentMode: 'on_delivery',
        prescriptionImage: '/path/to/prescription.jpg',
      );

      // Assert
      expect(result.isRight(), isTrue);
    });

    test('should create order with customer notes', () async {
      // Arrange
      when(mockRepository.createOrder(
        pharmacyId: 1,
        items: testItems,
        deliveryAddress: testDeliveryAddress,
        paymentMode: 'on_delivery',
        prescriptionImage: null,
        customerNotes: 'Please call before delivery',
        prescriptionId: null,
      )).thenAnswer((_) async => Right(testOrder));

      // Act
      final result = await useCase.call(
        pharmacyId: 1,
        items: testItems,
        deliveryAddress: testDeliveryAddress,
        paymentMode: 'on_delivery',
        customerNotes: 'Please call before delivery',
      );

      // Assert
      expect(result.isRight(), isTrue);
    });

    test('should create order with prescription ID', () async {
      // Arrange
      when(mockRepository.createOrder(
        pharmacyId: 1,
        items: testItems,
        deliveryAddress: testDeliveryAddress,
        paymentMode: 'on_delivery',
        prescriptionImage: null,
        customerNotes: null,
        prescriptionId: 123,
      )).thenAnswer((_) async => Right(testOrder));

      // Act
      final result = await useCase.call(
        pharmacyId: 1,
        items: testItems,
        deliveryAddress: testDeliveryAddress,
        paymentMode: 'on_delivery',
        prescriptionId: 123,
      );

      // Assert
      expect(result.isRight(), isTrue);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(mockRepository.createOrder(
        pharmacyId: 1,
        items: testItems,
        deliveryAddress: testDeliveryAddress,
        paymentMode: 'on_delivery',
        prescriptionImage: null,
        customerNotes: null,
        prescriptionId: null,
      )).thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      // Act
      final result = await useCase.call(
        pharmacyId: 1,
        items: testItems,
        deliveryAddress: testDeliveryAddress,
        paymentMode: 'on_delivery',
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    group('Validation - pharmacyId', () {
      test('should return validation failure for pharmacyId <= 0', () async {
        // Act
        final result = await useCase.call(
          pharmacyId: 0,
          items: testItems,
          deliveryAddress: testDeliveryAddress,
          paymentMode: 'on_delivery',
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['pharmacyId'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
      });

      test('should return validation failure for negative pharmacyId', () async {
        // Act
        final result = await useCase.call(
          pharmacyId: -1,
          items: testItems,
          deliveryAddress: testDeliveryAddress,
          paymentMode: 'on_delivery',
        );

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });

    group('Validation - items', () {
      test('should return validation failure for empty items', () async {
        // Act
        final result = await useCase.call(
          pharmacyId: 1,
          items: const [],
          deliveryAddress: testDeliveryAddress,
          paymentMode: 'on_delivery',
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['items'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
      });

      test('should return validation failure for item with quantity <= 0', () async {
        // Act
        final result = await useCase.call(
          pharmacyId: 1,
          items: const [
            OrderItemEntity(
              productId: 1,
              name: 'Paracetamol',
              quantity: 0,
              unitPrice: 1500.0,
              totalPrice: 0.0,
            ),
          ],
          deliveryAddress: testDeliveryAddress,
          paymentMode: 'on_delivery',
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['quantity'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
      });

      test('should return validation failure for item with negative quantity', () async {
        // Act
        final result = await useCase.call(
          pharmacyId: 1,
          items: const [
            OrderItemEntity(
              productId: 1,
              name: 'Paracetamol',
              quantity: -1,
              unitPrice: 1500.0,
              totalPrice: -1500.0,
            ),
          ],
          deliveryAddress: testDeliveryAddress,
          paymentMode: 'on_delivery',
        );

        // Assert
        expect(result.isLeft(), isTrue);
      });

      test('should return validation failure for item with negative price', () async {
        // Act
        final result = await useCase.call(
          pharmacyId: 1,
          items: const [
            OrderItemEntity(
              productId: 1,
              name: 'Paracetamol',
              quantity: 1,
              unitPrice: -1500.0,
              totalPrice: -1500.0,
            ),
          ],
          deliveryAddress: testDeliveryAddress,
          paymentMode: 'on_delivery',
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['price'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
      });

      test('should return validation failure for item with empty name', () async {
        // Act
        final result = await useCase.call(
          pharmacyId: 1,
          items: const [
            OrderItemEntity(
              productId: 1,
              name: '',
              quantity: 1,
              unitPrice: 1500.0,
              totalPrice: 1500.0,
            ),
          ],
          deliveryAddress: testDeliveryAddress,
          paymentMode: 'on_delivery',
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['name'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
      });

      test('should return validation failure for item with whitespace-only name', () async {
        // Act
        final result = await useCase.call(
          pharmacyId: 1,
          items: const [
            OrderItemEntity(
              productId: 1,
              name: '   ',
              quantity: 1,
              unitPrice: 1500.0,
              totalPrice: 1500.0,
            ),
          ],
          deliveryAddress: testDeliveryAddress,
          paymentMode: 'on_delivery',
        );

        // Assert
        expect(result.isLeft(), isTrue);
      });

      test('should accept item with zero price', () async {
        // Arrange
        const freeItem = [
          OrderItemEntity(
            productId: 1,
            name: 'Free Sample',
            quantity: 1,
            unitPrice: 0.0,
            totalPrice: 0.0,
          ),
        ];
        
        when(mockRepository.createOrder(
          pharmacyId: 1,
          items: freeItem,
          deliveryAddress: testDeliveryAddress,
          paymentMode: 'on_delivery',
          prescriptionImage: null,
          customerNotes: null,
          prescriptionId: null,
        )).thenAnswer((_) async => Right(testOrder));

        // Act
        final result = await useCase.call(
          pharmacyId: 1,
          items: freeItem,
          deliveryAddress: testDeliveryAddress,
          paymentMode: 'on_delivery',
        );

        // Assert
        expect(result.isRight(), isTrue);
      });
    });

    group('Validation - deliveryAddress', () {
      test('should return validation failure for empty delivery address', () async {
        // Act
        final result = await useCase.call(
          pharmacyId: 1,
          items: testItems,
          deliveryAddress: const DeliveryAddressEntity(address: ''),
          paymentMode: 'on_delivery',
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['address'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
      });

      test('should return validation failure for whitespace-only delivery address', () async {
        // Act
        final result = await useCase.call(
          pharmacyId: 1,
          items: testItems,
          deliveryAddress: const DeliveryAddressEntity(address: '   '),
          paymentMode: 'on_delivery',
        );

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });

    group('Validation - paymentMode', () {
      test('should return validation failure for invalid payment mode', () async {
        // Act
        final result = await useCase.call(
          pharmacyId: 1,
          items: testItems,
          deliveryAddress: testDeliveryAddress,
          paymentMode: 'invalid_mode',
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect((failure as ValidationFailure).errors['paymentMode'], isNotEmpty);
          },
          (_) => fail('Should be Left'),
        );
      });

      test('should return validation failure for credit_card payment mode', () async {
        // Act
        final result = await useCase.call(
          pharmacyId: 1,
          items: testItems,
          deliveryAddress: testDeliveryAddress,
          paymentMode: 'credit_card',
        );

        // Assert
        expect(result.isLeft(), isTrue);
      });

      test('should return validation failure for empty payment mode', () async {
        // Act
        final result = await useCase.call(
          pharmacyId: 1,
          items: testItems,
          deliveryAddress: testDeliveryAddress,
          paymentMode: '',
        );

        // Assert
        expect(result.isLeft(), isTrue);
      });

      test('should accept platform payment mode', () async {
        // Arrange
        when(mockRepository.createOrder(
          pharmacyId: 1,
          items: testItems,
          deliveryAddress: testDeliveryAddress,
          paymentMode: 'platform',
          prescriptionImage: null,
          customerNotes: null,
          prescriptionId: null,
        )).thenAnswer((_) async => Right(testOrder));

        // Act
        final result = await useCase.call(
          pharmacyId: 1,
          items: testItems,
          deliveryAddress: testDeliveryAddress,
          paymentMode: 'platform',
        );

        // Assert
        expect(result.isRight(), isTrue);
      });

      test('should accept on_delivery payment mode', () async {
        // Arrange
        when(mockRepository.createOrder(
          pharmacyId: 1,
          items: testItems,
          deliveryAddress: testDeliveryAddress,
          paymentMode: 'on_delivery',
          prescriptionImage: null,
          customerNotes: null,
          prescriptionId: null,
        )).thenAnswer((_) async => Right(testOrder));

        // Act
        final result = await useCase.call(
          pharmacyId: 1,
          items: testItems,
          deliveryAddress: testDeliveryAddress,
          paymentMode: 'on_delivery',
        );

        // Assert
        expect(result.isRight(), isTrue);
      });
    });
  });
}
