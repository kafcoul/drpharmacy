import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/entities/delivery_address_entity.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../domain/usecases/get_order_details_usecase.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/cancel_order_usecase.dart';
import '../../domain/usecases/initiate_payment_usecase.dart';
import 'orders_state.dart';

class OrdersNotifier extends StateNotifier<OrdersState> {
  final GetOrdersUseCase getOrdersUseCase;
  final GetOrderDetailsUseCase getOrderDetailsUseCase;
  final CreateOrderUseCase createOrderUseCase;
  final CancelOrderUseCase cancelOrderUseCase;
  final InitiatePaymentUseCase initiatePaymentUseCase;

  OrdersNotifier({
    required this.getOrdersUseCase,
    required this.getOrderDetailsUseCase,
    required this.createOrderUseCase,
    required this.cancelOrderUseCase,
    required this.initiatePaymentUseCase,
  }) : super(const OrdersState.initial());

  // Load orders list
  Future<void> loadOrders({String? status}) async {
    state = state.copyWith(status: OrdersStatus.loading);

    final result = await getOrdersUseCase(status: status);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: OrdersStatus.error,
          errorMessage: failure.message,
        );
      },
      (orders) {
        state = state.copyWith(
          status: OrdersStatus.loaded,
          orders: orders,
          errorMessage: null,
        );
      },
    );
  }

  // Load order details
  Future<void> loadOrderDetails(int orderId) async {
    state = state.copyWith(status: OrdersStatus.loading);

    final result = await getOrderDetailsUseCase(orderId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: OrdersStatus.error,
          errorMessage: failure.message,
        );
      },
      (order) {
        state = state.copyWith(
          status: OrdersStatus.loaded,
          selectedOrder: order,
          errorMessage: null,
        );
      },
    );
  }

  // Create order
  Future<void> createOrder({
    required int pharmacyId,
    required List<OrderItemEntity> items,
    required DeliveryAddressEntity deliveryAddress,
    required String paymentMode,
    String? prescriptionImage,
    String? customerNotes,
    int? prescriptionId, // ID de la prescription uploadée via checkout
  }) async {
    state = state.copyWith(status: OrdersStatus.loading);

    final result = await createOrderUseCase(
      pharmacyId: pharmacyId,
      items: items,
      deliveryAddress: deliveryAddress,
      paymentMode: paymentMode,
      prescriptionImage: prescriptionImage,
      customerNotes: customerNotes,
      prescriptionId: prescriptionId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: OrdersStatus.error,
          errorMessage: failure.message,
        );
      },
      (order) {
        state = state.copyWith(
          status: OrdersStatus.loaded,
          createdOrder: order,
          orders: [order, ...state.orders],
          errorMessage: null,
        );
      },
    );
  }

  // Cancel order
  Future<void> cancelOrder(int orderId, String reason) async {
    state = state.copyWith(status: OrdersStatus.loading);

    final result = await cancelOrderUseCase(orderId, reason);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: OrdersStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        // Refresh orders list
        loadOrders();
      },
    );
  }

  // Initiate payment
  Future<Map<String, dynamic>?> initiatePayment({
    required int orderId,
    required String provider,
  }) async {
    // We don't necessarily update global state status here as it might interfere with order list
    // or we can set it to loading.

    final result = await initiatePaymentUseCase(
      orderId: orderId,
      provider: provider,
    );

    return result.fold((failure) {
      state = state.copyWith(
        status: OrdersStatus.error,
        errorMessage: failure.message,
      );
      return null;
    }, (data) => data);
  }

  // Clear error
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(
        errorMessage: null,
        status: state.orders.isEmpty
            ? OrdersStatus.initial
            : OrdersStatus.loaded,
      );
    }
  }
}
