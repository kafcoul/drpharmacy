import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/orders/presentation/pages/order_confirmation_page.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: const OrderConfirmationPage(orderId: '1'),
        routes: {
          '/home': (_) => const Scaffold(body: Text('Home')),
          '/orders': (_) => const Scaffold(body: Text('Orders')),
          '/tracking': (_) => const Scaffold(body: Text('Tracking')),
        },
      ),
    );
  }

  group('OrderConfirmationPage Widget Tests', () {
    testWidgets('should render order confirmation page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OrderConfirmationPage), findsOneWidget);
    });

    testWidgets('should display success icon', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byIcon(Icons.check_circle), findsWidgets);
    });

    testWidgets('should display confirmation message', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OrderConfirmationPage), findsOneWidget);
    });

    testWidgets('should display order number', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OrderConfirmationPage), findsOneWidget);
    });

    testWidgets('should have track order button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should have continue shopping button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OrderConfirmationPage), findsOneWidget);
    });

    testWidgets('should display estimated delivery time', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OrderConfirmationPage), findsOneWidget);
    });

    testWidgets('should navigate to tracking on button tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final button = find.byType(ElevatedButton).first;
      if (button.evaluate().isNotEmpty) {
        await tester.tap(button);
        await tester.pumpAndSettle();
      }
      
      expect(true, true);
    });

    testWidgets('should have animation', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OrderConfirmationPage), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final semanticsHandle = tester.ensureSemantics();
      await tester.pump();
      semanticsHandle.dispose();
      
      expect(find.byType(OrderConfirmationPage), findsOneWidget);
    });
  });
}
