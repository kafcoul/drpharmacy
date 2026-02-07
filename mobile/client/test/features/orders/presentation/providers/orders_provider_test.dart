import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/orders/presentation/providers/orders_provider.dart';
import 'package:drpharma_client/features/orders/presentation/providers/orders_state.dart';

void main() {
  group('OrdersProvider Tests', () {
    test('ordersProvider should be defined', () {
      expect(ordersProvider, isNotNull);
    });

    test('ordersProvider should be a StateNotifierProvider', () {
      expect(ordersProvider, isA<StateNotifierProvider>());
    });

    test('OrdersState should have initial state', () {
      const state = OrdersState.initial();
      expect(state.isLoading, false);
      expect(state.orders, isEmpty);
      expect(state.error, isNull);
    });

    test('OrdersState should have loading state', () {
      const state = OrdersState.loading();
      expect(state.isLoading, true);
    });

    test('OrdersState should have error state', () {
      const state = OrdersState.error('Test error');
      expect(state.error, 'Test error');
    });
  });
}
