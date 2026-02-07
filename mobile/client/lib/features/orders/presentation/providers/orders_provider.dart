import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/providers.dart';
import 'orders_state.dart';
import 'orders_notifier.dart';

final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((
  ref,
) {
  return OrdersNotifier(
    getOrdersUseCase: ref.watch(getOrdersUseCaseProvider),
    getOrderDetailsUseCase: ref.watch(getOrderDetailsUseCaseProvider),
    createOrderUseCase: ref.watch(createOrderUseCaseProvider),
    cancelOrderUseCase: ref.watch(cancelOrderUseCaseProvider),
    initiatePaymentUseCase: ref.watch(initiatePaymentUseCaseProvider),
  );
});
