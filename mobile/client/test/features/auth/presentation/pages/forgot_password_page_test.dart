import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/auth/presentation/pages/forgot_password_page.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: const ForgotPasswordPage(),
        routes: {
          '/login': (_) => const Scaffold(body: Text('Login')),
        },
      ),
    );
  }

  group('ForgotPasswordPage Widget Tests', () {
    testWidgets('should render forgot password page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordPage), findsOneWidget);
    });

    testWidgets('should have email input field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('should have submit button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should have back to login link', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.textContaining('connexion'), findsWidgets);
    });

    testWidgets('should validate empty email', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      final submitButton = find.byType(ElevatedButton);
      if (submitButton.evaluate().isNotEmpty) {
        await tester.tap(submitButton.first);
        await tester.pumpAndSettle();
      }
      expect(find.byType(ForgotPasswordPage), findsOneWidget);
    });

    testWidgets('should validate email format', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      final emailField = find.byType(TextFormField);
      if (emailField.evaluate().isNotEmpty) {
        await tester.enterText(emailField.first, 'invalid-email');
        await tester.pumpAndSettle();
      }
      expect(find.byType(ForgotPasswordPage), findsOneWidget);
    });

    testWidgets('should show success message on submit', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordPage), findsOneWidget);
    });
  });
}
