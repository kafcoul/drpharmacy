import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/features/orders/presentation/widgets/payment_dialogs.dart';

void main() {
  group('PaymentProviderDialog', () {
    testWidgets('should display dialog title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PaymentProviderDialog(),
          ),
        ),
      );

      expect(find.text('Choisir le moyen de paiement'), findsOneWidget);
    });

    testWidgets('should display Jèko option', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PaymentProviderDialog(),
          ),
        ),
      );

      expect(find.text('Jèko'), findsOneWidget);
    });

    testWidgets('should display payment methods description', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PaymentProviderDialog(),
          ),
        ),
      );

      expect(find.text('Wave, Orange Money, MTN, Moov, Djamo'), findsOneWidget);
    });

    testWidgets('should display wallet icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PaymentProviderDialog(),
          ),
        ),
      );

      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
    });

    testWidgets('should be a SimpleDialog', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PaymentProviderDialog(),
          ),
        ),
      );

      expect(find.byType(SimpleDialog), findsOneWidget);
    });

    testWidgets('should return jeko when Jèko option is tapped', (tester) async {
      String? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await showDialog<String>(
                    context: context,
                    builder: (context) => const PaymentProviderDialog(),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap on Jèko option
      await tester.tap(find.text('Jèko'));
      await tester.pumpAndSettle();

      expect(result, 'jeko');
    });

    testWidgets('show static method should display dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => PaymentProviderDialog.show(context),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Initially no dialog
      expect(find.text('Choisir le moyen de paiement'), findsNothing);

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Choisir le moyen de paiement'), findsOneWidget);
    });

    testWidgets('dialog should not be dismissible by tapping outside', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => PaymentProviderDialog.show(context),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.text('Choisir le moyen de paiement'), findsOneWidget);

      // Tap outside (barrier)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Dialog should still be visible
      expect(find.text('Choisir le moyen de paiement'), findsOneWidget);
    });
  });

  group('PaymentLoadingDialog', () {
    testWidgets('should display loading indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PaymentLoadingDialog(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should be wrapped in a Card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PaymentLoadingDialog(),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('show static method should display loading dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => PaymentLoadingDialog.show(context),
                child: const Text('Show Loading'),
              ),
            ),
          ),
        ),
      );

      // Initially no loading dialog
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Show loading
      await tester.tap(find.text('Show Loading'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hide static method should close dialog', (tester) async {
      late BuildContext savedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              savedContext = context;
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => PaymentLoadingDialog.show(context),
                  child: const Text('Show Loading'),
                ),
              );
            },
          ),
        ),
      );

      // Show loading
      await tester.tap(find.text('Show Loading'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Hide loading
      PaymentLoadingDialog.hide(savedContext);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('loading dialog should not be dismissible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => PaymentLoadingDialog.show(context),
                child: const Text('Show Loading'),
              ),
            ),
          ),
        ),
      );

      // Show loading
      await tester.tap(find.text('Show Loading'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Try to dismiss by tapping outside
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should still be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
