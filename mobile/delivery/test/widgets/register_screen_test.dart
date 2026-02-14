import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:courier_flutter/presentation/screens/register_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildScreen() {
    return const ProviderScope(
      child: MaterialApp(
        home: RegisterScreen(),
      ),
    );
  }

  group('RegisterScreen - Structure', () {
    testWidgets('displays app bar with title', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Devenir Livreur'), findsOneWidget);
    });

    testWidgets('displays stepper widget', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Stepper), findsOneWidget);
    });

    testWidgets('displays first step title', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Informations personnelles'), findsOneWidget);
    });

    testWidgets('displays vehicle step title', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Véhicule'), findsOneWidget);
    });

    testWidgets('displays step subtitles', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Nom, email, téléphone'), findsOneWidget);
    });
  });

  group('RegisterScreen - Personal Info Fields', () {
    testWidgets('displays all personal info form fields', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Nom complet'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Téléphone'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.text('Confirmer mot de passe'), findsOneWidget);
    });

    testWidgets('displays form field icons', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsAtLeastNWidgets(2));
    });

    testWidgets('displays Continuer button', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Continuer'), findsAtLeastNWidgets(1));
    });

    testWidgets('does not display Retour on first step', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Retour'), findsNothing);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsAtLeastNWidgets(1));
      await tester.tap(find.byIcon(Icons.visibility).first);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility_off), findsAtLeastNWidgets(1));
    });

    testWidgets('can enter text in name field', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Nom complet'), 'John Doe');
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('can enter text in email field', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'john@test.com');
      expect(find.text('john@test.com'), findsOneWidget);
    });

    testWidgets('can enter text in phone field', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Téléphone'), '0612345678');
      expect(find.text('0612345678'), findsOneWidget);
    });
  });

  group('RegisterScreen - Step Navigation', () {
    testWidgets('advances to vehicle step on Continuer', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Tap Continuer (FilledButton)
      final continuerButton = find.byType(FilledButton);
      await tester.ensureVisible(continuerButton.first);
      await tester.tap(continuerButton.first);
      await tester.pumpAndSettle();

      // Now vehicle step content should be visible
      expect(find.text('Type de véhicule'), findsOneWidget);
      expect(find.text('Retour'), findsAtLeastNWidgets(1));
    });

    testWidgets('vehicle step shows vehicle type cards', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Go to step 1
      final continuerButton = find.byType(FilledButton);
      await tester.ensureVisible(continuerButton.first);
      await tester.tap(continuerButton.first);
      await tester.pumpAndSettle();

      expect(find.text('Vélo'), findsOneWidget);
      expect(find.text('Moto'), findsOneWidget);
      expect(find.text('Voiture'), findsOneWidget);
    });

    testWidgets('vehicle step shows vehicle type icons', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      final continuerButton = find.byType(FilledButton);
      await tester.ensureVisible(continuerButton.first);
      await tester.tap(continuerButton.first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.pedal_bike), findsOneWidget);
      expect(find.byIcon(Icons.two_wheeler), findsOneWidget);
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });

    testWidgets('vehicle step shows immatriculation field', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      final continuerButton = find.byType(FilledButton);
      await tester.ensureVisible(continuerButton.first);
      await tester.tap(continuerButton.first);
      await tester.pumpAndSettle();

      expect(find.text('Immatriculation du véhicule'), findsOneWidget);
    });

    testWidgets('vehicle step shows license number field', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      final continuerButton = find.byType(FilledButton);
      await tester.ensureVisible(continuerButton.first);
      await tester.tap(continuerButton.first);
      await tester.pumpAndSettle();

      expect(find.textContaining('Numéro de permis'), findsOneWidget);
    });

    testWidgets('can go back from vehicle step', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Go to step 1
      final continuerButton = find.byType(FilledButton);
      await tester.ensureVisible(continuerButton.first);
      await tester.tap(continuerButton.first);
      await tester.pumpAndSettle();

      // Tap the OutlinedButton (Retour) - more specific than text
      final retourButton = find.byType(OutlinedButton);
      await tester.ensureVisible(retourButton.first);
      await tester.tap(retourButton.first);
      await tester.pumpAndSettle();

      // Back to personal info
      expect(find.text('Nom complet'), findsOneWidget);
    });

    testWidgets('advances to KYC step', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Go to step 1
      var continuerButton = find.byType(FilledButton);
      await tester.ensureVisible(continuerButton.first);
      await tester.tap(continuerButton.first);
      await tester.pumpAndSettle();

      // Go to step 2
      continuerButton = find.byType(FilledButton);
      await tester.ensureVisible(continuerButton.first);
      await tester.tap(continuerButton.first);
      await tester.pumpAndSettle();

      // KYC step content should be visible
      expect(find.textContaining('vérifier votre identité'), findsOneWidget);
    });

    testWidgets('KYC step shows document upload cards', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Navigate to step 2
      var btn = find.byType(FilledButton);
      await tester.ensureVisible(btn.first);
      await tester.tap(btn.first);
      await tester.pumpAndSettle();

      btn = find.byType(FilledButton);
      await tester.ensureVisible(btn.first);
      await tester.tap(btn.first);
      await tester.pumpAndSettle();

      expect(find.textContaining('Pièce d\'identité (Recto)'), findsOneWidget);
      expect(find.textContaining('Pièce d\'identité (Verso)'), findsOneWidget);
      expect(find.textContaining('Selfie de vérification'), findsOneWidget);
    });

    testWidgets('KYC step shows S inscrire button', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Navigate to step 2
      var btn = find.byType(FilledButton);
      await tester.ensureVisible(btn.first);
      await tester.tap(btn.first);
      await tester.pumpAndSettle();

      btn = find.byType(FilledButton);
      await tester.ensureVisible(btn.first);
      await tester.tap(btn.first);
      await tester.pumpAndSettle();

      expect(find.text('S\'inscrire'), findsAtLeastNWidgets(1));
    });

    testWidgets('KYC step shows info box about verification', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Navigate to step 2
      var btn = find.byType(FilledButton);
      await tester.ensureVisible(btn.first);
      await tester.tap(btn.first);
      await tester.pumpAndSettle();

      btn = find.byType(FilledButton);
      await tester.ensureVisible(btn.first);
      await tester.tap(btn.first);
      await tester.pumpAndSettle();

      expect(find.textContaining('24-48h'), findsOneWidget);
    });
  });
}
