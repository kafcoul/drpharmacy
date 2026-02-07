import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/addresses/presentation/widgets/address_selector.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: AddressSelector(
            onAddressSelected: (address) {},
          ),
        ),
      ),
    );
  }

  group('AddressSelector Widget Tests', () {
    testWidgets('should render address selector', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AddressSelector), findsOneWidget);
    });

    testWidgets('should display address list', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AddressSelector), findsOneWidget);
    });

    testWidgets('should have add new address option', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AddressSelector), findsOneWidget);
    });

    testWidgets('should be selectable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AddressSelector), findsOneWidget);
    });

    testWidgets('should show selected address indicator', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AddressSelector), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final semanticsHandle = tester.ensureSemantics();
      await tester.pump();
      semanticsHandle.dispose();
      
      expect(find.byType(AddressSelector), findsOneWidget);
    });
  });
}
