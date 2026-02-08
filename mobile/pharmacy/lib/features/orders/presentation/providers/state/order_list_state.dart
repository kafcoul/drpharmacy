import '../../../domain/entities/order_entity.dart';

enum OrderStatus { initial, loading, loaded, error }

class OrderListState {
  final OrderStatus status;
  final List<OrderEntity> orders;
  final String? errorMessage;
  final String activeFilter; // 'all', 'pending', 'confirmed', 'ready', 'in_delivery', 'delivered', 'cancelled'

  const OrderListState({
    this.status = OrderStatus.initial,
    this.orders = const [],
    this.errorMessage,
    this.activeFilter = 'pending',
  });

  OrderListState copyWith({
    OrderStatus? status,
    List<OrderEntity>? orders,
    String? errorMessage,
    String? activeFilter,
  }) {
    return OrderListState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}
