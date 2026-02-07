import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    group('App Info', () {
      test('appName should be DR-PHARMA', () {
        expect(AppConstants.appName, 'DR-PHARMA');
      });

      test('appVersion should be 1.0.0', () {
        expect(AppConstants.appVersion, '1.0.0');
      });
    });

    group('Storage Keys', () {
      test('keyAccessToken should have correct value', () {
        expect(AppConstants.keyAccessToken, 'access_token');
      });

      test('tokenKey should be alias for keyAccessToken', () {
        expect(AppConstants.tokenKey, AppConstants.keyAccessToken);
      });

      test('keyUserId should have correct value', () {
        expect(AppConstants.keyUserId, 'user_id');
      });

      test('keyUserEmail should have correct value', () {
        expect(AppConstants.keyUserEmail, 'user_email');
      });

      test('keyUserName should have correct value', () {
        expect(AppConstants.keyUserName, 'user_name');
      });

      test('keyUserPhone should have correct value', () {
        expect(AppConstants.keyUserPhone, 'user_phone');
      });

      test('userKey should have correct value', () {
        expect(AppConstants.userKey, 'user_data');
      });
    });

    group('Pagination', () {
      test('defaultPageSize should be 20', () {
        expect(AppConstants.defaultPageSize, 20);
      });

      test('maxPageSize should be 100', () {
        expect(AppConstants.maxPageSize, 100);
      });

      test('defaultPageSize should be less than maxPageSize', () {
        expect(AppConstants.defaultPageSize, lessThan(AppConstants.maxPageSize));
      });
    });

    group('Validation', () {
      test('minPasswordLength should be 8', () {
        expect(AppConstants.minPasswordLength, 8);
      });

      test('maxNameLength should be 100', () {
        expect(AppConstants.maxNameLength, 100);
      });

      test('minPasswordLength should be positive', () {
        expect(AppConstants.minPasswordLength, greaterThan(0));
      });
    });

    group('Phone Validation', () {
      test('phoneRegex should be valid regex', () {
        expect(() => RegExp(AppConstants.phoneRegex), returnsNormally);
      });

      test('phoneRegex should match valid phone numbers', () {
        final regex = RegExp(AppConstants.phoneRegex);
        expect(regex.hasMatch('+225 07 07 07 07'), isTrue);
        expect(regex.hasMatch('+22507070707'), isTrue);
      });

      test('phoneRegex should not match invalid phone numbers', () {
        final regex = RegExp(AppConstants.phoneRegex);
        expect(regex.hasMatch('07 07 07 07'), isFalse);
        expect(regex.hasMatch('+33 6 12 34 56 78'), isFalse);
      });

      test('phoneLengthWithPrefix should be 10', () {
        expect(AppConstants.phoneLengthWithPrefix, 10);
      });
    });

    group('Payment Modes', () {
      test('paymentModePlatform should be platform', () {
        expect(AppConstants.paymentModePlatform, 'platform');
      });

      test('paymentModeOnDelivery should be on_delivery', () {
        expect(AppConstants.paymentModeOnDelivery, 'on_delivery');
      });

      test('payment modes should be different', () {
        expect(
          AppConstants.paymentModePlatform,
          isNot(equals(AppConstants.paymentModeOnDelivery)),
        );
      });
    });

    group('Currency', () {
      test('currencyLocale should be fr_CI', () {
        expect(AppConstants.currencyLocale, 'fr_CI');
      });

      test('currencySymbol should be F CFA', () {
        expect(AppConstants.currencySymbol, 'F CFA');
      });
    });

    group('Timeouts', () {
      test('splashDuration should be 2 seconds', () {
        expect(AppConstants.splashDuration, const Duration(seconds: 2));
      });

      test('snackBarDuration should be 3 seconds', () {
        expect(AppConstants.snackBarDuration, const Duration(seconds: 3));
      });

      test('splashDuration should be a positive duration', () {
        expect(AppConstants.splashDuration.inMilliseconds, greaterThan(0));
      });

      test('snackBarDuration should be a positive duration', () {
        expect(AppConstants.snackBarDuration.inMilliseconds, greaterThan(0));
      });
    });

    group('Edge cases', () {
      test('all storage keys should be non-empty strings', () {
        expect(AppConstants.keyAccessToken, isNotEmpty);
        expect(AppConstants.tokenKey, isNotEmpty);
        expect(AppConstants.keyUserId, isNotEmpty);
        expect(AppConstants.keyUserEmail, isNotEmpty);
        expect(AppConstants.keyUserName, isNotEmpty);
        expect(AppConstants.keyUserPhone, isNotEmpty);
        expect(AppConstants.userKey, isNotEmpty);
      });

      test('pagination values should be positive', () {
        expect(AppConstants.defaultPageSize, greaterThan(0));
        expect(AppConstants.maxPageSize, greaterThan(0));
      });
    });
  });
}
