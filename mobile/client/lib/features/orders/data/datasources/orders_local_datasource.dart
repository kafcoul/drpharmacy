import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';

class OrdersLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _cachedOrdersKey = 'cached_orders';
  static const String _cachedOrderPrefix = 'cached_order_';

  OrdersLocalDataSource(this.sharedPreferences);

  /// Cache orders list
  Future<void> cacheOrders(List<OrderModel> orders) async {
    final ordersJson = orders.map((order) => order.toJson()).toList();
    await sharedPreferences.setString(
      _cachedOrdersKey,
      jsonEncode(ordersJson),
    );
  }

  /// Get cached orders list
  List<OrderModel>? getCachedOrders() {
    final ordersString = sharedPreferences.getString(_cachedOrdersKey);
    if (ordersString == null) return null;

    final List<dynamic> ordersJson = jsonDecode(ordersString) as List<dynamic>;
    return ordersJson
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Cache a single order
  Future<void> cacheOrder(OrderModel order) async {
    await sharedPreferences.setString(
      '$_cachedOrderPrefix${order.id}',
      jsonEncode(order.toJson()),
    );
  }

  /// Get cached order by ID
  OrderModel? getCachedOrder(int orderId) {
    final orderString = sharedPreferences.getString('$_cachedOrderPrefix$orderId');
    if (orderString == null) return null;

    return OrderModel.fromJson(jsonDecode(orderString) as Map<String, dynamic>);
  }

  /// Clear all cached orders
  Future<void> clearCache() async {
    await sharedPreferences.remove(_cachedOrdersKey);
    
    // Remove individual order caches
    final keys = sharedPreferences.getKeys();
    for (final key in keys) {
      if (key.startsWith(_cachedOrderPrefix)) {
        await sharedPreferences.remove(key);
      }
    }
  }
}
