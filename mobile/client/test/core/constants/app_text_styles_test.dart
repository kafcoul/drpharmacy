import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/core/constants/app_text_styles.dart';
import 'package:drpharma_client/core/constants/app_colors.dart';

void main() {
  group('AppTextStyles', () {
    group('Heading Styles', () {
      test('heading1 should have correct font size', () {
        expect(AppTextStyles.heading1.fontSize, 28);
      });

      test('heading1 should be bold', () {
        expect(AppTextStyles.heading1.fontWeight, FontWeight.bold);
      });

      test('heading1 should use textPrimary color', () {
        expect(AppTextStyles.heading1.color, AppColors.textPrimary);
      });

      test('heading1 should have negative letter spacing', () {
        expect(AppTextStyles.heading1.letterSpacing, -0.5);
      });

      test('heading2 should have correct font size', () {
        expect(AppTextStyles.heading2.fontSize, 24);
      });

      test('heading2 should be bold', () {
        expect(AppTextStyles.heading2.fontWeight, FontWeight.bold);
      });

      test('heading2 should use textPrimary color', () {
        expect(AppTextStyles.heading2.color, AppColors.textPrimary);
      });

      test('heading3 should have correct font size', () {
        expect(AppTextStyles.heading3.fontSize, 20);
      });

      test('heading3 should be semibold', () {
        expect(AppTextStyles.heading3.fontWeight, FontWeight.w600);
      });

      test('heading3 should use textPrimary color', () {
        expect(AppTextStyles.heading3.color, AppColors.textPrimary);
      });

      test('heading4 should have correct font size', () {
        expect(AppTextStyles.heading4.fontSize, 18);
      });

      test('heading4 should be semibold', () {
        expect(AppTextStyles.heading4.fontWeight, FontWeight.w600);
      });

      test('heading4 should use textPrimary color', () {
        expect(AppTextStyles.heading4.color, AppColors.textPrimary);
      });

      test('headings should be in descending size order', () {
        expect(AppTextStyles.heading1.fontSize!,
            greaterThan(AppTextStyles.heading2.fontSize!));
        expect(AppTextStyles.heading2.fontSize!,
            greaterThan(AppTextStyles.heading3.fontSize!));
        expect(AppTextStyles.heading3.fontSize!,
            greaterThan(AppTextStyles.heading4.fontSize!));
      });
    });

    group('Body Styles', () {
      test('bodyLarge should have correct font size', () {
        expect(AppTextStyles.bodyLarge.fontSize, 16);
      });

      test('bodyLarge should have normal weight', () {
        expect(AppTextStyles.bodyLarge.fontWeight, FontWeight.normal);
      });

      test('bodyLarge should have line height', () {
        expect(AppTextStyles.bodyLarge.height, 1.5);
      });

      test('bodyLarge should use textPrimary color', () {
        expect(AppTextStyles.bodyLarge.color, AppColors.textPrimary);
      });

      test('bodyMedium should have correct font size', () {
        expect(AppTextStyles.bodyMedium.fontSize, 14);
      });

      test('bodyMedium should have normal weight', () {
        expect(AppTextStyles.bodyMedium.fontWeight, FontWeight.normal);
      });

      test('bodyMedium should have line height', () {
        expect(AppTextStyles.bodyMedium.height, 1.4);
      });

      test('bodySmall should have correct font size', () {
        expect(AppTextStyles.bodySmall.fontSize, 12);
      });

      test('bodySmall should have normal weight', () {
        expect(AppTextStyles.bodySmall.fontWeight, FontWeight.normal);
      });

      test('bodySmall should use textSecondary color', () {
        expect(AppTextStyles.bodySmall.color, AppColors.textSecondary);
      });

      test('body styles should be in descending size order', () {
        expect(AppTextStyles.bodyLarge.fontSize!,
            greaterThan(AppTextStyles.bodyMedium.fontSize!));
        expect(AppTextStyles.bodyMedium.fontSize!,
            greaterThan(AppTextStyles.bodySmall.fontSize!));
      });
    });

    group('Label Styles', () {
      test('buttonLabel should have correct font size', () {
        expect(AppTextStyles.buttonLabel.fontSize, 16);
      });

      test('buttonLabel should be bold', () {
        expect(AppTextStyles.buttonLabel.fontWeight, FontWeight.bold);
      });

      test('buttonLabel should have letter spacing', () {
        expect(AppTextStyles.buttonLabel.letterSpacing, 0.5);
      });

      test('fieldLabel should have correct font size', () {
        expect(AppTextStyles.fieldLabel.fontSize, 14);
      });

      test('fieldLabel should be medium weight', () {
        expect(AppTextStyles.fieldLabel.fontWeight, FontWeight.w500);
      });

      test('fieldLabel should use textSecondary color', () {
        expect(AppTextStyles.fieldLabel.color, AppColors.textSecondary);
      });

      test('hint should have correct font size', () {
        expect(AppTextStyles.hint.fontSize, 14);
      });

      test('hint should have normal weight', () {
        expect(AppTextStyles.hint.fontWeight, FontWeight.normal);
      });

      test('hint should use textHint color', () {
        expect(AppTextStyles.hint.color, AppColors.textHint);
      });
    });

    group('Price Styles', () {
      test('priceLarge should have correct font size', () {
        expect(AppTextStyles.priceLarge.fontSize, 24);
      });

      test('priceLarge should be bold', () {
        expect(AppTextStyles.priceLarge.fontWeight, FontWeight.bold);
      });

      test('priceLarge should use primary color', () {
        expect(AppTextStyles.priceLarge.color, AppColors.primary);
      });

      test('price should have correct font size', () {
        expect(AppTextStyles.price.fontSize, 18);
      });

      test('price should be bold', () {
        expect(AppTextStyles.price.fontWeight, FontWeight.bold);
      });

      test('price should use primary color', () {
        expect(AppTextStyles.price.color, AppColors.primary);
      });

      test('priceSmall should have correct font size', () {
        expect(AppTextStyles.priceSmall.fontSize, 14);
      });

      test('priceSmall should be semibold', () {
        expect(AppTextStyles.priceSmall.fontWeight, FontWeight.w600);
      });

      test('priceSmall should use primary color', () {
        expect(AppTextStyles.priceSmall.color, AppColors.primary);
      });

      test('price styles should be in descending size order', () {
        expect(AppTextStyles.priceLarge.fontSize!,
            greaterThan(AppTextStyles.price.fontSize!));
        expect(AppTextStyles.price.fontSize!,
            greaterThan(AppTextStyles.priceSmall.fontSize!));
      });
    });

    group('Special Styles', () {
      test('badge should have correct font size', () {
        expect(AppTextStyles.badge.fontSize, 12);
      });

      test('badge should be semibold', () {
        expect(AppTextStyles.badge.fontWeight, FontWeight.w600);
      });

      test('badge should be white', () {
        expect(AppTextStyles.badge.color, Colors.white);
      });

      test('caption should have correct font size', () {
        expect(AppTextStyles.caption.fontSize, 11);
      });

      test('caption should have normal weight', () {
        expect(AppTextStyles.caption.fontWeight, FontWeight.normal);
      });

      test('caption should use textHint color', () {
        expect(AppTextStyles.caption.color, AppColors.textHint);
      });

      test('caption should be smallest text', () {
        expect(AppTextStyles.caption.fontSize!,
            lessThan(AppTextStyles.bodySmall.fontSize!));
      });

      test('link should have correct font size', () {
        expect(AppTextStyles.link.fontSize, 14);
      });

      test('link should be medium weight', () {
        expect(AppTextStyles.link.fontWeight, FontWeight.w500);
      });

      test('link should use primary color', () {
        expect(AppTextStyles.link.color, AppColors.primary);
      });

      test('link should have underline decoration', () {
        expect(AppTextStyles.link.decoration, TextDecoration.underline);
      });
    });

    group('Status Styles', () {
      test('error should have correct font size', () {
        expect(AppTextStyles.error.fontSize, 12);
      });

      test('error should have normal weight', () {
        expect(AppTextStyles.error.fontWeight, FontWeight.normal);
      });

      test('error should use error color', () {
        expect(AppTextStyles.error.color, AppColors.error);
      });

      test('success should have correct font size', () {
        expect(AppTextStyles.success.fontSize, 12);
      });

      test('success should have normal weight', () {
        expect(AppTextStyles.success.fontWeight, FontWeight.normal);
      });

      test('success should use success color', () {
        expect(AppTextStyles.success.color, AppColors.success);
      });

      test('error and success should have same size', () {
        expect(AppTextStyles.error.fontSize, AppTextStyles.success.fontSize);
      });
    });

    group('withColor Helper', () {
      test('should return new style with specified color', () {
        final originalStyle = AppTextStyles.bodyMedium;
        final newStyle = AppTextStyles.withColor(originalStyle, Colors.red);

        expect(newStyle.color, Colors.red);
        expect(newStyle.fontSize, originalStyle.fontSize);
        expect(newStyle.fontWeight, originalStyle.fontWeight);
      });

      test('should not modify original style', () {
        final originalStyle = AppTextStyles.bodyMedium;
        final originalColor = originalStyle.color;

        AppTextStyles.withColor(originalStyle, Colors.blue);

        expect(originalStyle.color, originalColor);
      });

      test('should work with any TextStyle', () {
        final customStyle = const TextStyle(fontSize: 20);
        final result = AppTextStyles.withColor(customStyle, Colors.green);

        expect(result.color, Colors.green);
        expect(result.fontSize, 20);
      });
    });

    group('forDarkMode Helper', () {
      test('should convert textPrimary to white', () {
        final style = const TextStyle(color: AppColors.textPrimary);
        final darkStyle = AppTextStyles.forDarkMode(style);

        expect(darkStyle.color, Colors.white);
      });

      test('should convert textSecondary to grey[400]', () {
        final style = const TextStyle(color: AppColors.textSecondary);
        final darkStyle = AppTextStyles.forDarkMode(style);

        expect(darkStyle.color, Colors.grey[400]);
      });

      test('should not modify other colors', () {
        final style = const TextStyle(color: Colors.red);
        final darkStyle = AppTextStyles.forDarkMode(style);

        expect(darkStyle.color, Colors.red);
      });

      test('should preserve other properties when converting', () {
        final style = const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        );
        final darkStyle = AppTextStyles.forDarkMode(style);

        expect(darkStyle.color, Colors.white);
        expect(darkStyle.fontSize, 16);
        expect(darkStyle.fontWeight, FontWeight.bold);
      });

      test('should handle heading1 correctly', () {
        final darkStyle = AppTextStyles.forDarkMode(AppTextStyles.heading1);

        expect(darkStyle.color, Colors.white);
        expect(darkStyle.fontSize, AppTextStyles.heading1.fontSize);
        expect(darkStyle.fontWeight, AppTextStyles.heading1.fontWeight);
      });

      test('should handle bodySmall correctly', () {
        final darkStyle = AppTextStyles.forDarkMode(AppTextStyles.bodySmall);

        expect(darkStyle.color, Colors.grey[400]);
      });

      test('should not modify primary color styles', () {
        final darkStyle = AppTextStyles.forDarkMode(AppTextStyles.price);

        expect(darkStyle.color, AppColors.primary);
      });
    });

    group('Typography Hierarchy', () {
      test('all heading sizes should be larger than body sizes', () {
        final smallestHeading = AppTextStyles.heading4.fontSize!;
        final largestBody = AppTextStyles.bodyLarge.fontSize!;

        expect(smallestHeading, greaterThan(largestBody));
      });

      test('all body sizes should be larger than caption', () {
        final smallestBody = AppTextStyles.bodySmall.fontSize!;
        final captionSize = AppTextStyles.caption.fontSize!;

        expect(smallestBody, greaterThan(captionSize));
      });

      test('buttonLabel should be same size as bodyLarge', () {
        expect(
            AppTextStyles.buttonLabel.fontSize, AppTextStyles.bodyLarge.fontSize);
      });
    });

    group('Font Weight Consistency', () {
      test('all heading styles should be at least semibold', () {
        final headings = [
          AppTextStyles.heading1,
          AppTextStyles.heading2,
          AppTextStyles.heading3,
          AppTextStyles.heading4,
        ];

        for (final heading in headings) {
          expect(heading.fontWeight!.index,
              greaterThanOrEqualTo(FontWeight.w600.index));
        }
      });

      test('all body styles should be normal weight', () {
        final bodies = [
          AppTextStyles.bodyLarge,
          AppTextStyles.bodyMedium,
          AppTextStyles.bodySmall,
        ];

        for (final body in bodies) {
          expect(body.fontWeight, FontWeight.normal);
        }
      });

      test('all price styles should be at least semibold', () {
        final prices = [
          AppTextStyles.priceLarge,
          AppTextStyles.price,
          AppTextStyles.priceSmall,
        ];

        for (final price in prices) {
          expect(price.fontWeight!.index,
              greaterThanOrEqualTo(FontWeight.w600.index));
        }
      });
    });

    group('Color Consistency', () {
      test('primary text elements should use textPrimary', () {
        expect(AppTextStyles.heading1.color, AppColors.textPrimary);
        expect(AppTextStyles.heading2.color, AppColors.textPrimary);
        expect(AppTextStyles.heading3.color, AppColors.textPrimary);
        expect(AppTextStyles.heading4.color, AppColors.textPrimary);
        expect(AppTextStyles.bodyLarge.color, AppColors.textPrimary);
        expect(AppTextStyles.bodyMedium.color, AppColors.textPrimary);
      });

      test('secondary text elements should use textSecondary', () {
        expect(AppTextStyles.bodySmall.color, AppColors.textSecondary);
        expect(AppTextStyles.fieldLabel.color, AppColors.textSecondary);
      });

      test('hint elements should use textHint', () {
        expect(AppTextStyles.hint.color, AppColors.textHint);
        expect(AppTextStyles.caption.color, AppColors.textHint);
      });

      test('accent elements should use primary color', () {
        expect(AppTextStyles.priceLarge.color, AppColors.primary);
        expect(AppTextStyles.price.color, AppColors.primary);
        expect(AppTextStyles.priceSmall.color, AppColors.primary);
        expect(AppTextStyles.link.color, AppColors.primary);
      });
    });

    group('Line Height', () {
      test('bodyLarge should have optimal reading line height', () {
        expect(AppTextStyles.bodyLarge.height, 1.5);
      });

      test('bodyMedium should have optimal reading line height', () {
        expect(AppTextStyles.bodyMedium.height, 1.4);
      });

      test('bodySmall should have optimal reading line height', () {
        expect(AppTextStyles.bodySmall.height, 1.4);
      });

      test('body line heights should be between 1.4 and 1.6', () {
        final bodies = [
          AppTextStyles.bodyLarge,
          AppTextStyles.bodyMedium,
          AppTextStyles.bodySmall,
        ];

        for (final body in bodies) {
          expect(body.height, greaterThanOrEqualTo(1.4));
          expect(body.height, lessThanOrEqualTo(1.6));
        }
      });
    });

    group('Readability', () {
      test('minimum font size should be at least 11', () {
        final allStyles = [
          AppTextStyles.heading1,
          AppTextStyles.heading2,
          AppTextStyles.heading3,
          AppTextStyles.heading4,
          AppTextStyles.bodyLarge,
          AppTextStyles.bodyMedium,
          AppTextStyles.bodySmall,
          AppTextStyles.buttonLabel,
          AppTextStyles.fieldLabel,
          AppTextStyles.hint,
          AppTextStyles.priceLarge,
          AppTextStyles.price,
          AppTextStyles.priceSmall,
          AppTextStyles.badge,
          AppTextStyles.caption,
          AppTextStyles.link,
          AppTextStyles.error,
          AppTextStyles.success,
        ];

        for (final style in allStyles) {
          expect(style.fontSize, greaterThanOrEqualTo(11));
        }
      });

      test('maximum font size should not exceed 28', () {
        final allStyles = [
          AppTextStyles.heading1,
          AppTextStyles.heading2,
          AppTextStyles.heading3,
          AppTextStyles.heading4,
          AppTextStyles.priceLarge,
          AppTextStyles.price,
          AppTextStyles.priceSmall,
        ];

        for (final style in allStyles) {
          expect(style.fontSize, lessThanOrEqualTo(28));
        }
      });
    });
  });
}
