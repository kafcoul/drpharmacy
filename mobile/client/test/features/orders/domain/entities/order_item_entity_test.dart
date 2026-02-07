import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/orders/domain/entities/order_item_entity.dart';

void main() {
  group('OrderItemEntity', () {
    const tOrderItem = OrderItemEntity(
      id: 1,
      productId: 100,
      name: 'Doliprane 1000mg',
      quantity: 2,
      unitPrice: 1500.0,
      totalPrice: 3000.0,
    );

    group('Constructor', () {
      test('should create a valid OrderItemEntity with all required fields', () {
        const item = OrderItemEntity(
          name: 'Test Product',
          quantity: 1,
          unitPrice: 1000.0,
          totalPrice: 1000.0,
        );

        expect(item.name, 'Test Product');
        expect(item.quantity, 1);
        expect(item.unitPrice, 1000.0);
        expect(item.totalPrice, 1000.0);
      });

      test('should have null optional fields by default', () {
        const item = OrderItemEntity(
          name: 'Test',
          quantity: 1,
          unitPrice: 500.0,
          totalPrice: 500.0,
        );

        expect(item.id, isNull);
        expect(item.productId, isNull);
      });

      test('should create entity with all fields', () {
        expect(tOrderItem.id, 1);
        expect(tOrderItem.productId, 100);
        expect(tOrderItem.name, 'Doliprane 1000mg');
        expect(tOrderItem.quantity, 2);
        expect(tOrderItem.unitPrice, 1500.0);
        expect(tOrderItem.totalPrice, 3000.0);
      });
    });

    group('Equatable', () {
      test('should return true when comparing equal entities', () {
        const item1 = OrderItemEntity(
          id: 1,
          productId: 100,
          name: 'Product',
          quantity: 2,
          unitPrice: 1000.0,
          totalPrice: 2000.0,
        );

        const item2 = OrderItemEntity(
          id: 1,
          productId: 100,
          name: 'Product',
          quantity: 2,
          unitPrice: 1000.0,
          totalPrice: 2000.0,
        );

        expect(item1, item2);
      });

      test('should return false when ids are different', () {
        const item1 = OrderItemEntity(
          id: 1,
          name: 'Product',
          quantity: 2,
          unitPrice: 1000.0,
          totalPrice: 2000.0,
        );

        const item2 = OrderItemEntity(
          id: 2,
          name: 'Product',
          quantity: 2,
          unitPrice: 1000.0,
          totalPrice: 2000.0,
        );

        expect(item1, isNot(item2));
      });

      test('should return false when names are different', () {
        const item1 = OrderItemEntity(
          name: 'Product A',
          quantity: 2,
          unitPrice: 1000.0,
          totalPrice: 2000.0,
        );

        const item2 = OrderItemEntity(
          name: 'Product B',
          quantity: 2,
          unitPrice: 1000.0,
          totalPrice: 2000.0,
        );

        expect(item1, isNot(item2));
      });

      test('should return false when quantities are different', () {
        const item1 = OrderItemEntity(
          name: 'Product',
          quantity: 2,
          unitPrice: 1000.0,
          totalPrice: 2000.0,
        );

        const item2 = OrderItemEntity(
          name: 'Product',
          quantity: 3,
          unitPrice: 1000.0,
          totalPrice: 3000.0,
        );

        expect(item1, isNot(item2));
      });

      test('should return false when prices are different', () {
        const item1 = OrderItemEntity(
          name: 'Product',
          quantity: 2,
          unitPrice: 1000.0,
          totalPrice: 2000.0,
        );

        const item2 = OrderItemEntity(
          name: 'Product',
          quantity: 2,
          unitPrice: 1500.0,
          totalPrice: 3000.0,
        );

        expect(item1, isNot(item2));
      });

      test('should have same hashCode for equal entities', () {
        const item1 = OrderItemEntity(
          id: 1,
          name: 'Product',
          quantity: 2,
          unitPrice: 1000.0,
          totalPrice: 2000.0,
        );

        const item2 = OrderItemEntity(
          id: 1,
          name: 'Product',
          quantity: 2,
          unitPrice: 1000.0,
          totalPrice: 2000.0,
        );

        expect(item1.hashCode, item2.hashCode);
      });
    });

    group('props', () {
      test('should contain all fields in correct order', () {
        expect(tOrderItem.props, [
          1,         // id
          100,       // productId
          'Doliprane 1000mg',  // name
          2,         // quantity
          1500.0,    // unitPrice
          3000.0,    // totalPrice
        ]);
      });

      test('should include null values when optional fields are null', () {
        const item = OrderItemEntity(
          name: 'Product',
          quantity: 1,
          unitPrice: 500.0,
          totalPrice: 500.0,
        );

        expect(item.props[0], isNull); // id
        expect(item.props[1], isNull); // productId
      });
    });

    group('Edge cases', () {
      test('should handle zero quantity', () {
        const item = OrderItemEntity(
          name: 'Product',
          quantity: 0,
          unitPrice: 1000.0,
          totalPrice: 0.0,
        );

        expect(item.quantity, 0);
        expect(item.totalPrice, 0.0);
      });

      test('should handle zero prices', () {
        const item = OrderItemEntity(
          name: 'Free Sample',
          quantity: 1,
          unitPrice: 0.0,
          totalPrice: 0.0,
        );

        expect(item.unitPrice, 0.0);
        expect(item.totalPrice, 0.0);
      });

      test('should handle large quantities', () {
        const item = OrderItemEntity(
          name: 'Bulk Product',
          quantity: 999,
          unitPrice: 100.0,
          totalPrice: 99900.0,
        );

        expect(item.quantity, 999);
        expect(item.totalPrice, 99900.0);
      });

      test('should handle decimal prices', () {
        const item = OrderItemEntity(
          name: 'Product',
          quantity: 3,
          unitPrice: 1250.50,
          totalPrice: 3751.50,
        );

        expect(item.unitPrice, 1250.50);
        expect(item.totalPrice, 3751.50);
      });

      test('should handle very long product names', () {
        const item = OrderItemEntity(
          name: 'Super Long Product Name With Many Words And Details About The Medication',
          quantity: 1,
          unitPrice: 1000.0,
          totalPrice: 1000.0,
        );

        expect(item.name.length, greaterThan(50));
      });

      test('should handle only id without productId', () {
        const item = OrderItemEntity(
          id: 1,
          name: 'Product',
          quantity: 1,
          unitPrice: 500.0,
          totalPrice: 500.0,
        );

        expect(item.id, 1);
        expect(item.productId, isNull);
      });

      test('should handle only productId without id', () {
        const item = OrderItemEntity(
          productId: 100,
          name: 'Product',
          quantity: 1,
          unitPrice: 500.0,
          totalPrice: 500.0,
        );

        expect(item.id, isNull);
        expect(item.productId, 100);
      });
    });
  });
}
