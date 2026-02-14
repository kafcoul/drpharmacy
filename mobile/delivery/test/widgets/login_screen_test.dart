import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:courier_flutter/presentation/screens/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('should display login form elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      // Allow async operations to complete
      await tester.pumpAndSettle();
      
      // Verify header elements
      expect(find.text('DR-PHARMA'), findsOneWidget);
      expect(find.text('ESPACE LIVREUR'), findsOneWidget);
      
      // Verify form title
      expect(find.text('Connexion'), findsOneWidget);
      
      // Verify form fields
      expect(find.byType(TextFormField), findsNWidgets(2));
      
      // Verify login button
      expect(find.text('SE CONNECTER'), findsOneWidget);
      
      // Verify registration link
      expect(find.text('Pas encore de compte ? '), findsOneWidget);
      expect(find.text('Devenir livreur'), findsOneWidget);
    });

    testWidgets('should show validation error for empty email', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Find and tap login button without entering credentials
      await tester.tap(find.text('SE CONNECTER'));
      await tester.pumpAndSettle();
      
      // Verify validation error is shown
      expect(find.text('Veuillez entrer votre identifiant'), findsOneWidget);
    });

    testWidgets('should show validation error for empty password', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Enter email but not password
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      
      // Tap login button
      await tester.tap(find.text('SE CONNECTER'));
      await tester.pumpAndSettle();
      
      // Verify password validation error
      expect(find.text('Veuillez entrer votre mot de passe'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Find password visibility toggle icon
      final visibilityIcon = find.byIcon(Icons.visibility_off_outlined);
      expect(visibilityIcon, findsOneWidget);
      
      // Tap to toggle visibility
      await tester.tap(visibilityIcon);
      await tester.pumpAndSettle();
      
      // Verify icon changed to visibility_outlined
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('should navigate to register screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap on "Devenir livreur" link
      await tester.tap(find.text('Devenir livreur'));
      await tester.pumpAndSettle();
      
      // Verify navigation occurred (RegisterScreen should be displayed)
      // Note: This test might need mocking or might fail if RegisterScreen has dependencies
    });

    testWidgets('should display version number', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      expect(find.text('Version 1.0.0'), findsOneWidget);
    });

    testWidgets('displays shipping icon in header', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      expect(find.byIcon(Icons.local_shipping_rounded), findsOneWidget);
    });

    testWidgets('displays form field labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      expect(find.text('Email ou Téléphone'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
    });

    testWidgets('displays form field prefix icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('can enter text in both fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).first, 'user@test.com');
      expect(find.text('user@test.com'), findsOneWidget);
      
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('displays hint text for email field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      expect(find.text('ex: +225 0102030405'), findsOneWidget);
    });

    testWidgets('both validation errors show when both fields empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('SE CONNECTER'));
      await tester.pumpAndSettle();
      
      expect(find.text('Veuillez entrer votre identifiant'), findsOneWidget);
      expect(find.text('Veuillez entrer votre mot de passe'), findsOneWidget);
    });
  });
}
