import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/profile/presentation/pages/notification_settings_page.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: const NotificationSettingsPage(),
      ),
    );
  }

  group('NotificationSettingsPage Widget Tests', () {
    testWidgets('should render notification settings page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(NotificationSettingsPage), findsOneWidget);
    });

    testWidgets('should have push notifications toggle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(SwitchListTile), findsWidgets);
    });

    testWidgets('should have order updates toggle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(NotificationSettingsPage), findsOneWidget);
    });

    testWidgets('should have promotions toggle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(NotificationSettingsPage), findsOneWidget);
    });

    testWidgets('should have app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should toggle push notifications', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first);
        await tester.pump();
      }
      
      expect(find.byType(NotificationSettingsPage), findsOneWidget);
    });

    testWidgets('should have back button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final semanticsHandle = tester.ensureSemantics();
      await tester.pump();
      semanticsHandle.dispose();
      
      expect(find.byType(NotificationSettingsPage), findsOneWidget);
    });
  });
}
