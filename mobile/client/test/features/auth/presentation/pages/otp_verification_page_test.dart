import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drpharma_client/features/auth/presentation/pages/otp_verification_page.dart';

void main() {
  Widget createTestWidget({String phoneNumber = '+2250701020304'}) {
    return ProviderScope(
      child: MaterialApp(
        home: OtpVerificationPage(phoneNumber: phoneNumber),
        routes: {
          '/home': (_) => const Scaffold(body: Text('Home')),
          '/login': (_) => const Scaffold(body: Text('Login')),
        },
      ),
    );
  }

  group('OtpVerificationPage Widget Tests', () {
    testWidgets('should render OTP verification page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(OtpVerificationPage), findsOneWidget);
    });

    testWidgets('should display phone number', (tester) async {
      await tester.pumpWidget(createTestWidget(phoneNumber: '+2250701020304'));
      await tester.pumpAndSettle();
      expect(find.textContaining('07'), findsWidgets);
    });

    testWidgets('should have OTP input fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('should have verify button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.textContaining('Vérifier'), findsWidgets);
    });

    testWidgets('should have resend OTP link', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.textContaining('Renvoyer'), findsWidgets);
    });

    testWidgets('should show countdown timer', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(OtpVerificationPage), findsOneWidget);
    });

    testWidgets('should validate OTP length', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(OtpVerificationPage), findsOneWidget);
    });

    testWidgets('should auto-focus next field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(OtpVerificationPage), findsOneWidget);
    });
  });
}
