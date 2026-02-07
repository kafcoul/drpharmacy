import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/features/orders/presentation/widgets/payment_mode_selector.dart';
import 'package:drpharma_client/core/constants/app_constants.dart';

void main() {
  Widget createTestWidget({
    required String selectedMode,
    required ValueChanged<String> onModeChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PaymentModeSelector(
          selectedMode: selectedMode,
          onModeChanged: onModeChanged,
        ),
      ),
    );
  }

  group('PaymentModeSelector', () {
    testWidgets('should display both payment options', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          selectedMode: AppConstants.paymentModePlatform,
          onModeChanged: (_) {},
        ),
      );

      // Assert
      expect(find.text('Paiement en ligne'), findsOneWidget);
      expect(find.text('Paiement à la livraison'), findsOneWidget);
    });

    testWidgets('should display subtitles for payment options', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          selectedMode: AppConstants.paymentModePlatform,
          onModeChanged: (_) {},
        ),
      );

      // Assert
      expect(find.textContaining('mobile money'), findsOneWidget);
      expect(find.textContaining('espèces'), findsOneWidget);
    });

    testWidgets('should have radio buttons for each option', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          selectedMode: AppConstants.paymentModePlatform,
          onModeChanged: (_) {},
        ),
      );

      // Assert
      expect(find.byType(Radio<String>), findsNWidgets(2));
    });

    testWidgets('should select platform payment by default when provided',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          selectedMode: AppConstants.paymentModePlatform,
          onModeChanged: (_) {},
        ),
      );

      // Assert
      final radio = tester.widget<Radio<String>>(
        find.byType(Radio<String>).first,
      );
      expect(radio.groupValue, AppConstants.paymentModePlatform);
    });

    testWidgets('should select on_delivery payment when provided',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          selectedMode: AppConstants.paymentModeOnDelivery,
          onModeChanged: (_) {},
        ),
      );

      // Assert
      final radios = tester.widgetList<Radio<String>>(
        find.byType(Radio<String>),
      ).toList();
      expect(radios[1].groupValue, AppConstants.paymentModeOnDelivery);
    });

    testWidgets('should call onModeChanged when tapping on delivery option',
        (tester) async {
      // Arrange
      String? selectedValue;
      await tester.pumpWidget(
        createTestWidget(
          selectedMode: AppConstants.paymentModePlatform,
          onModeChanged: (value) => selectedValue = value,
        ),
      );

      // Act - tap on "Paiement à la livraison"
      await tester.tap(find.text('Paiement à la livraison'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedValue, AppConstants.paymentModeOnDelivery);
    });

    testWidgets('should call onModeChanged when tapping on platform option',
        (tester) async {
      // Arrange
      String? selectedValue;
      await tester.pumpWidget(
        createTestWidget(
          selectedMode: AppConstants.paymentModeOnDelivery,
          onModeChanged: (value) => selectedValue = value,
        ),
      );

      // Act - tap on "Paiement en ligne"
      await tester.tap(find.text('Paiement en ligne'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedValue, AppConstants.paymentModePlatform);
    });

    testWidgets('should call onModeChanged when tapping radio directly',
        (tester) async {
      // Arrange
      String? selectedValue;
      await tester.pumpWidget(
        createTestWidget(
          selectedMode: AppConstants.paymentModePlatform,
          onModeChanged: (value) => selectedValue = value,
        ),
      );

      // Act - tap on second radio button
      await tester.tap(find.byType(Radio<String>).last);
      await tester.pumpAndSettle();

      // Assert
      expect(selectedValue, AppConstants.paymentModeOnDelivery);
    });

    testWidgets('should display payment icons', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          selectedMode: AppConstants.paymentModePlatform,
          onModeChanged: (_) {},
        ),
      );

      // Assert
      expect(find.byIcon(Icons.payment), findsOneWidget);
      expect(find.byIcon(Icons.local_shipping), findsOneWidget);
    });

    testWidgets('selected option should have different visual appearance',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          selectedMode: AppConstants.paymentModePlatform,
          onModeChanged: (_) {},
        ),
      );

      // Assert - find cards (both options are in cards)
      expect(find.byType(Card), findsNWidgets(2));
    });
  });
}
