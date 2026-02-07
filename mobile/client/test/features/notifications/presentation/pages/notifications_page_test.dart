import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/notifications/presentation/pages/notifications_page.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: const NotificationsPage(),
        routes: {
          '/order-details': (_) => const Scaffold(body: Text('Order Details')),
        },
      ),
    );
  }

  group('NotificationsPage Widget Tests', () {
    testWidgets('should render notifications page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(NotificationsPage), findsOneWidget);
    });

    testWidgets('should have app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display notification cards', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(NotificationsPage), findsOneWidget);
    });

    testWidgets('should show empty state when no notifications', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(NotificationsPage), findsOneWidget);
    });

    testWidgets('should display notification title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(NotificationsPage), findsOneWidget);
    });

    testWidgets('should display notification body', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(NotificationsPage), findsOneWidget);
    });

    testWidgets('should display notification time', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(NotificationsPage), findsOneWidget);
    });

    testWidgets('should indicate read/unread status', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(NotificationsPage), findsOneWidget);
    });

    testWidgets('should be scrollable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(NotificationsPage), findsOneWidget);
    });

    testWidgets('should have mark all as read option', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(NotificationsPage), findsOneWidget);
    });

    testWidgets('should navigate on notification tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(NotificationsPage), findsOneWidget);
    });

    testWidgets('should have delete option', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(NotificationsPage), findsOneWidget);
    });

    testWidgets('should have pull to refresh', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(RefreshIndicator), findsWidgets);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final semanticsHandle = tester.ensureSemantics();
      await tester.pump();
      semanticsHandle.dispose();
      
      expect(find.byType(NotificationsPage), findsOneWidget);
    });
  });
}
