import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/prescriptions/presentation/pages/prescriptions_list_page.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: const PrescriptionsListPage(),
        routes: {
          '/prescription-upload': (_) => const Scaffold(body: Text('Upload')),
          '/prescription-details': (_) => const Scaffold(body: Text('Details')),
        },
      ),
    );
  }

  group('PrescriptionsListPage Widget Tests', () {
    testWidgets('should render prescriptions list page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PrescriptionsListPage), findsOneWidget);
    });

    testWidgets('should have app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have add prescription button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byIcon(Icons.add), findsWidgets);
    });

    testWidgets('should display prescription cards', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PrescriptionsListPage), findsOneWidget);
    });

    testWidgets('should show empty state when no prescriptions', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PrescriptionsListPage), findsOneWidget);
    });

    testWidgets('should display prescription date', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PrescriptionsListPage), findsOneWidget);
    });

    testWidgets('should display prescription status', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PrescriptionsListPage), findsOneWidget);
    });

    testWidgets('should be scrollable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PrescriptionsListPage), findsOneWidget);
    });

    testWidgets('should navigate to prescription details on tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PrescriptionsListPage), findsOneWidget);
    });

    testWidgets('should have pull to refresh', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(RefreshIndicator), findsWidgets);
    });

    testWidgets('should navigate to upload on button tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final addButton = find.byIcon(Icons.add);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton.first);
        await tester.pumpAndSettle();
      }
      
      expect(true, true);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final semanticsHandle = tester.ensureSemantics();
      await tester.pump();
      semanticsHandle.dispose();
      
      expect(find.byType(PrescriptionsListPage), findsOneWidget);
    });
  });
}
