import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/providers.dart';
import 'cart_state.dart';
import 'cart_notifier.dart';

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return CartNotifier(sharedPreferences);
});
