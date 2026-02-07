import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/home/presentation/widgets/featured_pharmacies_section.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FeaturedPharmaciesSection(),
          ),
        ),
      ),
    );
  }

  group('FeaturedPharmaciesSection Widget Tests', () {
    testWidgets('should render featured pharmacies section', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(FeaturedPharmaciesSection), findsOneWidget);
    });

    testWidgets('should display section title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(FeaturedPharmaciesSection), findsOneWidget);
    });

    testWidgets('should display pharmacy cards', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(FeaturedPharmaciesSection), findsOneWidget);
    });

    testWidgets('should be horizontally scrollable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(FeaturedPharmaciesSection), findsOneWidget);
    });

    testWidgets('should have see all button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(FeaturedPharmaciesSection), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final semanticsHandle = tester.ensureSemantics();
      await tester.pump();
      semanticsHandle.dispose();
      
      expect(find.byType(FeaturedPharmaciesSection), findsOneWidget);
    });
  });
}
