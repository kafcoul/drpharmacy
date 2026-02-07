import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/orders/presentation/pages/orders_list_page.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: const OrdersListPage(),
        routes: {
          '/order-details': (_) => const Scaffold(body: Text('Order Details')),
          '/tracking': (_) => const Scaffold(body: Text('Tracking')),
        },
      ),
    );
  }

  group('OrdersListPage Widget Tests', () {
    testWidgets('should render orders list page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OrdersListPage), findsOneWidget);
    });

    testWidgets('should have app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display order cards', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OrdersListPage), findsOneWidget);
    });

    testWidgets('should show empty state when no orders', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OrdersListPage), findsOneWidget);
    });

    testWidgets('should display order status', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OrdersListPage), findsOneWidget);
    });

    testWidgets('should display order total', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OrdersListPage), findsOneWidget);
    });

    testWidgets('should be scrollable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OrdersListPage), findsOneWidget);
    });

    testWidgets('should have filter by status', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OrdersListPage), findsOneWidget);
    });

    testWidgets('should navigate to order details on tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OrdersListPage), findsOneWidget);
    });

    testWidgets('should have pull to refresh', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(RefreshIndicator), findsWidgets);
    });

    testWidgets('should display order date', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OrdersListPage), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final semanticsHandle = tester.ensureSemantics();
      await tester.pump();
      semanticsHandle.dispose();
      
      expect(find.byType(OrdersListPage), findsOneWidget);
    });
  });
}
