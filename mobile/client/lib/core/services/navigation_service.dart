import 'package:flutter/material.dart';

/// Global navigation key for accessing navigation from anywhere
/// Including background notification handlers
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Navigation service for handling deep links and notification navigation
class NavigationService {
  /// Navigate to order details
  static Future<void> navigateToOrderDetails(int orderId) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Import order details page dynamically to avoid circular dependency
    // For now, we'll use a simple named route approach
    Navigator.of(context).pushNamed(
      '/order-details',
      arguments: orderId,
    );
  }

  /// Navigate to orders list
  static Future<void> navigateToOrdersList() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    Navigator.of(context).pushNamed('/orders');
  }

  /// Navigate to notifications
  static Future<void> navigateToNotifications() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    Navigator.of(context).pushNamed('/notifications');
  }

  /// Handle notification tap based on type
  static Future<void> handleNotificationTap({
    required String? type,
    required Map<String, dynamic> data,
  }) async {
    if (type == null) return;

    switch (type) {
      case 'order_status':
      case 'payment_confirmed':
      case 'delivery_assigned':
      case 'order_delivered':
        final orderId = data['order_id'];
        if (orderId != null) {
          await navigateToOrderDetails(
            orderId is int ? orderId : int.parse(orderId.toString()),
          );
        }
        break;

      case 'new_order':
        await navigateToOrdersList();
        break;

      default:
        await navigateToNotifications();
    }
  }
}
