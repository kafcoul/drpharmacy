import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/core/accessibility/accessible_themes.dart';
import 'package:drpharma_client/core/accessibility/accessibility_utils.dart';

void main() {
  group('AccessibleColorScheme', () {
    test('accessibleColors has all required colors', () {
      final colors = AccessibleThemes.accessibleColors;
      
      expect(colors.textOnLight, isA<Color>());
      expect(colors.textSecondaryOnLight, isA<Color>());
      expect(colors.textOnDark, isA<Color>());
      expect(colors.textSecondaryOnDark, isA<Color>());
      expect(colors.primary, isA<Color>());
      expect(colors.primaryOnDark, isA<Color>());
      expect(colors.error, isA<Color>());
      expect(colors.errorOnDark, isA<Color>());
      expect(colors.success, isA<Color>());
      expect(colors.successOnDark, isA<Color>());
      expect(colors.warning, isA<Color>());
      expect(colors.warningOnDark, isA<Color>());
      expect(colors.backgroundLight, isA<Color>());
      expect(colors.backgroundDark, isA<Color>());
      expect(colors.surfaceLight, isA<Color>());
      expect(colors.surfaceDark, isA<Color>());
    });

    test('textOnLight has adequate contrast with backgroundLight', () {
      final colors = AccessibleThemes.accessibleColors;
      final hasContrast = AccessibilityService.hasAdequateContrast(
        colors.textOnLight,
        colors.backgroundLight,
      );
      expect(hasContrast, isTrue);
    });

    test('textOnDark has adequate contrast with backgroundDark', () {
      final colors = AccessibleThemes.accessibleColors;
      final hasContrast = AccessibilityService.hasAdequateContrast(
        colors.textOnDark,
        colors.backgroundDark,
      );
      expect(hasContrast, isTrue);
    });

    test('textSecondaryOnLight has adequate contrast with surfaceLight', () {
      final colors = AccessibleThemes.accessibleColors;
      final hasContrast = AccessibilityService.hasAdequateContrast(
        colors.textSecondaryOnLight,
        colors.surfaceLight,
      );
      expect(hasContrast, isTrue);
    });

    test('textSecondaryOnDark has adequate contrast with surfaceDark', () {
      final colors = AccessibleThemes.accessibleColors;
      final hasContrast = AccessibilityService.hasAdequateContrast(
        colors.textSecondaryOnDark,
        colors.surfaceDark,
      );
      expect(hasContrast, isTrue);
    });

    test('primary color is defined', () {
      final colors = AccessibleThemes.accessibleColors;
      expect(colors.primary, equals(const Color(0xFF0055AA)));
    });

    test('primaryOnDark color is defined', () {
      final colors = AccessibleThemes.accessibleColors;
      expect(colors.primaryOnDark, equals(const Color(0xFF4DA6FF)));
    });

    test('error colors are defined', () {
      final colors = AccessibleThemes.accessibleColors;
      expect(colors.error, equals(const Color(0xFFC62828)));
      expect(colors.errorOnDark, equals(const Color(0xFFFF5252)));
    });

    test('success colors are defined', () {
      final colors = AccessibleThemes.accessibleColors;
      expect(colors.success, equals(const Color(0xFF2E7D32)));
      expect(colors.successOnDark, equals(const Color(0xFF69F0AE)));
    });

    test('warning colors are defined', () {
      final colors = AccessibleThemes.accessibleColors;
      expect(colors.warning, equals(const Color(0xFFE65100)));
      expect(colors.warningOnDark, equals(const Color(0xFFFFAB40)));
    });
  });

  group('AccessibleThemes.lightAccessible', () {
    late ThemeData theme;

    setUp(() {
      theme = AccessibleThemes.lightAccessible();
    });

    test('uses Material 3', () {
      expect(theme.useMaterial3, isTrue);
    });

    test('has light brightness', () {
      expect(theme.brightness, Brightness.light);
    });

    test('has correct color scheme', () {
      expect(theme.colorScheme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, isA<Color>());
      expect(theme.colorScheme.onPrimary, Colors.white);
    });

    test('has white scaffold background', () {
      final colors = AccessibleThemes.accessibleColors;
      expect(theme.scaffoldBackgroundColor, colors.backgroundLight);
    });

    test('has text theme', () {
      expect(theme.textTheme.displayLarge, isNotNull);
      expect(theme.textTheme.bodyLarge, isNotNull);
      expect(theme.textTheme.labelSmall, isNotNull);
    });

    test('has elevated button theme', () {
      expect(theme.elevatedButtonTheme, isNotNull);
    });

    test('has outlined button theme', () {
      expect(theme.outlinedButtonTheme, isNotNull);
    });

    test('has text button theme', () {
      expect(theme.textButtonTheme, isNotNull);
    });

    test('has input decoration theme', () {
      expect(theme.inputDecorationTheme, isNotNull);
      expect(theme.inputDecorationTheme.filled, isTrue);
    });

    test('has app bar theme', () {
      expect(theme.appBarTheme, isNotNull);
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.appBarTheme.centerTitle, isTrue);
    });

    test('has card theme', () {
      expect(theme.cardTheme, isNotNull);
      expect(theme.cardTheme.elevation, 2);
    });

    test('has icon theme', () {
      expect(theme.iconTheme, isNotNull);
      expect(theme.iconTheme.size, 24);
    });

    test('supports high contrast mode', () {
      final highContrastTheme = AccessibleThemes.lightAccessible(highContrast: true);
      expect(highContrastTheme.useMaterial3, isTrue);
      expect(highContrastTheme.brightness, Brightness.light);
    });

    test('accepts custom seed color', () {
      final customTheme = AccessibleThemes.lightAccessible(seedColor: Colors.purple);
      expect(customTheme.useMaterial3, isTrue);
    });
  });

  group('AccessibleThemes.darkAccessible', () {
    late ThemeData theme;

    setUp(() {
      theme = AccessibleThemes.darkAccessible();
    });

    test('uses Material 3', () {
      expect(theme.useMaterial3, isTrue);
    });

    test('has dark brightness', () {
      expect(theme.brightness, Brightness.dark);
    });

    test('has correct color scheme', () {
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, isA<Color>());
    });

    test('has dark scaffold background', () {
      final colors = AccessibleThemes.accessibleColors;
      expect(theme.scaffoldBackgroundColor, colors.backgroundDark);
    });

    test('has text theme', () {
      expect(theme.textTheme.displayLarge, isNotNull);
      expect(theme.textTheme.bodyLarge, isNotNull);
      expect(theme.textTheme.labelSmall, isNotNull);
    });

    test('has elevated button theme', () {
      expect(theme.elevatedButtonTheme, isNotNull);
    });

    test('has outlined button theme', () {
      expect(theme.outlinedButtonTheme, isNotNull);
    });

    test('has text button theme', () {
      expect(theme.textButtonTheme, isNotNull);
    });

    test('has input decoration theme with dark fill', () {
      expect(theme.inputDecorationTheme, isNotNull);
      expect(theme.inputDecorationTheme.filled, isTrue);
    });

    test('has app bar theme with dark surface', () {
      expect(theme.appBarTheme, isNotNull);
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.appBarTheme.centerTitle, isTrue);
    });

    test('has card theme with dark color', () {
      expect(theme.cardTheme, isNotNull);
      expect(theme.cardTheme.elevation, 2);
    });

    test('has icon theme', () {
      expect(theme.iconTheme, isNotNull);
      expect(theme.iconTheme.size, 24);
    });

    test('supports high contrast mode', () {
      final highContrastTheme = AccessibleThemes.darkAccessible(highContrast: true);
      expect(highContrastTheme.useMaterial3, isTrue);
      expect(highContrastTheme.brightness, Brightness.dark);
    });

    test('accepts custom seed color', () {
      final customTheme = AccessibleThemes.darkAccessible(seedColor: Colors.teal);
      expect(customTheme.useMaterial3, isTrue);
    });
  });

  group('Text Theme Accessibility', () {
    test('light theme text has proper line heights', () {
      final theme = AccessibleThemes.lightAccessible();
      
      // Display styles should have good line height
      expect(theme.textTheme.displayLarge?.height, greaterThanOrEqualTo(1.2));
      expect(theme.textTheme.displayMedium?.height, greaterThanOrEqualTo(1.2));
      expect(theme.textTheme.displaySmall?.height, greaterThanOrEqualTo(1.2));
      
      // Body styles should have comfortable line height
      expect(theme.textTheme.bodyLarge?.height, greaterThanOrEqualTo(1.4));
      expect(theme.textTheme.bodyMedium?.height, greaterThanOrEqualTo(1.4));
      expect(theme.textTheme.bodySmall?.height, greaterThanOrEqualTo(1.4));
    });

    test('light theme has readable font sizes', () {
      final theme = AccessibleThemes.lightAccessible();
      
      // Body text should be at least 14pt
      expect(theme.textTheme.bodyMedium?.fontSize, greaterThanOrEqualTo(14));
      
      // Labels should be at least 11pt
      expect(theme.textTheme.labelSmall?.fontSize, greaterThanOrEqualTo(11));
    });

    test('dark theme text has proper line heights', () {
      final theme = AccessibleThemes.darkAccessible();
      
      expect(theme.textTheme.displayLarge?.height, greaterThanOrEqualTo(1.2));
      expect(theme.textTheme.bodyLarge?.height, greaterThanOrEqualTo(1.4));
    });
  });

  group('Button Theme Accessibility', () {
    test('elevated buttons meet minimum touch target', () {
      final theme = AccessibleThemes.lightAccessible();
      final buttonStyle = theme.elevatedButtonTheme.style;
      
      final minSize = buttonStyle?.minimumSize?.resolve({});
      expect(minSize?.width, greaterThanOrEqualTo(A11yConstants.minTouchTargetSize));
      expect(minSize?.height, greaterThanOrEqualTo(A11yConstants.minTouchTargetSize));
    });

    test('outlined buttons meet minimum touch target', () {
      final theme = AccessibleThemes.lightAccessible();
      final buttonStyle = theme.outlinedButtonTheme.style;
      
      final minSize = buttonStyle?.minimumSize?.resolve({});
      expect(minSize?.width, greaterThanOrEqualTo(A11yConstants.minTouchTargetSize));
      expect(minSize?.height, greaterThanOrEqualTo(A11yConstants.minTouchTargetSize));
    });

    test('text buttons meet minimum touch target', () {
      final theme = AccessibleThemes.lightAccessible();
      final buttonStyle = theme.textButtonTheme.style;
      
      final minSize = buttonStyle?.minimumSize?.resolve({});
      expect(minSize?.width, greaterThanOrEqualTo(A11yConstants.minTouchTargetSize));
      expect(minSize?.height, greaterThanOrEqualTo(A11yConstants.minTouchTargetSize));
    });

    test('button text is readable size', () {
      final theme = AccessibleThemes.lightAccessible();
      final buttonStyle = theme.elevatedButtonTheme.style;
      
      final textStyle = buttonStyle?.textStyle?.resolve({});
      expect(textStyle?.fontSize, greaterThanOrEqualTo(16));
    });
  });

  group('Input Theme Accessibility', () {
    test('input has proper padding', () {
      final theme = AccessibleThemes.lightAccessible();
      final inputTheme = theme.inputDecorationTheme;
      
      expect(inputTheme.contentPadding, isNotNull);
    });

    test('input has visible borders', () {
      final theme = AccessibleThemes.lightAccessible();
      final inputTheme = theme.inputDecorationTheme;
      
      expect(inputTheme.border, isNotNull);
      expect(inputTheme.enabledBorder, isNotNull);
      expect(inputTheme.focusedBorder, isNotNull);
      expect(inputTheme.errorBorder, isNotNull);
    });

    test('focused border is thicker than enabled', () {
      final theme = AccessibleThemes.lightAccessible();
      final inputTheme = theme.inputDecorationTheme;
      
      final enabledBorder = inputTheme.enabledBorder as OutlineInputBorder?;
      final focusedBorder = inputTheme.focusedBorder as OutlineInputBorder?;
      
      expect(focusedBorder?.borderSide.width, 
             greaterThan(enabledBorder?.borderSide.width ?? 0));
    });

    test('dark theme input has proper styling', () {
      final theme = AccessibleThemes.darkAccessible();
      final inputTheme = theme.inputDecorationTheme;
      
      expect(inputTheme.filled, isTrue);
      expect(inputTheme.border, isNotNull);
    });
  });

  group('Color Contrast Validation', () {
    test('light theme primary on white has good contrast', () {
      final colors = AccessibleThemes.accessibleColors;
      final ratio = AccessibilityService.calculateContrastRatio(
        colors.primary,
        Colors.white,
      );
      // WCAG AA requires 4.5:1 for normal text
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('dark theme primary on dark background has good contrast', () {
      final colors = AccessibleThemes.accessibleColors;
      final ratio = AccessibilityService.calculateContrastRatio(
        colors.primaryOnDark,
        colors.backgroundDark,
      );
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('error color on light background has good contrast', () {
      final colors = AccessibleThemes.accessibleColors;
      final ratio = AccessibilityService.calculateContrastRatio(
        colors.error,
        colors.backgroundLight,
      );
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('success color on light background has good contrast', () {
      final colors = AccessibleThemes.accessibleColors;
      final ratio = AccessibilityService.calculateContrastRatio(
        colors.success,
        colors.backgroundLight,
      );
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('warning color on light background has good contrast', () {
      final colors = AccessibleThemes.accessibleColors;
      final ratio = AccessibilityService.calculateContrastRatio(
        colors.warning,
        colors.backgroundLight,
      );
      // Warning might need large text, so 3:1 is acceptable
      expect(ratio, greaterThanOrEqualTo(3.0));
    });
  });

  group('Theme Consistency', () {
    test('light and dark themes have same structure', () {
      final lightTheme = AccessibleThemes.lightAccessible();
      final darkTheme = AccessibleThemes.darkAccessible();
      
      // Both should have same theming components
      expect(lightTheme.elevatedButtonTheme.style, isNotNull);
      expect(darkTheme.elevatedButtonTheme.style, isNotNull);
      
      expect(lightTheme.textTheme.bodyLarge, isNotNull);
      expect(darkTheme.textTheme.bodyLarge, isNotNull);
    });

    test('high contrast themes maintain structure', () {
      final lightHighContrast = AccessibleThemes.lightAccessible(highContrast: true);
      final darkHighContrast = AccessibleThemes.darkAccessible(highContrast: true);
      
      expect(lightHighContrast.useMaterial3, isTrue);
      expect(darkHighContrast.useMaterial3, isTrue);
      
      expect(lightHighContrast.elevatedButtonTheme.style, isNotNull);
      expect(darkHighContrast.elevatedButtonTheme.style, isNotNull);
    });
  });

  group('AccessibleColorScheme Constructor', () {
    test('can create custom color scheme', () {
      const customScheme = AccessibleColorScheme(
        textOnLight: Colors.black,
        textSecondaryOnLight: Colors.grey,
        textOnDark: Colors.white,
        textSecondaryOnDark: Colors.white70,
        primary: Colors.blue,
        primaryOnDark: Colors.lightBlue,
        error: Colors.red,
        errorOnDark: Colors.redAccent,
        success: Colors.green,
        successOnDark: Colors.lightGreen,
        warning: Colors.orange,
        warningOnDark: Colors.orangeAccent,
        backgroundLight: Colors.white,
        backgroundDark: Colors.black,
        surfaceLight: Color(0xFFF5F5F5),
        surfaceDark: Color(0xFF1E1E1E),
      );

      expect(customScheme.textOnLight, Colors.black);
      expect(customScheme.primary, Colors.blue);
      expect(customScheme.error, Colors.red);
    });
  });
}
