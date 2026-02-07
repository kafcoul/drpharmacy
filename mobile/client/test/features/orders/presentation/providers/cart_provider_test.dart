import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/orders/presentation/providers/cart_provider.dart';
import 'package:drpharma_client/features/orders/presentation/providers/cart_state.dart';

void main() {
  group('CartProvider Tests', () {
    test('cartProvider should be defined', () {
      expect(cartProvider, isNotNull);
    });

    test('cartProvider should be a StateNotifierProvider', () {
      expect(cartProvider, isA<StateNotifierProvider>());
    });

    test('CartState should have initial state', () {
      const state = CartState.initial();
      expect(state.items, isEmpty);
      expect(state.total, 0);
    });

    test('CartState should be empty initially', () {
      const state = CartState.initial();
      expect(state.isEmpty, true);
    });
  });
}
