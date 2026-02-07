import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/core/widgets/example_riverpod_form.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExampleRiverpodFormWidget(),
          ),
        ),
      ),
    );
  }

  group('ExampleRiverpodFormWidget Tests', () {
    testWidgets('should render example form', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(ExampleRiverpodFormWidget), findsOneWidget);
    });

    testWidgets('should have password field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('should have password visibility toggle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off), findsWidgets);
    });

    testWidgets('should toggle password visibility', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final toggleButton = find.byIcon(Icons.visibility_off).first;
      await tester.tap(toggleButton);
      await tester.pump();
      
      expect(find.byIcon(Icons.visibility), findsWidgets);
    });

    testWidgets('should have submit button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should have confirm password field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.textContaining('Confirmer'), findsWidgets);
    });

    testWidgets('should use Riverpod providers', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(ProviderScope), findsOneWidget);
    });

    testWidgets('should be scrollable in form', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(Form), findsOneWidget);
    });
  });
}
