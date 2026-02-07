import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/orders/data/models/order_item_model.dart';
import 'package:drpharma_client/features/orders/domain/entities/order_item_entity.dart';

void main() {
  group('OrderItemModel', () {
    group('creation', () {
      test('should create with all fields', () {
        const model = OrderItemModel(
          id: 1,
          productId: 100,
          name: 'Paracetamol 500mg',
          quantity: 2,
          unitPrice: 2500.0,
          totalPrice: 5000.0,
        );

        expect(model.id, equals(1));
        expect(model.productId, equals(100));
        expect(model.name, equals('Paracetamol 500mg'));
        expect(model.quantity, equals(2));
        expect(model.unitPrice, equals(2500.0));
        expect(model.totalPrice, equals(5000.0));
      });

      test('should create with null id and productId', () {
        const model = OrderItemModel(
          id: null,
          productId: null,
          name: 'Test Product',
          quantity: 1,
          unitPrice: 1000.0,
          totalPrice: 1000.0,
        );

        expect(model.id, isNull);
        expect(model.productId, isNull);
      });

      test('should create with only productId', () {
        const model = OrderItemModel(
          productId: 50,
          name: 'Product',
          quantity: 3,
          unitPrice: 500.0,
          totalPrice: 1500.0,
        );

        expect(model.productId, equals(50));
        expect(model.id, isNull);
      });
    });

    group('fromJson', () {
      test('should parse complete JSON', () {
        final json = {
          'id': 1,
          'product_id': 100,
          'name': 'Aspirine 100mg',
          'quantity': 3,
          'unit_price': 1500.0,
          'total_price': 4500.0,
        };

        final model = OrderItemModel.fromJson(json);

        expect(model.id, equals(1));
        expect(model.productId, equals(100));
        expect(model.name, equals('Aspirine 100mg'));
        expect(model.quantity, equals(3));
        expect(model.unitPrice, equals(1500.0));
        expect(model.totalPrice, equals(4500.0));
      });

      test('should parse JSON with product_name instead of name', () {
        final json = {
          'id': 2,
          'product_id': 200,
          'product_name': 'Ibuprofen 400mg',
          'quantity': 2,
          'unit_price': 3000.0,
          'total_price': 6000.0,
        };

        final model = OrderItemModel.fromJson(json);

        expect(model.name, equals('Ibuprofen 400mg'));
      });

      test('should prefer name over product_name', () {
        final json = {
          'id': 3,
          'product_id': 300,
          'name': 'Name Field',
          'product_name': 'Product Name Field',
          'quantity': 1,
          'unit_price': 1000.0,
          'total_price': 1000.0,
        };

        final model = OrderItemModel.fromJson(json);

        expect(model.name, equals('Name Field'));
      });

      test('should parse string unit_price', () {
        final json = {
          'id': 4,
          'product_id': 400,
          'name': 'Test',
          'quantity': 1,
          'unit_price': '2500.00',
          'total_price': 2500.0,
        };

        final model = OrderItemModel.fromJson(json);

        expect(model.unitPrice, equals(2500.0));
      });

      test('should parse string total_price', () {
        final json = {
          'id': 5,
          'product_id': 500,
          'name': 'Test',
          'quantity': 2,
          'unit_price': 2500.0,
          'total_price': '5000.00',
        };

        final model = OrderItemModel.fromJson(json);

        expect(model.totalPrice, equals(5000.0));
      });

      test('should parse both string prices', () {
        final json = {
          'id': 6,
          'product_id': 600,
          'name': 'Test',
          'quantity': 3,
          'unit_price': '1000.50',
          'total_price': '3001.50',
        };

        final model = OrderItemModel.fromJson(json);

        expect(model.unitPrice, equals(1000.50));
        expect(model.totalPrice, equals(3001.50));
      });

      test('should handle invalid string price as 0', () {
        final json = {
          'id': 7,
          'product_id': 700,
          'name': 'Test',
          'quantity': 1,
          'unit_price': 'invalid',
          'total_price': 'invalid',
        };

        final model = OrderItemModel.fromJson(json);

        expect(model.unitPrice, equals(0.0));
        expect(model.totalPrice, equals(0.0));
      });

      test('should parse JSON with null id and product_id', () {
        final json = {
          'name': 'Minimal Item',
          'quantity': 1,
          'unit_price': 500.0,
          'total_price': 500.0,
        };

        final model = OrderItemModel.fromJson(json);

        expect(model.id, isNull);
        expect(model.productId, isNull);
        expect(model.name, equals('Minimal Item'));
      });
    });

    group('toJson', () {
      test('should serialize for API with price instead of unit_price', () {
        const model = OrderItemModel(
          id: 1,
          productId: 100,
          name: 'Test Product',
          quantity: 2,
          unitPrice: 2500.0,
          totalPrice: 5000.0,
        );

        final json = model.toJson();

        expect(json['id'], equals(100)); // uses productId
        expect(json['name'], equals('Test Product'));
        expect(json['quantity'], equals(2));
        expect(json['price'], equals(2500.0)); // uses 'price' for API
        expect(json.containsKey('unit_price'), isFalse);
        expect(json.containsKey('total_price'), isFalse);
      });

      test('should use id when productId is null', () {
        const model = OrderItemModel(
          id: 50,
          productId: null,
          name: 'Test',
          quantity: 1,
          unitPrice: 1000.0,
          totalPrice: 1000.0,
        );

        final json = model.toJson();

        expect(json['id'], equals(50));
      });

      test('should handle both null ids', () {
        const model = OrderItemModel(
          id: null,
          productId: null,
          name: 'Test',
          quantity: 1,
          unitPrice: 1000.0,
          totalPrice: 1000.0,
        );

        final json = model.toJson();

        expect(json['id'], isNull);
      });
    });

    group('toEntity', () {
      test('should convert to entity with all fields', () {
        const model = OrderItemModel(
          id: 1,
          productId: 100,
          name: 'Paracetamol',
          quantity: 2,
          unitPrice: 2500.0,
          totalPrice: 5000.0,
        );

        final entity = model.toEntity();

        expect(entity, isA<OrderItemEntity>());
        expect(entity.id, equals(1));
        expect(entity.productId, equals(100));
        expect(entity.name, equals('Paracetamol'));
        expect(entity.quantity, equals(2));
        expect(entity.unitPrice, equals(2500.0));
        expect(entity.totalPrice, equals(5000.0));
      });

      test('should convert to entity with null fields', () {
        const model = OrderItemModel(
          id: null,
          productId: null,
          name: 'Test',
          quantity: 1,
          unitPrice: 500.0,
          totalPrice: 500.0,
        );

        final entity = model.toEntity();

        expect(entity.id, isNull);
        expect(entity.productId, isNull);
      });
    });

    group('fromEntity', () {
      test('should create from entity with all fields', () {
        const entity = OrderItemEntity(
          id: 1,
          productId: 100,
          name: 'Aspirine',
          quantity: 3,
          unitPrice: 1500.0,
          totalPrice: 4500.0,
        );

        final model = OrderItemModel.fromEntity(entity);

        expect(model.id, equals(1));
        expect(model.productId, equals(100));
        expect(model.name, equals('Aspirine'));
        expect(model.quantity, equals(3));
        expect(model.unitPrice, equals(1500.0));
        expect(model.totalPrice, equals(4500.0));
      });

      test('should create from entity with null fields', () {
        const entity = OrderItemEntity(
          id: null,
          productId: null,
          name: 'Minimal',
          quantity: 1,
          unitPrice: 1000.0,
          totalPrice: 1000.0,
        );

        final model = OrderItemModel.fromEntity(entity);

        expect(model.id, isNull);
        expect(model.productId, isNull);
      });
    });

    group('roundtrip entity', () {
      test('toEntity -> fromEntity should preserve data', () {
        const original = OrderItemModel(
          id: 10,
          productId: 200,
          name: 'Roundtrip Product',
          quantity: 5,
          unitPrice: 3000.0,
          totalPrice: 15000.0,
        );

        final entity = original.toEntity();
        final restored = OrderItemModel.fromEntity(entity);

        expect(restored.id, equals(original.id));
        expect(restored.productId, equals(original.productId));
        expect(restored.name, equals(original.name));
        expect(restored.quantity, equals(original.quantity));
        expect(restored.unitPrice, equals(original.unitPrice));
        expect(restored.totalPrice, equals(original.totalPrice));
      });
    });

    group('edge cases', () {
      test('should handle zero quantity', () {
        const model = OrderItemModel(
          name: 'Zero Qty',
          quantity: 0,
          unitPrice: 1000.0,
          totalPrice: 0.0,
        );

        expect(model.quantity, equals(0));
        expect(model.totalPrice, equals(0.0));
      });

      test('should handle large quantities', () {
        const model = OrderItemModel(
          name: 'Large Qty',
          quantity: 1000,
          unitPrice: 100.0,
          totalPrice: 100000.0,
        );

        expect(model.quantity, equals(1000));
        expect(model.totalPrice, equals(100000.0));
      });

      test('should handle decimal prices', () {
        const model = OrderItemModel(
          name: 'Decimal Price',
          quantity: 1,
          unitPrice: 1234.56,
          totalPrice: 1234.56,
        );

        expect(model.unitPrice, equals(1234.56));
        expect(model.totalPrice, equals(1234.56));
      });

      test('should handle long product names', () {
        const longName = 'Very Long Product Name With Many Words And Details About The Medication';
        const model = OrderItemModel(
          name: longName,
          quantity: 1,
          unitPrice: 1000.0,
          totalPrice: 1000.0,
        );

        expect(model.name, equals(longName));
      });
    });
  });
}
