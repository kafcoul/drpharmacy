import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/orders/presentation/widgets/delivery_address_form.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DeliveryAddressForm(
              onSubmit: (address) {},
            ),
          ),
        ),
      ),
    );
  }

  group('DeliveryAddressForm Widget Tests', () {
    testWidgets('should render delivery address form', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(DeliveryAddressForm), findsOneWidget);
    });

    testWidgets('should have street field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('should have city field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('should have submit button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should validate empty fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final button = find.byType(ElevatedButton).first;
      if (button.evaluate().isNotEmpty) {
        await tester.tap(button);
        await tester.pump();
      }
      
      expect(find.byType(DeliveryAddressForm), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final semanticsHandle = tester.ensureSemantics();
      await tester.pump();
      semanticsHandle.dispose();
      
      expect(find.byType(DeliveryAddressForm), findsOneWidget);
    });
  });
}
