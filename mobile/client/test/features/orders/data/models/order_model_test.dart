import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/features/orders/data/models/order_model.dart';
import 'package:drpharma_client/features/orders/data/models/order_item_model.dart';
import 'package:drpharma_client/features/orders/domain/entities/order_entity.dart';

void main() {
  group('OrderModel', () {
    group('fromJson', () {
      test('should parse complete order data', () {
        // Arrange
        final json = {
          'id': 1,
          'reference': 'ORD-2026-001',
          'delivery_code': 'ABC123',
          'status': 'pending',
          'payment_status': 'pending',
          'payment_mode': 'on_delivery',
          'pharmacy_id': 1,
          'pharmacy': {
            'id': 1,
            'name': 'Pharmacie du Centre',
            'phone': '+24107123456',
            'address': 'Libreville',
          },
          'items': [
            {
              'id': 1,
              'product_id': 1,
              'name': 'Paracétamol 500mg',
              'quantity': 2,
              'unit_price': 1500.0,
              'total_price': 3000.0,
            },
          ],
          'subtotal': 3000.0,
          'delivery_fee': 500.0,
          'total_amount': 3500.0,
          'currency': 'XOF',
          'delivery_address': '123 Rue Test, Libreville',
          'delivery_city': 'Libreville',
          'delivery_latitude': 0.4162,
          'delivery_longitude': 9.4673,
          'customer_phone': '+24107123456',
          'customer_notes': 'Merci de livrer avant 18h',
          'created_at': '2026-02-01T10:00:00Z',
          'confirmed_at': '2026-02-01T10:30:00Z',
        };

        // Act
        final model = OrderModel.fromJson(json);

        // Assert
        expect(model.id, 1);
        expect(model.reference, 'ORD-2026-001');
        expect(model.deliveryCode, 'ABC123');
        expect(model.status, 'pending');
        expect(model.paymentStatus, 'pending');
        expect(model.paymentMode, 'on_delivery');
        expect(model.pharmacy?.name, 'Pharmacie du Centre');
        expect(model.items.length, 1);
        expect(model.items.first.name, 'Paracétamol 500mg');
        expect(model.subtotal, 3000.0);
        expect(model.deliveryFee, 500.0);
        expect(model.totalAmount, 3500.0);
        expect(model.deliveryAddress, '123 Rue Test, Libreville');
        expect(model.customerNotes, 'Merci de livrer avant 18h');
      });

      test('should parse order with string amounts', () {
        // Arrange - API sometimes returns amounts as strings
        final json = {
          'id': 2,
          'reference': 'ORD-2026-002',
          'status': 'confirmed',
          'payment_status': 'paid',
          'payment_mode': 'platform',
          'total_amount': '5000.00',
          'subtotal': '4500.00',
          'delivery_fee': '500.00',
          'delivery_address': 'Test',
          'created_at': '2026-02-01T10:00:00Z',
          'items': [],
        };

        // Act
        final model = OrderModel.fromJson(json);

        // Assert
        expect(model.totalAmount, 5000.0);
        expect(model.subtotal, 4500.0);
        expect(model.deliveryFee, 500.0);
      });

      test('should parse minimal order data', () {
        // Arrange
        final json = {
          'id': 3,
          'reference': 'ORD-003',
          'status': 'pending',
          'payment_mode': 'on_delivery',
          'total_amount': 1000,
          'delivery_address': 'Test Address',
          'created_at': '2026-02-01T00:00:00Z',
        };

        // Act
        final model = OrderModel.fromJson(json);

        // Assert
        expect(model.id, 3);
        expect(model.reference, 'ORD-003');
        expect(model.paymentStatus, 'pending'); // default
        expect(model.items, isEmpty);
        expect(model.currency, 'XOF'); // default
      });

      test('should handle null pharmacy gracefully', () {
        // Arrange
        final json = {
          'id': 4,
          'reference': 'ORD-004',
          'status': 'pending',
          'payment_mode': 'on_delivery',
          'total_amount': 1000,
          'delivery_address': 'Test',
          'created_at': '2026-02-01T00:00:00Z',
          'pharmacy': null,
        };

        // Act
        final model = OrderModel.fromJson(json);

        // Assert
        expect(model.pharmacy, isNull);
      });
    });

    group('toJson', () {
      test('should serialize order data correctly', () {
        // Arrange
        const pharmacy = PharmacyBasicModel(
          id: 1,
          name: 'Test Pharmacy',
          phone: '+24107000000',
        );

        const item = OrderItemModel(
          id: 1,
          productId: 1,
          name: 'Test Product',
          quantity: 2,
          unitPrice: 1000.0,
          totalPrice: 2000.0,
        );

        final model = OrderModel(
          id: 1,
          reference: 'ORD-001',
          status: 'pending',
          paymentStatus: 'pending',
          paymentMode: 'on_delivery',
          pharmacy: pharmacy,
          items: const [item],
          totalAmount: 2500.0,
          subtotal: 2000.0,
          deliveryFee: 500.0,
          deliveryAddress: 'Test Address',
          createdAt: '2026-02-01T10:00:00Z',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['reference'], 'ORD-001');
        expect(json['status'], 'pending');
        expect(json['payment_mode'], 'on_delivery');
        expect(json['total_amount'], 2500.0);
        expect(json['items'], isA<List>());
      });
    });

    group('toEntity', () {
      test('should convert to OrderEntity correctly', () {
        // Arrange
        const pharmacy = PharmacyBasicModel(
          id: 1,
          name: 'Pharmacie Test',
          phone: '+24107000000',
          address: 'Libreville',
        );

        const item = OrderItemModel(
          id: 1,
          productId: 1,
          name: 'Paracétamol',
          quantity: 2,
          unitPrice: 1500.0,
          totalPrice: 3000.0,
        );

        final model = OrderModel(
          id: 1,
          reference: 'ORD-001',
          deliveryCode: 'XYZ789',
          status: 'confirmed',
          paymentStatus: 'paid',
          paymentMode: 'platform',
          pharmacyId: 1,
          pharmacy: pharmacy,
          items: const [item],
          subtotal: 3000.0,
          deliveryFee: 500.0,
          totalAmount: 3500.0,
          currency: 'XOF',
          deliveryAddress: '123 Rue Test',
          deliveryCity: 'Libreville',
          deliveryLatitude: 0.4162,
          deliveryLongitude: 9.4673,
          customerPhone: '+24107123456',
          customerNotes: 'Test notes',
          createdAt: '2026-02-01T10:00:00Z',
          confirmedAt: '2026-02-01T10:30:00Z',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.id, 1);
        expect(entity.reference, 'ORD-001');
        expect(entity.deliveryCode, 'XYZ789');
        expect(entity.status, OrderStatus.confirmed);
        expect(entity.paymentStatus, 'paid');
        expect(entity.paymentMode, PaymentMode.platform);
        expect(entity.pharmacyId, 1);
        expect(entity.pharmacyName, 'Pharmacie Test');
        expect(entity.pharmacyPhone, '+24107000000');
        expect(entity.items.length, 1);
        expect(entity.items.first.name, 'Paracétamol');
        expect(entity.subtotal, 3000.0);
        expect(entity.deliveryFee, 500.0);
        expect(entity.totalAmount, 3500.0);
        expect(entity.currency, 'XOF');
        expect(entity.deliveryAddress.address, '123 Rue Test');
        expect(entity.deliveryAddress.city, 'Libreville');
        expect(entity.deliveryAddress.latitude, 0.4162);
        expect(entity.customerNotes, 'Test notes');
        expect(entity.confirmedAt, isNotNull);
      });

      test('should parse all order statuses correctly', () {
        // Test each status
        final statuses = {
          'pending': OrderStatus.pending,
          'confirmed': OrderStatus.confirmed,
          'ready': OrderStatus.ready,
          'delivering': OrderStatus.delivering,
          'delivered': OrderStatus.delivered,
          'cancelled': OrderStatus.cancelled,
          'failed': OrderStatus.failed,
        };

        for (final entry in statuses.entries) {
          final model = OrderModel(
            id: 1,
            reference: 'ORD-001',
            status: entry.key,
            paymentMode: 'on_delivery',
            totalAmount: 1000,
            deliveryAddress: 'Test',
            createdAt: '2026-02-01T00:00:00Z',
          );

          final entity = model.toEntity();
          expect(entity.status, entry.value, 
            reason: 'Status ${entry.key} should map to ${entry.value}');
        }
      });

      test('should parse all payment modes correctly', () {
        // Test each payment mode
        final modes = {
          'platform': PaymentMode.platform,
          'on_delivery': PaymentMode.onDelivery,
        };

        for (final entry in modes.entries) {
          final model = OrderModel(
            id: 1,
            reference: 'ORD-001',
            status: 'pending',
            paymentMode: entry.key,
            totalAmount: 1000,
            deliveryAddress: 'Test',
            createdAt: '2026-02-01T00:00:00Z',
          );

          final entity = model.toEntity();
          expect(entity.paymentMode, entry.value,
            reason: 'Payment mode ${entry.key} should map to ${entry.value}');
        }
      });
    });
  });

  group('OrderItemModel', () {
    group('fromJson', () {
      test('should parse item with all fields', () {
        // Arrange
        final json = {
          'id': 1,
          'product_id': 10,
          'name': 'Doliprane 1000mg',
          'quantity': 3,
          'unit_price': 2500.0,
          'total_price': 7500.0,
        };

        // Act
        final model = OrderItemModel.fromJson(json);

        // Assert
        expect(model.id, 1);
        expect(model.productId, 10);
        expect(model.name, 'Doliprane 1000mg');
        expect(model.quantity, 3);
        expect(model.unitPrice, 2500.0);
        expect(model.totalPrice, 7500.0);
      });

      test('should parse item with string prices', () {
        // Arrange
        final json = {
          'id': 2,
          'product_id': 20,
          'name': 'Test',
          'quantity': 1,
          'unit_price': '1500.00',
          'total_price': '1500.00',
        };

        // Act
        final model = OrderItemModel.fromJson(json);

        // Assert
        expect(model.unitPrice, 1500.0);
        expect(model.totalPrice, 1500.0);
      });
    });

    group('toEntity', () {
      test('should convert to OrderItemEntity', () {
        // Arrange
        const model = OrderItemModel(
          id: 1,
          productId: 10,
          name: 'Paracétamol',
          quantity: 2,
          unitPrice: 1000.0,
          totalPrice: 2000.0,
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.id, 1);
        expect(entity.productId, 10);
        expect(entity.name, 'Paracétamol');
        expect(entity.quantity, 2);
        expect(entity.unitPrice, 1000.0);
        expect(entity.totalPrice, 2000.0);
      });
    });
  });

  group('PharmacyBasicModel', () {
    test('should parse from json', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'Pharmacie Test',
        'phone': '+24107000000',
        'address': 'Libreville',
      };

      // Act
      final model = PharmacyBasicModel.fromJson(json);

      // Assert
      expect(model.id, 1);
      expect(model.name, 'Pharmacie Test');
      expect(model.phone, '+24107000000');
      expect(model.address, 'Libreville');
    });

    test('should serialize to json', () {
      // Arrange
      const model = PharmacyBasicModel(
        id: 1,
        name: 'Test',
        phone: '+24107000000',
        address: 'Test Address',
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['name'], 'Test');
      expect(json['phone'], '+24107000000');
      expect(json['address'], 'Test Address');
    });
  });
}
