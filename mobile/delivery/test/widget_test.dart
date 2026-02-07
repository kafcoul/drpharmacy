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

void main() {
  testWidgets('Login screen renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Wrap in ProviderScope because MyApp uses it in main(), but here we pump the widget directly
    // Actually MyApp in main.dart is wrapped in ProviderScope in main(), but inside MyApp it is just MaterialApp
    // Wait, main() does runAPP(ProviderScope(child: MyApp())).
    // Testing MyApp directly means we need to wrap it ourselves if it depends on providers,
    // or we can test ProviderScope(child: MyApp()).

    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify that login screen is shown
    expect(find.text('Courier Login'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
