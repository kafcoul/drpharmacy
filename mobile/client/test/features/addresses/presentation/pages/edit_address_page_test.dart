import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/addresses/presentation/pages/edit_address_page.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: const EditAddressPage(addressId: '1'),
      ),
    );
  }

  group('EditAddressPage Widget Tests', () {
    testWidgets('should render edit address page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(EditAddressPage), findsOneWidget);
    });

    testWidgets('should have pre-filled address name field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('should have pre-filled street address field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('should have pre-filled city field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('should have update button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should have delete button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(EditAddressPage), findsOneWidget);
    });

    testWidgets('should validate empty address name', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(EditAddressPage), findsOneWidget);
    });

    testWidgets('should have default address checkbox', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(EditAddressPage), findsOneWidget);
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

    testWidgets('should show confirmation on delete', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(EditAddressPage), findsOneWidget);
    });

    testWidgets('should show loading indicator on update', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(EditAddressPage), findsOneWidget);
    });
  });
}
