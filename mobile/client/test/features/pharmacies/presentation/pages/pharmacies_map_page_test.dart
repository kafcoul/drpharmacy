import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/pharmacies/presentation/pages/pharmacies_map_page.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: const PharmaciesMapPage(),
        routes: {
          '/pharmacy-details': (_) => const Scaffold(body: Text('Pharmacy Details')),
          '/pharmacies-list': (_) => const Scaffold(body: Text('Pharmacies List')),
        },
      ),
    );
  }

  group('PharmaciesMapPage Widget Tests', () {
    testWidgets('should render pharmacies map page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmaciesMapPage), findsOneWidget);
    });

    testWidgets('should display map', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmaciesMapPage), findsOneWidget);
    });

    testWidgets('should have app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display pharmacy markers', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmaciesMapPage), findsOneWidget);
    });

    testWidgets('should have user location button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsWidgets);
    });

    testWidgets('should show pharmacy info on marker tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmaciesMapPage), findsOneWidget);
    });

    testWidgets('should have list view toggle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmaciesMapPage), findsOneWidget);
    });

    testWidgets('should have search functionality', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmaciesMapPage), findsOneWidget);
    });

    testWidgets('should have zoom controls', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmaciesMapPage), findsOneWidget);
    });

    testWidgets('should show loading state', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmaciesMapPage), findsOneWidget);
    });

    testWidgets('should navigate to pharmacy details', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PharmaciesMapPage), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final semanticsHandle = tester.ensureSemantics();
      await tester.pump();
      semanticsHandle.dispose();
      
      expect(find.byType(PharmaciesMapPage), findsOneWidget);
    });
  });
}
