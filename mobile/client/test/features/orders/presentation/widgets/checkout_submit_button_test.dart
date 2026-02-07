import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/orders/presentation/widgets/checkout_submit_button.dart';

void main() {
  group('CheckoutSubmitButton', () {
    group('normal state', () {
      testWidgets('should display total price when not submitting', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckoutSubmitButton(
                isSubmitting: false,
                totalFormatted: '15,000 FCFA',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Confirmer la commande - 15,000 FCFA'), findsOneWidget);
      });

      testWidgets('should be enabled when not submitting', (tester) async {
        bool pressed = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckoutSubmitButton(
                isSubmitting: false,
                totalFormatted: '15,000 FCFA',
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        expect(pressed, true);
      });

      testWidgets('should display correct formatted amount', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckoutSubmitButton(
                isSubmitting: false,
                totalFormatted: '250,500 FCFA',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Confirmer la commande - 250,500 FCFA'), findsOneWidget);
      });

      testWidgets('should handle zero amount', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckoutSubmitButton(
                isSubmitting: false,
                totalFormatted: '0 FCFA',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Confirmer la commande - 0 FCFA'), findsOneWidget);
      });
    });

    group('submitting state', () {
      testWidgets('should display loading indicator when submitting', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckoutSubmitButton(
                isSubmitting: true,
                totalFormatted: '15,000 FCFA',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Traitement en cours...'), findsOneWidget);
      });

      testWidgets('should be disabled when submitting', (tester) async {
        bool pressed = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckoutSubmitButton(
                isSubmitting: true,
                totalFormatted: '15,000 FCFA',
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);
        expect(pressed, false);
      });

      testWidgets('should not show total when submitting', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckoutSubmitButton(
                isSubmitting: true,
                totalFormatted: '15,000 FCFA',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Confirmer la commande - 15,000 FCFA'), findsNothing);
      });
    });

    group('disabled state', () {
      testWidgets('should be disabled when onPressed is null', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CheckoutSubmitButton(
                isSubmitting: false,
                totalFormatted: '15,000 FCFA',
                onPressed: null,
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);
      });
    });

    group('button styling', () {
      testWidgets('should take full width', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                child: CheckoutSubmitButton(
                  isSubmitting: false,
                  totalFormatted: '15,000 FCFA',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(
          find.ancestor(
            of: find.byType(ElevatedButton),
            matching: find.byType(SizedBox),
          ).first,
        );
        expect(sizedBox.width, double.infinity);
      });

      testWidgets('should render as ElevatedButton', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckoutSubmitButton(
                isSubmitting: false,
                totalFormatted: '15,000 FCFA',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });

    group('text styling', () {
      testWidgets('should have bold text', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckoutSubmitButton(
                isSubmitting: false,
                totalFormatted: '15,000 FCFA',
                onPressed: () {},
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(
          find.text('Confirmer la commande - 15,000 FCFA'),
        );
        expect(textWidget.style?.fontWeight, FontWeight.bold);
      });

      testWidgets('should have proper font size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckoutSubmitButton(
                isSubmitting: false,
                totalFormatted: '15,000 FCFA',
                onPressed: () {},
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(
          find.text('Confirmer la commande - 15,000 FCFA'),
        );
        expect(textWidget.style?.fontSize, 16);
      });
    });

    group('callback behavior', () {
      testWidgets('should call onPressed when tapped', (tester) async {
        int tapCount = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckoutSubmitButton(
                isSubmitting: false,
                totalFormatted: '15,000 FCFA',
                onPressed: () => tapCount++,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        expect(tapCount, 1);

        await tester.tap(find.byType(ElevatedButton));
        expect(tapCount, 2);
      });

      testWidgets('should not call onPressed when submitting', (tester) async {
        int tapCount = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckoutSubmitButton(
                isSubmitting: true,
                totalFormatted: '15,000 FCFA',
                onPressed: () => tapCount++,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        expect(tapCount, 0);
      });
    });

    group('loading indicator', () {
      testWidgets('should show loading indicator with correct size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckoutSubmitButton(
                isSubmitting: true,
                totalFormatted: '15,000 FCFA',
                onPressed: () {},
              ),
            ),
          ),
        );

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.strokeWidth, 2);
      });

      testWidgets('should show loading text', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckoutSubmitButton(
                isSubmitting: true,
                totalFormatted: '15,000 FCFA',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Traitement en cours...'), findsOneWidget);
      });
    });
  });
}
