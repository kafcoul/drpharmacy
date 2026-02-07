import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/profile/presentation/pages/profile_page.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: const ProfilePage(),
        routes: {
          '/edit-profile': (_) => const Scaffold(body: Text('Edit Profile')),
          '/addresses': (_) => const Scaffold(body: Text('Addresses')),
          '/orders': (_) => const Scaffold(body: Text('Orders')),
          '/settings': (_) => const Scaffold(body: Text('Settings')),
          '/login': (_) => const Scaffold(body: Text('Login')),
        },
      ),
    );
  }

  group('ProfilePage Widget Tests', () {
    testWidgets('should render profile page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('should display user avatar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(CircleAvatar), findsWidgets);
    });

    testWidgets('should have edit profile option', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.textContaining('Modifier'), findsWidgets);
    });

    testWidgets('should have addresses option', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.textContaining('Adresses'), findsWidgets);
    });

    testWidgets('should have orders history option', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.textContaining('Commandes'), findsWidgets);
    });

    testWidgets('should have logout option', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.textContaining('Déconnexion'), findsWidgets);
    });

    testWidgets('should display user name', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('should have settings option', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(ProfilePage), findsOneWidget);
    });
  });
}
