import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/features/orders/presentation/providers/orders_state.dart';
import 'package:drpharma_client/features/orders/domain/entities/order_entity.dart';
import 'package:drpharma_client/features/orders/domain/entities/delivery_address_entity.dart';

void main() {
  group('OrdersStatus', () {
    test('should have all expected values', () {
      expect(OrdersStatus.values.length, 4);
      expect(OrdersStatus.values, contains(OrdersStatus.initial));
      expect(OrdersStatus.values, contains(OrdersStatus.loading));
      expect(OrdersStatus.values, contains(OrdersStatus.loaded));
      expect(OrdersStatus.values, contains(OrdersStatus.error));
    });
  });

  group('OrdersState', () {
    late OrderEntity testOrder;

    setUp(() {
      testOrder = OrderEntity(
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
        ),
        pharmacyId: 1,
        pharmacyName: 'Pharmacie Test',
        items: const [],
        createdAt: DateTime(2024, 1, 15),
      );
    });

    group('Constructor', () {
      test('should create OrdersState with required fields', () {
        // Act
        const state = OrdersState(
          status: OrdersStatus.initial,
          orders: [],
        );

        // Assert
        expect(state.status, OrdersStatus.initial);
        expect(state.orders, isEmpty);
        expect(state.selectedOrder, isNull);
        expect(state.createdOrder, isNull);
        expect(state.errorMessage, isNull);
      });

      test('should create OrdersState with all fields', () {
        // Act
        final state = OrdersState(
          status: OrdersStatus.loaded,
          orders: [testOrder],
          selectedOrder: testOrder,
          createdOrder: testOrder,
          errorMessage: null,
        );

        // Assert
        expect(state.status, OrdersStatus.loaded);
        expect(state.orders.length, 1);
        expect(state.selectedOrder, testOrder);
        expect(state.createdOrder, testOrder);
      });
    });

    group('OrdersState.initial', () {
      test('should create initial state with default values', () {
        // Act
        const state = OrdersState.initial();

        // Assert
        expect(state.status, OrdersStatus.initial);
        expect(state.orders, isEmpty);
        expect(state.selectedOrder, isNull);
        expect(state.createdOrder, isNull);
        expect(state.errorMessage, isNull);
      });
    });

    group('copyWith', () {
      test('should copy with new status', () {
        // Arrange
        const initialState = OrdersState.initial();

        // Act
        final newState = initialState.copyWith(status: OrdersStatus.loading);

        // Assert
        expect(newState.status, OrdersStatus.loading);
        expect(newState.orders, isEmpty);
      });

      test('should copy with new orders list', () {
        // Arrange
        const initialState = OrdersState.initial();

        // Act
        final newState = initialState.copyWith(orders: [testOrder]);

        // Assert
        expect(newState.orders.length, 1);
        expect(newState.orders.first, testOrder);
      });

      test('should copy with selected order', () {
        // Arrange
        const initialState = OrdersState.initial();

        // Act
        final newState = initialState.copyWith(selectedOrder: testOrder);

        // Assert
        expect(newState.selectedOrder, testOrder);
      });

      test('should copy with created order', () {
        // Arrange
        const initialState = OrdersState.initial();

        // Act
        final newState = initialState.copyWith(createdOrder: testOrder);

        // Assert
        expect(newState.createdOrder, testOrder);
      });

      test('should copy with error message', () {
        // Arrange
        const initialState = OrdersState.initial();

        // Act
        final newState = initialState.copyWith(errorMessage: 'Failed to load');

        // Assert
        expect(newState.errorMessage, 'Failed to load');
      });

      test('should clear error message when not provided', () {
        // Arrange
        final errorState = const OrdersState.initial().copyWith(
          errorMessage: 'Error',
        );

        // Act
        final newState = errorState.copyWith(status: OrdersStatus.loaded);

        // Assert
        expect(newState.errorMessage, isNull);
      });

      test('should preserve values when not specified', () {
        // Arrange
        final state = OrdersState(
          status: OrdersStatus.loaded,
          orders: [testOrder],
          selectedOrder: testOrder,
        );

        // Act
        final newState = state.copyWith();

        // Assert
        expect(newState.status, OrdersStatus.loaded);
        expect(newState.orders.length, 1);
        expect(newState.selectedOrder, testOrder);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties match', () {
        // Arrange
        const state1 = OrdersState.initial();
        const state2 = OrdersState.initial();

        // Assert
        expect(state1, equals(state2));
      });

      test('should not be equal when status differs', () {
        // Arrange
        const state1 = OrdersState.initial();
        final state2 = const OrdersState.initial().copyWith(
          status: OrdersStatus.loading,
        );

        // Assert
        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when orders differ', () {
        // Arrange
        const state1 = OrdersState.initial();
        final state2 = const OrdersState.initial().copyWith(
          orders: [testOrder],
        );

        // Assert
        expect(state1, isNot(equals(state2)));
      });

      test('should have props with all fields', () {
        // Arrange
        const state = OrdersState.initial();

        // Assert
        expect(state.props.length, 5);
      });
    });
  });

  group('OrderStatus enum', () {
    test('should have all expected values', () {
      expect(OrderStatus.values.length, greaterThanOrEqualTo(4));
      expect(OrderStatus.values, contains(OrderStatus.pending));
      expect(OrderStatus.values, contains(OrderStatus.confirmed));
      expect(OrderStatus.values, contains(OrderStatus.delivered));
      expect(OrderStatus.values, contains(OrderStatus.cancelled));
    });
  });
}
