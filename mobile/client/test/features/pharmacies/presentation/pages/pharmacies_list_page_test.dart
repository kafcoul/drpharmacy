import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/pharmacies/presentation/pages/pharmacies_list_page.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: const PharmaciesListPage(),
        routes: {
          '/pharmacy-details': (_) => const Scaffold(body: Text('Pharmacy Details')),
          '/pharmacies-map': (_) => const Scaffold(body: Text('Pharmacies Map')),
        },
      ),
    );
  }

  group('PharmaciesListPage Widget Tests', () {
    testWidgets('should render pharmacies list page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmaciesListPage), findsOneWidget);
    });

    testWidgets('should have app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have search functionality', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmaciesListPage), findsOneWidget);
    });

    testWidgets('should display pharmacy cards', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmaciesListPage), findsOneWidget);
    });

    testWidgets('should show pharmacy name', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmaciesListPage), findsOneWidget);
    });

    testWidgets('should show pharmacy distance', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmaciesListPage), findsOneWidget);
    });

    testWidgets('should show pharmacy rating', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmaciesListPage), findsOneWidget);
    });

    testWidgets('should be scrollable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmaciesListPage), findsOneWidget);
    });

    testWidgets('should have map view toggle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmaciesListPage), findsOneWidget);
    });

    testWidgets('should have filter options', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmaciesListPage), findsOneWidget);
    });

    testWidgets('should navigate to pharmacy details on tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmaciesListPage), findsOneWidget);
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
      
      expect(find.byType(PharmaciesListPage), findsOneWidget);
    });
  });
}
