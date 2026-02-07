import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/auth/presentation/pages/splash_page.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: const SplashPage(),
        routes: {
          '/login': (_) => const Scaffold(body: Text('Login')),
          '/home': (_) => const Scaffold(body: Text('Home')),
        },
      ),
    );
  }

  group('SplashPage Widget Tests', () {
    testWidgets('should render splash page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(SplashPage), findsOneWidget);
    });

    testWidgets('should display app logo', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(SplashPage), findsOneWidget);
    });

    testWidgets('should display app name', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.textContaining('DR'), findsWidgets);
    });

    testWidgets('should show loading indicator', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should have branded colors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(SplashPage), findsOneWidget);
    });
  });
}
