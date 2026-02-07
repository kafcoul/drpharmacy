import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/orders/domain/entities/order_entity.dart';
import 'package:drpharma_client/features/orders/domain/entities/order_item_entity.dart';
import 'package:drpharma_client/features/orders/domain/entities/delivery_address_entity.dart';

void main() {
  const testDeliveryAddress = DeliveryAddressEntity(
    address: '123 Test Street',
    city: 'Abidjan',
    latitude: 5.3364,
    longitude: -4.0266,
    phone: '+2251234567890',
  );

  const testOrderItem = OrderItemEntity(
    id: 1,
    productId: 100,
    name: 'Test Product',
    quantity: 2,
    unitPrice: 500.0,
    totalPrice: 1000.0,
  );

  OrderEntity createOrder({
    int id = 1,
    OrderStatus status = OrderStatus.pending,
    String paymentStatus = 'pending',
    PaymentMode paymentMode = PaymentMode.platform,
    DateTime? paidAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    List<OrderItemEntity>? items,
  }) {
    return OrderEntity(
      id: id,
      reference: 'ORD-001',
      status: status,
      paymentStatus: paymentStatus,
      paymentMode: paymentMode,
      pharmacyId: 1,
      pharmacyName: 'Test Pharmacy',
      items: items ?? [testOrderItem],
      subtotal: 1000.0,
      deliveryFee: 500.0,
      totalAmount: 1500.0,
      deliveryAddress: testDeliveryAddress,
      createdAt: DateTime(2024, 1, 1),
      paidAt: paidAt,
      deliveredAt: deliveredAt,
      cancelledAt: cancelledAt,
    );
  }

  group('OrderStatus', () {
    group('displayName', () {
      test('pending should return "En attente"', () {
        expect(OrderStatus.pending.displayName, 'En attente');
      });

      test('confirmed should return "Confirmée"', () {
        expect(OrderStatus.confirmed.displayName, 'Confirmée');
      });

      test('ready should return "Prête"', () {
        expect(OrderStatus.ready.displayName, 'Prête');
      });

      test('delivering should return "En livraison"', () {
        expect(OrderStatus.delivering.displayName, 'En livraison');
      });

      test('delivered should return "Livrée"', () {
        expect(OrderStatus.delivered.displayName, 'Livrée');
      });

      test('cancelled should return "Annulée"', () {
        expect(OrderStatus.cancelled.displayName, 'Annulée');
      });

      test('failed should return "Échouée"', () {
        expect(OrderStatus.failed.displayName, 'Échouée');
      });
    });
  });

  group('PaymentMode', () {
    group('displayName', () {
      test('platform should return "Paiement en ligne"', () {
        expect(PaymentMode.platform.displayName, 'Paiement en ligne');
      });

      test('onDelivery should return "Paiement à la livraison"', () {
        expect(PaymentMode.onDelivery.displayName, 'Paiement à la livraison');
      });
    });
  });

  group('OrderEntity', () {
    group('constructor', () {
      test('should create with required parameters', () {
        final order = createOrder();

        expect(order.id, 1);
        expect(order.reference, 'ORD-001');
        expect(order.status, OrderStatus.pending);
        expect(order.paymentStatus, 'pending');
        expect(order.paymentMode, PaymentMode.platform);
        expect(order.pharmacyId, 1);
        expect(order.pharmacyName, 'Test Pharmacy');
        expect(order.subtotal, 1000.0);
        expect(order.deliveryFee, 500.0);
        expect(order.totalAmount, 1500.0);
        expect(order.currency, 'XOF');
      });
    });

    group('isPaid', () {
      test('should return true when paymentStatus is "paid"', () {
        final order = createOrder(paymentStatus: 'paid');
        expect(order.isPaid, isTrue);
      });

      test('should return true when paidAt is not null', () {
        final order = createOrder(paidAt: DateTime(2024, 1, 2));
        expect(order.isPaid, isTrue);
      });

      test('should return false when payment is pending', () {
        final order = createOrder(paymentStatus: 'pending');
        expect(order.isPaid, isFalse);
      });

      test('should return false when payment failed', () {
        final order = createOrder(paymentStatus: 'failed');
        expect(order.isPaid, isFalse);
      });
    });

    group('isDelivered', () {
      test('should return true when deliveredAt is not null', () {
        final order = createOrder(deliveredAt: DateTime(2024, 1, 3));
        expect(order.isDelivered, isTrue);
      });

      test('should return false when deliveredAt is null', () {
        final order = createOrder();
        expect(order.isDelivered, isFalse);
      });
    });

    group('isCancelled', () {
      test('should return true when status is cancelled', () {
        final order = createOrder(status: OrderStatus.cancelled);
        expect(order.isCancelled, isTrue);
      });

      test('should return false when status is not cancelled', () {
        final order = createOrder(status: OrderStatus.pending);
        expect(order.isCancelled, isFalse);
      });
    });

    group('canBeCancelled', () {
      test('should return true when status is pending', () {
        final order = createOrder(status: OrderStatus.pending);
        expect(order.canBeCancelled, isTrue);
      });

      test('should return true when status is confirmed', () {
        final order = createOrder(status: OrderStatus.confirmed);
        expect(order.canBeCancelled, isTrue);
      });

      test('should return false when status is ready', () {
        final order = createOrder(status: OrderStatus.ready);
        expect(order.canBeCancelled, isFalse);
      });

      test('should return false when status is delivering', () {
        final order = createOrder(status: OrderStatus.delivering);
        expect(order.canBeCancelled, isFalse);
      });

      test('should return false when status is delivered', () {
        final order = createOrder(status: OrderStatus.delivered);
        expect(order.canBeCancelled, isFalse);
      });

      test('should return false when status is cancelled', () {
        final order = createOrder(status: OrderStatus.cancelled);
        expect(order.canBeCancelled, isFalse);
      });
    });

    group('needsPayment', () {
      test('should return true for unpaid platform payment', () {
        final order = createOrder(
          paymentMode: PaymentMode.platform,
          paymentStatus: 'pending',
        );
        expect(order.needsPayment, isTrue);
      });

      test('should return false for paid order', () {
        final order = createOrder(
          paymentMode: PaymentMode.platform,
          paymentStatus: 'paid',
        );
        expect(order.needsPayment, isFalse);
      });

      test('should return false for cancelled order', () {
        final order = createOrder(
          paymentMode: PaymentMode.platform,
          paymentStatus: 'pending',
          status: OrderStatus.cancelled,
        );
        expect(order.needsPayment, isFalse);
      });

      test('should return false for onDelivery payment mode', () {
        final order = createOrder(
          paymentMode: PaymentMode.onDelivery,
          paymentStatus: 'pending',
        );
        expect(order.needsPayment, isFalse);
      });
    });

    group('itemCount', () {
      test('should return total quantity of all items', () {
        final items = [
          const OrderItemEntity(
            id: 1,
            productId: 1,
            name: 'Product 1',
            quantity: 2,
            unitPrice: 100.0,
            totalPrice: 200.0,
          ),
          const OrderItemEntity(
            id: 2,
            productId: 2,
            name: 'Product 2',
            quantity: 3,
            unitPrice: 150.0,
            totalPrice: 450.0,
          ),
        ];
        final order = createOrder(items: items);

        expect(order.itemCount, 5);
      });

      test('should return 0 for empty items list', () {
        final order = createOrder(items: []);
        expect(order.itemCount, 0);
      });
    });

    group('statusColor', () {
      test('pending should return "warning"', () {
        final order = createOrder(status: OrderStatus.pending);
        expect(order.statusColor, 'warning');
      });

      test('confirmed should return "info"', () {
        final order = createOrder(status: OrderStatus.confirmed);
        expect(order.statusColor, 'info');
      });

      test('ready should return "info"', () {
        final order = createOrder(status: OrderStatus.ready);
        expect(order.statusColor, 'info');
      });

      test('delivering should return "primary"', () {
        final order = createOrder(status: OrderStatus.delivering);
        expect(order.statusColor, 'primary');
      });

      test('delivered should return "success"', () {
        final order = createOrder(status: OrderStatus.delivered);
        expect(order.statusColor, 'success');
      });

      test('cancelled should return "error"', () {
        final order = createOrder(status: OrderStatus.cancelled);
        expect(order.statusColor, 'error');
      });

      test('failed should return "error"', () {
        final order = createOrder(status: OrderStatus.failed);
        expect(order.statusColor, 'error');
      });
    });

    group('equality', () {
      test('should be equal when props match', () {
        final order1 = createOrder(id: 1);
        final order2 = createOrder(id: 1);

        expect(order1, equals(order2));
      });

      test('should not be equal when id differs', () {
        final order1 = createOrder(id: 1);
        final order2 = createOrder(id: 2);

        expect(order1, isNot(equals(order2)));
      });
    });
  });

  group('DeliveryAddressEntity', () {
    test('should create with required parameters', () {
      const address = DeliveryAddressEntity(
        address: '123 Main St',
      );

      expect(address.address, '123 Main St');
      expect(address.city, isNull);
      expect(address.latitude, isNull);
      expect(address.longitude, isNull);
      expect(address.phone, isNull);
    });

    test('should create with all parameters', () {
      expect(testDeliveryAddress.address, '123 Test Street');
      expect(testDeliveryAddress.city, 'Abidjan');
      expect(testDeliveryAddress.latitude, 5.3364);
      expect(testDeliveryAddress.longitude, -4.0266);
      expect(testDeliveryAddress.phone, '+2251234567890');
    });
  });

  group('OrderItemEntity', () {
    test('should create with required parameters', () {
      expect(testOrderItem.id, 1);
      expect(testOrderItem.productId, 100);
      expect(testOrderItem.name, 'Test Product');
      expect(testOrderItem.quantity, 2);
      expect(testOrderItem.unitPrice, 500.0);
      expect(testOrderItem.totalPrice, 1000.0);
    });
  });
}
