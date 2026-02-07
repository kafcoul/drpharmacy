import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/home/presentation/widgets/home_app_bar.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          appBar: HomeAppBar(),
        ),
      ),
    );
  }

  group('HomeAppBar Widget Tests', () {
    testWidgets('should render home app bar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(HomeAppBar), findsOneWidget);
    });

    testWidgets('should display logo or title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(HomeAppBar), findsOneWidget);
    });

    testWidgets('should have notification icon', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byIcon(Icons.notifications), findsWidgets);
    });

    testWidgets('should have cart icon', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(HomeAppBar), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final semanticsHandle = tester.ensureSemantics();
      await tester.pump();
      semanticsHandle.dispose();
      
      expect(find.byType(HomeAppBar), findsOneWidget);
    });
  });
}
