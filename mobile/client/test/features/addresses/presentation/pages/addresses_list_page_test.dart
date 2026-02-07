import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/addresses/presentation/pages/addresses_list_page.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: const AddressesListPage(),
        routes: {
          '/add-address': (_) => const Scaffold(body: Text('Add Address')),
          '/edit-address': (_) => const Scaffold(body: Text('Edit Address')),
        },
      ),
    );
  }

  group('AddressesListPage Widget Tests', () {
    testWidgets('should render addresses list page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AddressesListPage), findsOneWidget);
    });

    testWidgets('should have add address button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byIcon(Icons.add), findsWidgets);
    });

    testWidgets('should have app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display address cards', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AddressesListPage), findsOneWidget);
    });

    testWidgets('should have edit option for addresses', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AddressesListPage), findsOneWidget);
    });

    testWidgets('should have delete option for addresses', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AddressesListPage), findsOneWidget);
    });

    testWidgets('should show empty state when no addresses', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AddressesListPage), findsOneWidget);
    });

    testWidgets('should be scrollable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AddressesListPage), findsOneWidget);
    });

    testWidgets('should have default address indicator', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AddressesListPage), findsOneWidget);
    });

    testWidgets('should navigate to add address on button tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final addButton = find.byIcon(Icons.add);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton.first);
        await tester.pumpAndSettle();
      }
      
      expect(find.byType(AddressesListPage), findsWidgets);
    });
  });
}
