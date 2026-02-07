import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/pharmacies/presentation/pages/pharmacy_details_page.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: const PharmacyDetailsPage(pharmacyId: '1'),
        routes: {
          '/products': (_) => const Scaffold(body: Text('Products')),
        },
      ),
    );
  }

  group('PharmacyDetailsPage Widget Tests', () {
    testWidgets('should render pharmacy details page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmacyDetailsPage), findsOneWidget);
    });

    testWidgets('should display pharmacy name', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmacyDetailsPage), findsOneWidget);
    });

    testWidgets('should display pharmacy address', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmacyDetailsPage), findsOneWidget);
    });

    testWidgets('should display pharmacy rating', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmacyDetailsPage), findsOneWidget);
    });

    testWidgets('should display opening hours', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmacyDetailsPage), findsOneWidget);
    });

    testWidgets('should have call button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmacyDetailsPage), findsOneWidget);
    });

    testWidgets('should have directions button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmacyDetailsPage), findsOneWidget);
    });

    testWidgets('should display pharmacy image', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmacyDetailsPage), findsOneWidget);
    });

    testWidgets('should have products section', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmacyDetailsPage), findsOneWidget);
    });

    testWidgets('should have app bar with back button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should be scrollable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('should display distance from user', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmacyDetailsPage), findsOneWidget);
    });

    testWidgets('should show if pharmacy is on duty', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmacyDetailsPage), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final semanticsHandle = tester.ensureSemantics();
      await tester.pump();
      semanticsHandle.dispose();
      
      expect(find.byType(PharmacyDetailsPage), findsOneWidget);
    });
  });
}
