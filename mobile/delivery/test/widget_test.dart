// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:courier_flutter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App renders splash screen on launch', (WidgetTester tester) async {
    // Initialiser les mocks nécessaires pour éviter les erreurs de platform channels
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Le splash screen affiche le logo DR-PHARMA et LIVREUR
    expect(find.text('DR-PHARMA'), findsOneWidget);
    expect(find.text('LIVREUR'), findsOneWidget);

    // Pomper tous les timers pendants (splash screen a un timer de session check)
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}
