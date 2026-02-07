import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/features/orders/data/models/order_model.dart';
import 'package:drpharma_client/features/orders/data/models/order_item_model.dart';
import 'package:drpharma_client/features/orders/data/models/delivery_address_model.dart';
import 'package:drpharma_client/features/orders/domain/entities/order_entity.dart';

void main() {
  group('OrderModel', () {
    group('fromJson', () {
      test('should correctly parse complete order data', () {
        // Arrange
        final json = {
          'id': 1,
          'reference': 'ORD-001',
          'status': 'pending',
          'payment_status': 'pending',
          'delivery_code': 'ABC123',
          'payment_mode': 'on_delivery',
          'pharmacy_id': 1,
          'pharmacy': {
            'id': 1,
            'name': 'Pharmacie Test',
            'phone': '+24177123456',
            'address': '123 Rue Test',
          },
          'items': [
            {
              'id': 1,
              'name': 'Paracetamol',
              'quantity': 2,
              'unit_price': 1500.0,
              'total_price': 3000.0,
            },
          ],
          'subtotal': 3000.0,
          'delivery_fee': 500.0,
          'total_amount': 3500.0,
          'currency': 'XOF',
          'delivery_address': '456 Avenue Test',
          'delivery_city': 'Libreville',
          'delivery_latitude': 0.4162,
          'delivery_longitude': 9.4673,
          'customer_phone': '+24177654321',
          'customer_notes': 'Please call before delivery',
          'created_at': '2024-01-15T10:00:00.000Z',
        };

        // Act
        final model = OrderModel.fromJson(json);

        // Assert
        expect(model.id, 1);
        expect(model.reference, 'ORD-001');
        expect(model.status, 'pending');
        expect(model.paymentStatus, 'pending');
        expect(model.deliveryCode, 'ABC123');
        expect(model.paymentMode, 'on_delivery');
        expect(model.pharmacyId, 1);
        expect(model.pharmacy?.name, 'Pharmacie Test');
        expect(model.items.length, 1);
        expect(model.subtotal, 3000.0);
        expect(model.deliveryFee, 500.0);
        expect(model.totalAmount, 3500.0);
        expect(model.deliveryAddress, '456 Avenue Test');
        expect(model.deliveryCity, 'Libreville');
      });

      test('should correctly parse minimal order data', () {
        // Arrange
        final json = {
          'id': 1,
          'reference': 'ORD-002',
          'status': 'pending',
          'payment_mode': 'platform',
          'total_amount': 5000.0,
          'delivery_address': '789 Rue Test',
          'created_at': '2024-01-15T10:00:00.000Z',
        };

        // Act
        final model = OrderModel.fromJson(json);

        // Assert
        expect(model.id, 1);
        expect(model.reference, 'ORD-002');
        expect(model.paymentStatus, 'pending'); // default value
        expect(model.items, isEmpty);
        expect(model.currency, 'XOF'); // default value
      });

      test('should handle string amounts from API', () {
        // Arrange (API sometimes returns amounts as strings)
        final json = {
          'id': 1,
          'reference': 'ORD-003',
          'status': 'pending',
          'payment_mode': 'platform',
          'subtotal': '2500.00',
          'delivery_fee': '500.00',
          'total_amount': '3000.00',
          'delivery_address': '123 Rue Test',
          'created_at': '2024-01-15T10:00:00.000Z',
        };

        // Act
        final model = OrderModel.fromJson(json);

        // Assert
        expect(model.subtotal, 2500.0);
        expect(model.deliveryFee, 500.0);
        expect(model.totalAmount, 3000.0);
      });

      test('should handle numeric amounts from API', () {
        // Arrange
        final json = {
          'id': 1,
          'reference': 'ORD-004',
          'status': 'pending',
          'payment_mode': 'platform',
          'subtotal': 2500,
          'delivery_fee': 500,
          'total_amount': 3000,
          'delivery_address': '123 Rue Test',
          'created_at': '2024-01-15T10:00:00.000Z',
        };

        // Act
        final model = OrderModel.fromJson(json);

        // Assert
        expect(model.subtotal, 2500.0);
        expect(model.deliveryFee, 500.0);
        expect(model.totalAmount, 3000.0);
      });
    });

    group('toEntity', () {
      test('should correctly convert to OrderEntity', () {
        // Arrange
        final model = OrderModel(
          id: 1,
          reference: 'ORD-001',
          status: 'pending',
          paymentMode: 'on_delivery',
          pharmacyId: 1,
          pharmacy: const PharmacyBasicModel(
            id: 1,
            name: 'Pharmacie Test',
            phone: '+24177123456',
            address: '123 Rue Pharmacie',
          ),
          items: const [],
          subtotal: 3000.0,
          deliveryFee: 500.0,
          totalAmount: 3500.0,
          deliveryAddress: '456 Avenue Test',
          deliveryCity: 'Libreville',
          createdAt: '2024-01-15T10:00:00.000Z',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<OrderEntity>());
        expect(entity.id, 1);
        expect(entity.reference, 'ORD-001');
        expect(entity.status, OrderStatus.pending);
        expect(entity.paymentMode, PaymentMode.onDelivery);
        expect(entity.pharmacyId, 1);
        expect(entity.pharmacyName, 'Pharmacie Test');
        expect(entity.pharmacyPhone, '+24177123456');
        expect(entity.subtotal, 3000.0);
        expect(entity.deliveryFee, 500.0);
        expect(entity.totalAmount, 3500.0);
        expect(entity.deliveryAddress.address, '456 Avenue Test');
        expect(entity.deliveryAddress.city, 'Libreville');
      });

      test('should correctly parse order status', () {
        final testCases = {
          'pending': OrderStatus.pending,
          'confirmed': OrderStatus.confirmed,
          'ready': OrderStatus.ready,
          'delivering': OrderStatus.delivering,
          'delivered': OrderStatus.delivered,
          'cancelled': OrderStatus.cancelled,
          'failed': OrderStatus.failed,
          'PENDING': OrderStatus.pending, // case insensitive
          'unknown': OrderStatus.pending, // default
        };

        for (final entry in testCases.entries) {
          final model = OrderModel(
            id: 1,
            reference: 'ORD-001',
            status: entry.key,
            paymentMode: 'platform',
            totalAmount: 1000.0,
            deliveryAddress: 'Test',
            createdAt: '2024-01-15T10:00:00.000Z',
          );

          final entity = model.toEntity();
          expect(entity.status, entry.value, reason: 'Failed for status: ${entry.key}');
        }
      });

      test('should correctly parse payment mode', () {
        final testCases = {
          'platform': PaymentMode.platform,
          'on_delivery': PaymentMode.onDelivery,
          'PLATFORM': PaymentMode.platform, // case insensitive
          'unknown': PaymentMode.platform, // default
        };

        for (final entry in testCases.entries) {
          final model = OrderModel(
            id: 1,
            reference: 'ORD-001',
            status: 'pending',
            paymentMode: entry.key,
            totalAmount: 1000.0,
            deliveryAddress: 'Test',
            createdAt: '2024-01-15T10:00:00.000Z',
          );

          final entity = model.toEntity();
          expect(entity.paymentMode, entry.value, reason: 'Failed for mode: ${entry.key}');
        }
      });

      test('should correctly convert dates', () {
        // Arrange
        final model = OrderModel(
          id: 1,
          reference: 'ORD-001',
          status: 'delivered',
          paymentMode: 'platform',
          totalAmount: 1000.0,
          deliveryAddress: 'Test',
          createdAt: '2024-01-15T10:00:00.000Z',
          confirmedAt: '2024-01-15T11:00:00.000Z',
          paidAt: '2024-01-15T11:30:00.000Z',
          deliveredAt: '2024-01-15T14:00:00.000Z',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.createdAt, isNotNull);
        expect(entity.confirmedAt, isNotNull);
        expect(entity.paidAt, isNotNull);
        expect(entity.deliveredAt, isNotNull);
        expect(entity.cancelledAt, isNull);
      });
    });
  });

  group('PharmacyBasicModel', () {
    test('should correctly parse from JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'Pharmacie Test',
        'phone': '+24177123456',
        'address': '123 Rue Test',
      };

      // Act
      final model = PharmacyBasicModel.fromJson(json);

      // Assert
      expect(model.id, 1);
      expect(model.name, 'Pharmacie Test');
      expect(model.phone, '+24177123456');
      expect(model.address, '123 Rue Test');
    });

    test('should handle optional fields', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'Pharmacie Test',
      };

      // Act
      final model = PharmacyBasicModel.fromJson(json);

      // Assert
      expect(model.id, 1);
      expect(model.name, 'Pharmacie Test');
      expect(model.phone, isNull);
      expect(model.address, isNull);
    });

    test('should correctly serialize to JSON', () {
      // Arrange
      const model = PharmacyBasicModel(
        id: 1,
        name: 'Pharmacie Test',
        phone: '+24177123456',
        address: '123 Rue Test',
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['name'], 'Pharmacie Test');
      expect(json['phone'], '+24177123456');
      expect(json['address'], '123 Rue Test');
    });
  });

  group('OrderItemModel', () {
    test('should correctly parse from JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'product_id': 10,
        'name': 'Paracetamol 500mg',
        'quantity': 2,
        'unit_price': 1500.0,
        'total_price': 3000.0,
      };

      // Act
      final model = OrderItemModel.fromJson(json);

      // Assert
      expect(model.id, 1);
      expect(model.productId, 10);
      expect(model.name, 'Paracetamol 500mg');
      expect(model.quantity, 2);
      expect(model.unitPrice, 1500.0);
      expect(model.totalPrice, 3000.0);
    });

    test('should correctly convert to entity', () {
      // Arrange
      const model = OrderItemModel(
        id: 1,
        productId: 10,
        name: 'Paracetamol 500mg',
        quantity: 2,
        unitPrice: 1500.0,
        totalPrice: 3000.0,
      );

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity.id, 1);
      expect(entity.productId, 10);
      expect(entity.name, 'Paracetamol 500mg');
      expect(entity.quantity, 2);
      expect(entity.unitPrice, 1500.0);
      expect(entity.totalPrice, 3000.0);
    });

    test('should handle string prices from API', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'Paracetamol',
        'quantity': 2,
        'unit_price': '1500.00',
        'total_price': '3000.00',
      };

      // Act
      final model = OrderItemModel.fromJson(json);

      // Assert
      expect(model.unitPrice, 1500.0);
      expect(model.totalPrice, 3000.0);
    });
  });

  group('DeliveryAddressModel', () {
    test('should correctly parse from JSON', () {
      // Arrange
      final json = {
        'address': '123 Rue Test',
        'city': 'Libreville',
        'latitude': 0.4162,
        'longitude': 9.4673,
        'phone': '+24177123456',
      };

      // Act
      final model = DeliveryAddressModel.fromJson(json);

      // Assert
      expect(model.address, '123 Rue Test');
      expect(model.city, 'Libreville');
      expect(model.latitude, 0.4162);
      expect(model.longitude, 9.4673);
      expect(model.phone, '+24177123456');
    });

    test('should correctly convert to entity', () {
      // Arrange
      const model = DeliveryAddressModel(
        address: '123 Rue Test',
        city: 'Libreville',
        latitude: 0.4162,
        longitude: 9.4673,
        phone: '+24177123456',
      );

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity.address, '123 Rue Test');
      expect(entity.city, 'Libreville');
      expect(entity.latitude, 0.4162);
      expect(entity.longitude, 9.4673);
      expect(entity.phone, '+24177123456');
    });
  });
}
