import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:courier_flutter/presentation/widgets/home/go_online_button.dart';

void main() {
  group('GoOnlineButton', () {
    testWidgets('displays PASSER EN LIGNE when offline', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                GoOnlineButton(
                  isOnline: false,
                  isToggling: false,
                  onToggle: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PASSER EN LIGNE'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('displays PASSER HORS LIGNE when online', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                GoOnlineButton(
                  isOnline: true,
                  isToggling: false,
                  onToggle: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PASSER HORS LIGNE'), findsOneWidget);
      expect(find.byIcon(Icons.power_settings_new), findsOneWidget);
    });

    testWidgets('displays CHANGEMENT EN COURS when toggling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                GoOnlineButton(
                  isOnline: false,
                  isToggling: true,
                  onToggle: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('CHANGEMENT EN COURS...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('calls onToggle when tapped and not toggling', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                GoOnlineButton(
                  isOnline: false,
                  isToggling: false,
                  onToggle: () => tapped = true,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('PASSER EN LIGNE'));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onToggle when toggling', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                GoOnlineButton(
                  isOnline: false,
                  isToggling: true,
                  onToggle: () => tapped = true,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('CHANGEMENT EN COURS...'));
      expect(tapped, isFalse);
    });
  });
}
