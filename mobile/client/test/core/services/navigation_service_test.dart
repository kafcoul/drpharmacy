import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/core/services/navigation_service.dart';

void main() {
  group('navigatorKey', () {
    test('should be a GlobalKey<NavigatorState>', () {
      expect(navigatorKey, isA<GlobalKey<NavigatorState>>());
    });

    test('should be the same instance', () {
      final key1 = navigatorKey;
      final key2 = navigatorKey;
      expect(identical(key1, key2), true);
    });
  });

  group('NavigationService', () {
    group('navigateToOrderDetails', () {
      testWidgets('should not throw when context is null', (tester) async {
        // No MaterialApp mounted, so context is null
        await NavigationService.navigateToOrderDetails(1);
        // Should complete without error
      });

      testWidgets('should navigate to order details when context is available', (tester) async {
        bool navigated = false;
        
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            routes: {
              '/': (context) => const Scaffold(body: Text('Home')),
              '/order-details': (context) {
                navigated = true;
                final orderId = ModalRoute.of(context)?.settings.arguments as int?;
                return Scaffold(body: Text('Order $orderId'));
              },
            },
          ),
        );

        await NavigationService.navigateToOrderDetails(42);
        await tester.pumpAndSettle();

        expect(navigated, true);
        expect(find.text('Order 42'), findsOneWidget);
      });
    });

    group('navigateToOrdersList', () {
      testWidgets('should not throw when context is null', (tester) async {
        await NavigationService.navigateToOrdersList();
        // Should complete without error
      });

      testWidgets('should navigate to orders list when context is available', (tester) async {
        bool navigated = false;
        
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            routes: {
              '/': (context) => const Scaffold(body: Text('Home')),
              '/orders': (context) {
                navigated = true;
                return const Scaffold(body: Text('Orders List'));
              },
            },
          ),
        );

        await NavigationService.navigateToOrdersList();
        await tester.pumpAndSettle();

        expect(navigated, true);
        expect(find.text('Orders List'), findsOneWidget);
      });
    });

    group('navigateToNotifications', () {
      testWidgets('should not throw when context is null', (tester) async {
        await NavigationService.navigateToNotifications();
        // Should complete without error
      });

      testWidgets('should navigate to notifications when context is available', (tester) async {
        bool navigated = false;
        
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            routes: {
              '/': (context) => const Scaffold(body: Text('Home')),
              '/notifications': (context) {
                navigated = true;
                return const Scaffold(body: Text('Notifications'));
              },
            },
          ),
        );

        await NavigationService.navigateToNotifications();
        await tester.pumpAndSettle();

        expect(navigated, true);
        expect(find.text('Notifications'), findsOneWidget);
      });
    });

    group('handleNotificationTap', () {
      test('should do nothing when type is null', () async {
        await NavigationService.handleNotificationTap(
          type: null,
          data: {},
        );
        // Should complete without error
      });

      testWidgets('should navigate to order details for order_status type', (tester) async {
        bool navigated = false;
        
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            routes: {
              '/': (context) => const Scaffold(body: Text('Home')),
              '/order-details': (context) {
                navigated = true;
                return const Scaffold(body: Text('Order Details'));
              },
            },
          ),
        );

        await NavigationService.handleNotificationTap(
          type: 'order_status',
          data: {'order_id': 123},
        );
        await tester.pumpAndSettle();

        expect(navigated, true);
      });

      testWidgets('should navigate to order details for payment_confirmed type', (tester) async {
        bool navigated = false;
        
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            routes: {
              '/': (context) => const Scaffold(body: Text('Home')),
              '/order-details': (context) {
                navigated = true;
                return const Scaffold(body: Text('Order Details'));
              },
            },
          ),
        );

        await NavigationService.handleNotificationTap(
          type: 'payment_confirmed',
          data: {'order_id': 456},
        );
        await tester.pumpAndSettle();

        expect(navigated, true);
      });

      testWidgets('should navigate to order details for delivery_assigned type', (tester) async {
        bool navigated = false;
        
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            routes: {
              '/': (context) => const Scaffold(body: Text('Home')),
              '/order-details': (context) {
                navigated = true;
                return const Scaffold(body: Text('Order Details'));
              },
            },
          ),
        );

        await NavigationService.handleNotificationTap(
          type: 'delivery_assigned',
          data: {'order_id': 789},
        );
        await tester.pumpAndSettle();

        expect(navigated, true);
      });

      testWidgets('should navigate to order details for order_delivered type', (tester) async {
        bool navigated = false;
        
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            routes: {
              '/': (context) => const Scaffold(body: Text('Home')),
              '/order-details': (context) {
                navigated = true;
                return const Scaffold(body: Text('Order Details'));
              },
            },
          ),
        );

        await NavigationService.handleNotificationTap(
          type: 'order_delivered',
          data: {'order_id': 999},
        );
        await tester.pumpAndSettle();

        expect(navigated, true);
      });

      testWidgets('should navigate to orders list for new_order type', (tester) async {
        bool navigated = false;
        
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            routes: {
              '/': (context) => const Scaffold(body: Text('Home')),
              '/orders': (context) {
                navigated = true;
                return const Scaffold(body: Text('Orders List'));
              },
            },
          ),
        );

        await NavigationService.handleNotificationTap(
          type: 'new_order',
          data: {},
        );
        await tester.pumpAndSettle();

        expect(navigated, true);
      });

      testWidgets('should handle order_id as string', (tester) async {
        bool navigated = false;
        int? receivedOrderId;
        
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            routes: {
              '/': (context) => const Scaffold(body: Text('Home')),
              '/order-details': (context) {
                navigated = true;
                receivedOrderId = ModalRoute.of(context)?.settings.arguments as int?;
                return const Scaffold(body: Text('Order Details'));
              },
            },
          ),
        );

        await NavigationService.handleNotificationTap(
          type: 'order_status',
          data: {'order_id': '123'},  // String instead of int
        );
        await tester.pumpAndSettle();

        expect(navigated, true);
        expect(receivedOrderId, 123);
      });

      test('should do nothing for order_status without order_id', () async {
        await NavigationService.handleNotificationTap(
          type: 'order_status',
          data: {},  // No order_id
        );
        // Should complete without error
      });

      test('should do nothing for unknown notification type', () async {
        await NavigationService.handleNotificationTap(
          type: 'unknown_type',
          data: {'some_data': 'value'},
        );
        // Should complete without error
      });
    });
  });
}
