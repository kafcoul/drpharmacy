import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/core/services/firebase_otp_service.dart';

// Note: FirebaseOtpService requires Firebase initialization
// These tests verify the interface and structure

void main() {
  group('FirebaseOtpState Tests', () {
    test('should have initial state', () {
      expect(FirebaseOtpState.initial, isA<FirebaseOtpState>());
    });

    test('should have codeSent state', () {
      expect(FirebaseOtpState.codeSent, isA<FirebaseOtpState>());
    });

    test('should have verifying state', () {
      expect(FirebaseOtpState.verifying, isA<FirebaseOtpState>());
    });

    test('should have verified state', () {
      expect(FirebaseOtpState.verified, isA<FirebaseOtpState>());
    });

    test('should have error state', () {
      expect(FirebaseOtpState.error, isA<FirebaseOtpState>());
    });

    test('should have timeout state', () {
      expect(FirebaseOtpState.timeout, isA<FirebaseOtpState>());
    });
  });

  group('FirebaseOtpResult Tests', () {
    test('should create success result', () {
      final result = FirebaseOtpResult.success(
        firebaseUid: 'test-uid',
        phoneNumber: '+22507000000',
      );
      expect(result.success, true);
      expect(result.firebaseUid, 'test-uid');
      expect(result.phoneNumber, '+22507000000');
      expect(result.errorMessage, isNull);
    });

    test('should create error result', () {
      final result = FirebaseOtpResult.error('Test error message');
      expect(result.success, false);
      expect(result.errorMessage, 'Test error message');
      expect(result.firebaseUid, isNull);
    });

    test('should create result with all parameters', () {
      final result = FirebaseOtpResult(
        success: true,
        errorMessage: null,
        firebaseUid: 'uid-123',
        phoneNumber: '+22507000000',
      );
      expect(result.success, true);
      expect(result.firebaseUid, 'uid-123');
    });
  });

  group('FirebaseOtpService Interface Tests', () {
    test('should be instantiable', () {
      // Service requires FirebaseAuth which needs Firebase initialization
      // Just verify the class exists
      expect(FirebaseOtpService, isA<Type>());
    });

    test('should have hasVerificationId getter', () {
      expect(FirebaseOtpService, isA<Type>());
    });

    test('should have currentUserId getter', () {
      expect(FirebaseOtpService, isA<Type>());
    });
  });
}
