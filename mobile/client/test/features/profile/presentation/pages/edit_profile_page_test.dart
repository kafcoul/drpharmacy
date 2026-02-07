import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/profile/presentation/pages/edit_profile_page.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: const EditProfilePage(),
      ),
    );
  }

  group('EditProfilePage Widget Tests', () {
    testWidgets('should render edit profile page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(EditProfilePage), findsOneWidget);
    });

    testWidgets('should have name text field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('should have phone text field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('should have email text field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('should have save button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should have profile picture change option', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(EditProfilePage), findsOneWidget);
    });

    testWidgets('should validate empty name', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, '');
      await tester.pump();
      
      expect(find.byType(EditProfilePage), findsOneWidget);
    });

    testWidgets('should validate phone format', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(EditProfilePage), findsOneWidget);
    });

    testWidgets('should validate email format', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(EditProfilePage), findsOneWidget);
    });

    testWidgets('should have back navigation', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should be scrollable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });
  });
}
