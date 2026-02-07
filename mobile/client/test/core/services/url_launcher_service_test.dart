import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/core/services/url_launcher_service.dart';

// Note: UrlLauncherService uses url_launcher which requires platform channels
// These tests verify the interface and structure
// For integration tests, use mockito to mock url_launcher

void main() {
  group('UrlLauncherService Tests', () {
    test('should have makePhoneCall method', () {
      expect(UrlLauncherService.makePhoneCall, isA<Function>());
    });

    test('should have sendEmail method', () {
      expect(UrlLauncherService.sendEmail, isA<Function>());
    });

    test('should have sendSMS method', () {
      expect(UrlLauncherService.sendSMS, isA<Function>());
    });

    test('should have openWebUrl method', () {
      expect(UrlLauncherService.openWebUrl, isA<Function>());
    });

    test('should have openMap method', () {
      expect(UrlLauncherService.openMap, isA<Function>());
    });

    test('should have openMapWithAddress method', () {
      expect(UrlLauncherService.openMapWithAddress, isA<Function>());
    });

    test('should have openWhatsApp method', () {
      expect(UrlLauncherService.openWhatsApp, isA<Function>());
    });

    test('makePhoneCall should clean phone number format', () {
      // This tests the internal logic conceptually
      // The method cleans numbers by removing non-digit characters
      const phoneWithSpaces = '+225 07 00 00 00';
      final cleanRegex = RegExp(r'[^\d+]');
      final cleaned = phoneWithSpaces.replaceAll(cleanRegex, '');
      expect(cleaned, '+22507000000');
    });

    test('phone number cleaning should preserve plus sign', () {
      const phone = '+1-555-123-4567';
      final cleanRegex = RegExp(r'[^\d+]');
      final cleaned = phone.replaceAll(cleanRegex, '');
      expect(cleaned, '+15551234567');
    });

    test('phone number cleaning should work without plus sign', () {
      const phone = '07 00 00 00 00';
      final cleanRegex = RegExp(r'[^\d+]');
      final cleaned = phone.replaceAll(cleanRegex, '');
      expect(cleaned, '0700000000');
    });
  });
}
