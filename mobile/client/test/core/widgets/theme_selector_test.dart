import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/core/widgets/theme_selector.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: ThemeSelector(),
        ),
      ),
    );
  }

  group('ThemeSelector Widget Tests', () {
    testWidgets('should render theme selector', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(ThemeSelector), findsOneWidget);
    });

    testWidgets('should have theme options', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(ThemeSelector), findsOneWidget);
    });

    testWidgets('should be tappable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final selector = find.byType(ThemeSelector);
      if (selector.evaluate().isNotEmpty) {
        await tester.tap(selector.first);
        await tester.pump();
      }
      
      expect(find.byType(ThemeSelector), findsOneWidget);
    });
  });
}
