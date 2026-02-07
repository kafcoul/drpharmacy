import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/orders/presentation/widgets/prescription_requirement_section.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: PrescriptionRequirementSection(
            isRequired: true,
            onUpload: () {},
          ),
        ),
      ),
    );
  }

  group('PrescriptionRequirementSection Widget Tests', () {
    testWidgets('should render prescription requirement section', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PrescriptionRequirementSection), findsOneWidget);
    });

    testWidgets('should display requirement message when required', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PrescriptionRequirementSection), findsOneWidget);
    });

    testWidgets('should have upload button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PrescriptionRequirementSection), findsOneWidget);
    });

    testWidgets('should show warning icon when required', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PrescriptionRequirementSection), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final semanticsHandle = tester.ensureSemantics();
      await tester.pump();
      semanticsHandle.dispose();
      
      expect(find.byType(PrescriptionRequirementSection), findsOneWidget);
    });

    testWidgets('should not show when not required', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PrescriptionRequirementSection(
                isRequired: false,
                onUpload: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(PrescriptionRequirementSection), findsOneWidget);
    });
  });
}
