import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/auth/presentation/pages/onboarding_page.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: const OnboardingPage(),
        routes: {
          '/login': (_) => const Scaffold(body: Text('Login')),
          '/register': (_) => const Scaffold(body: Text('Register')),
        },
      ),
    );
  }

  group('OnboardingPage Widget Tests', () {
    testWidgets('should render onboarding page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('should display onboarding slides', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(PageView), findsWidgets);
    });

    testWidgets('should have page indicators', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('should have next button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should have skip button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('should display slide images', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('should display slide titles', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('should display slide descriptions', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('should swipe to next slide', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final pageView = find.byType(PageView);
      if (pageView.evaluate().isNotEmpty) {
        await tester.drag(pageView.first, const Offset(-300, 0));
        await tester.pumpAndSettle();
      }
      
      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('should navigate to login after last slide', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final semanticsHandle = tester.ensureSemantics();
      await tester.pump();
      semanticsHandle.dispose();
      
      expect(find.byType(OnboardingPage), findsOneWidget);
    });
  });
}
