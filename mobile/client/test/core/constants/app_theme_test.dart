import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drpharma_client/core/constants/app_theme.dart';
import 'package:drpharma_client/core/constants/app_colors.dart';

void main() {
  group('AppTheme', () {
    group('Light Theme - Basic Properties', () {
      test('should use Material 3', () {
        expect(AppTheme.lightTheme.useMaterial3, true);
      });

      test('should have light brightness', () {
        expect(AppTheme.lightTheme.brightness, Brightness.light);
      });

      test('should use primary color', () {
        expect(AppTheme.lightTheme.primaryColor, AppColors.primary);
      });

      test('should have white scaffold background', () {
        expect(AppTheme.lightTheme.scaffoldBackgroundColor, Colors.white);
      });
    });

    group('Light Theme - Color Scheme', () {
      test('should have correct primary color', () {
        expect(AppTheme.lightTheme.colorScheme.primary, AppColors.primary);
      });

      test('should have correct secondary color', () {
        expect(AppTheme.lightTheme.colorScheme.secondary, AppColors.secondary);
      });

      test('should have correct tertiary (accent) color', () {
        expect(AppTheme.lightTheme.colorScheme.tertiary, AppColors.accent);
      });

      test('should have correct error color', () {
        expect(AppTheme.lightTheme.colorScheme.error, AppColors.error);
      });

      test('should have white surface', () {
        expect(AppTheme.lightTheme.colorScheme.surface, Colors.white);
      });

      test('should have white onPrimary for contrast', () {
        expect(AppTheme.lightTheme.colorScheme.onPrimary, Colors.white);
      });

      test('should have white onSecondary for contrast', () {
        expect(AppTheme.lightTheme.colorScheme.onSecondary, Colors.white);
      });

      test('should have textPrimary onSurface', () {
        expect(
            AppTheme.lightTheme.colorScheme.onSurface, AppColors.textPrimary);
      });
    });

    group('Light Theme - AppBar', () {
      test('should have primary background color', () {
        expect(AppTheme.lightTheme.appBarTheme.backgroundColor,
            AppColors.primary);
      });

      test('should have white foreground color', () {
        expect(AppTheme.lightTheme.appBarTheme.foregroundColor, Colors.white);
      });

      test('should have no elevation', () {
        expect(AppTheme.lightTheme.appBarTheme.elevation, 0);
      });

      test('should not center title', () {
        expect(AppTheme.lightTheme.appBarTheme.centerTitle, false);
      });

      test('should have correct title text style', () {
        final titleStyle = AppTheme.lightTheme.appBarTheme.titleTextStyle;
        expect(titleStyle!.fontSize, 20);
        expect(titleStyle.fontWeight, FontWeight.bold);
        expect(titleStyle.color, Colors.white);
      });
    });

    group('Light Theme - Card', () {
      test('should have elevation of 2', () {
        expect(AppTheme.lightTheme.cardTheme.elevation, 2);
      });

      test('should have white color', () {
        expect(AppTheme.lightTheme.cardTheme.color, Colors.white);
      });

      test('should have rounded border radius of 12', () {
        final shape =
            AppTheme.lightTheme.cardTheme.shape as RoundedRectangleBorder;
        expect((shape.borderRadius as BorderRadius).topLeft.x, 12);
      });
    });

    group('Light Theme - Elevated Button', () {
      test('should have primary background', () {
        final style = AppTheme.lightTheme.elevatedButtonTheme.style!;
        final bgColor =
            style.backgroundColor?.resolve({}) ?? Colors.transparent;
        expect(bgColor, AppColors.primary);
      });

      test('should have white foreground', () {
        final style = AppTheme.lightTheme.elevatedButtonTheme.style!;
        final fgColor =
            style.foregroundColor?.resolve({}) ?? Colors.transparent;
        expect(fgColor, Colors.white);
      });

      test('should have elevation of 2', () {
        final style = AppTheme.lightTheme.elevatedButtonTheme.style!;
        final elevation = style.elevation?.resolve({}) ?? 0;
        expect(elevation, 2);
      });

      test('should have correct padding', () {
        final style = AppTheme.lightTheme.elevatedButtonTheme.style!;
        final padding =
            style.padding?.resolve({}) as EdgeInsets?;
        expect(padding?.horizontal, 48); // 24 * 2
        expect(padding?.vertical, 24); // 12 * 2
      });

      test('should have rounded border radius of 12', () {
        final style = AppTheme.lightTheme.elevatedButtonTheme.style!;
        final shape = style.shape?.resolve({}) as RoundedRectangleBorder;
        expect((shape.borderRadius as BorderRadius).topLeft.x, 12);
      });
    });

    group('Light Theme - Input Decoration', () {
      test('should be filled', () {
        expect(AppTheme.lightTheme.inputDecorationTheme.filled, true);
      });

      test('should have light grey fill color', () {
        expect(AppTheme.lightTheme.inputDecorationTheme.fillColor,
            Colors.grey.shade50);
      });

      test('should have correct content padding', () {
        final padding = AppTheme.lightTheme.inputDecorationTheme.contentPadding
            as EdgeInsets;
        expect(padding.horizontal, 32); // 16 * 2
        expect(padding.vertical, 32); // 16 * 2
      });

      test('focused border should use primary color', () {
        final border = AppTheme.lightTheme.inputDecorationTheme.focusedBorder
            as OutlineInputBorder;
        expect(border.borderSide.color, AppColors.primary);
        expect(border.borderSide.width, 2);
      });

      test('error border should use error color', () {
        final border = AppTheme.lightTheme.inputDecorationTheme.errorBorder
            as OutlineInputBorder;
        expect(border.borderSide.color, AppColors.error);
      });
    });

    group('Light Theme - Icon', () {
      test('should use textPrimary color', () {
        expect(AppTheme.lightTheme.iconTheme.color, AppColors.textPrimary);
      });
    });

    group('Light Theme - Text Theme', () {
      test('headlineLarge should be 32px bold', () {
        final style = AppTheme.lightTheme.textTheme.headlineLarge!;
        expect(style.fontSize, 32);
        expect(style.fontWeight, FontWeight.bold);
        expect(style.color, AppColors.textPrimary);
      });

      test('headlineMedium should be 28px bold', () {
        final style = AppTheme.lightTheme.textTheme.headlineMedium!;
        expect(style.fontSize, 28);
        expect(style.fontWeight, FontWeight.bold);
        expect(style.color, AppColors.textPrimary);
      });

      test('headlineSmall should be 24px bold', () {
        final style = AppTheme.lightTheme.textTheme.headlineSmall!;
        expect(style.fontSize, 24);
        expect(style.fontWeight, FontWeight.bold);
        expect(style.color, AppColors.textPrimary);
      });

      test('titleLarge should be 20px semibold', () {
        final style = AppTheme.lightTheme.textTheme.titleLarge!;
        expect(style.fontSize, 20);
        expect(style.fontWeight, FontWeight.w600);
        expect(style.color, AppColors.textPrimary);
      });

      test('titleMedium should be 16px semibold', () {
        final style = AppTheme.lightTheme.textTheme.titleMedium!;
        expect(style.fontSize, 16);
        expect(style.fontWeight, FontWeight.w600);
        expect(style.color, AppColors.textPrimary);
      });

      test('bodyLarge should be 16px', () {
        final style = AppTheme.lightTheme.textTheme.bodyLarge!;
        expect(style.fontSize, 16);
        expect(style.color, AppColors.textPrimary);
      });

      test('bodyMedium should be 14px', () {
        final style = AppTheme.lightTheme.textTheme.bodyMedium!;
        expect(style.fontSize, 14);
        expect(style.color, AppColors.textPrimary);
      });

      test('bodySmall should be 12px with secondary color', () {
        final style = AppTheme.lightTheme.textTheme.bodySmall!;
        expect(style.fontSize, 12);
        expect(style.color, AppColors.textSecondary);
      });

      test('text sizes should be in descending order', () {
        final theme = AppTheme.lightTheme.textTheme;
        expect(theme.headlineLarge!.fontSize,
            greaterThan(theme.headlineMedium!.fontSize!));
        expect(theme.headlineMedium!.fontSize,
            greaterThan(theme.headlineSmall!.fontSize!));
        expect(theme.headlineSmall!.fontSize,
            greaterThan(theme.titleLarge!.fontSize!));
        expect(theme.titleLarge!.fontSize,
            greaterThan(theme.titleMedium!.fontSize!));
        expect(theme.bodyLarge!.fontSize,
            greaterThan(theme.bodyMedium!.fontSize!));
        expect(theme.bodyMedium!.fontSize,
            greaterThan(theme.bodySmall!.fontSize!));
      });
    });

    group('Light Theme - FAB', () {
      test('should have primary background', () {
        expect(
            AppTheme.lightTheme.floatingActionButtonTheme.backgroundColor,
            AppColors.primary);
      });

      test('should have white foreground', () {
        expect(
            AppTheme.lightTheme.floatingActionButtonTheme.foregroundColor,
            Colors.white);
      });
    });

    group('Light Theme - SnackBar', () {
      test('should have dark background', () {
        expect(AppTheme.lightTheme.snackBarTheme.backgroundColor,
            AppColors.textPrimary);
      });

      test('should have white text', () {
        expect(AppTheme.lightTheme.snackBarTheme.contentTextStyle?.color,
            Colors.white);
      });

      test('should be floating', () {
        expect(AppTheme.lightTheme.snackBarTheme.behavior,
            SnackBarBehavior.floating);
      });

      test('should have rounded corners', () {
        final shape =
            AppTheme.lightTheme.snackBarTheme.shape as RoundedRectangleBorder;
        expect((shape.borderRadius as BorderRadius).topLeft.x, 8);
      });
    });

    group('Light Theme - Bottom Navigation', () {
      test('should have white background', () {
        expect(AppTheme.lightTheme.bottomNavigationBarTheme.backgroundColor,
            Colors.white);
      });

      test('should have primary selected color', () {
        expect(AppTheme.lightTheme.bottomNavigationBarTheme.selectedItemColor,
            AppColors.primary);
      });

      test('should have secondary unselected color', () {
        expect(
            AppTheme.lightTheme.bottomNavigationBarTheme.unselectedItemColor,
            AppColors.textSecondary);
      });

      test('should have elevation of 8', () {
        expect(
            AppTheme.lightTheme.bottomNavigationBarTheme.elevation, 8);
      });
    });

    group('Dark Theme - Basic Properties', () {
      test('should use Material 3', () {
        expect(AppTheme.darkTheme.useMaterial3, true);
      });

      test('should have dark brightness', () {
        expect(AppTheme.darkTheme.brightness, Brightness.dark);
      });

      test('should use primary color', () {
        expect(AppTheme.darkTheme.primaryColor, AppColors.primary);
      });

      test('should have dark scaffold background', () {
        expect(AppTheme.darkTheme.scaffoldBackgroundColor,
            const Color(0xFF121212));
      });
    });

    group('Dark Theme - Color Scheme', () {
      test('should have correct primary color', () {
        expect(AppTheme.darkTheme.colorScheme.primary, AppColors.primary);
      });

      test('should have correct secondary color', () {
        expect(AppTheme.darkTheme.colorScheme.secondary, AppColors.secondary);
      });

      test('should have correct tertiary (accent) color', () {
        expect(AppTheme.darkTheme.colorScheme.tertiary, AppColors.accent);
      });

      test('should have correct error color', () {
        expect(AppTheme.darkTheme.colorScheme.error, AppColors.error);
      });

      test('should have dark surface', () {
        expect(
            AppTheme.darkTheme.colorScheme.surface, const Color(0xFF1E1E1E));
      });

      test('should have white onSurface', () {
        expect(AppTheme.darkTheme.colorScheme.onSurface, Colors.white);
      });
    });

    group('Dark Theme - AppBar', () {
      test('should have dark background color', () {
        expect(AppTheme.darkTheme.appBarTheme.backgroundColor,
            const Color(0xFF1E1E1E));
      });

      test('should have white foreground color', () {
        expect(AppTheme.darkTheme.appBarTheme.foregroundColor, Colors.white);
      });

      test('should have no elevation', () {
        expect(AppTheme.darkTheme.appBarTheme.elevation, 0);
      });
    });

    group('Dark Theme - Card', () {
      test('should have dark color', () {
        expect(AppTheme.darkTheme.cardTheme.color, const Color(0xFF1E1E1E));
      });

      test('should have elevation of 2', () {
        expect(AppTheme.darkTheme.cardTheme.elevation, 2);
      });
    });

    group('Dark Theme - Input Decoration', () {
      test('should be filled', () {
        expect(AppTheme.darkTheme.inputDecorationTheme.filled, true);
      });

      test('should have dark fill color', () {
        expect(AppTheme.darkTheme.inputDecorationTheme.fillColor,
            const Color(0xFF2C2C2C));
      });

      test('focused border should use primary color', () {
        final border = AppTheme.darkTheme.inputDecorationTheme.focusedBorder
            as OutlineInputBorder;
        expect(border.borderSide.color, AppColors.primary);
        expect(border.borderSide.width, 2);
      });
    });

    group('Dark Theme - Icon', () {
      test('should use white color', () {
        expect(AppTheme.darkTheme.iconTheme.color, Colors.white);
      });
    });

    group('Dark Theme - Text Theme', () {
      test('headlineLarge should be white', () {
        expect(
            AppTheme.darkTheme.textTheme.headlineLarge!.color, Colors.white);
      });

      test('bodyLarge should be white', () {
        expect(AppTheme.darkTheme.textTheme.bodyLarge!.color, Colors.white);
      });

      test('bodySmall should be light grey', () {
        expect(AppTheme.darkTheme.textTheme.bodySmall!.color,
            const Color(0xFFB0B0B0));
      });
    });

    group('Dark Theme - SnackBar', () {
      test('should have dark background', () {
        expect(AppTheme.darkTheme.snackBarTheme.backgroundColor,
            const Color(0xFF2C2C2C));
      });

      test('should have white text', () {
        expect(AppTheme.darkTheme.snackBarTheme.contentTextStyle?.color,
            Colors.white);
      });
    });

    group('Dark Theme - Bottom Navigation', () {
      test('should have dark background', () {
        expect(AppTheme.darkTheme.bottomNavigationBarTheme.backgroundColor,
            const Color(0xFF1E1E1E));
      });

      test('should have primary selected color', () {
        expect(AppTheme.darkTheme.bottomNavigationBarTheme.selectedItemColor,
            AppColors.primary);
      });

      test('should have light grey unselected color', () {
        expect(AppTheme.darkTheme.bottomNavigationBarTheme.unselectedItemColor,
            const Color(0xFFB0B0B0));
      });
    });

    group('Theme Consistency', () {
      test('both themes should use same primary color', () {
        expect(AppTheme.lightTheme.colorScheme.primary,
            AppTheme.darkTheme.colorScheme.primary);
      });

      test('both themes should use same secondary color', () {
        expect(AppTheme.lightTheme.colorScheme.secondary,
            AppTheme.darkTheme.colorScheme.secondary);
      });

      test('both themes should use same error color', () {
        expect(AppTheme.lightTheme.colorScheme.error,
            AppTheme.darkTheme.colorScheme.error);
      });

      test('both themes should use Material 3', () {
        expect(AppTheme.lightTheme.useMaterial3, true);
        expect(AppTheme.darkTheme.useMaterial3, true);
      });

      test('both themes should have same button shape', () {
        final lightShape = AppTheme.lightTheme.elevatedButtonTheme.style?.shape
            ?.resolve({}) as RoundedRectangleBorder;
        final darkShape = AppTheme.darkTheme.elevatedButtonTheme.style?.shape
            ?.resolve({}) as RoundedRectangleBorder;
        expect(
            (lightShape.borderRadius as BorderRadius).topLeft.x,
            (darkShape.borderRadius as BorderRadius).topLeft.x);
      });

      test('both themes should have same card radius', () {
        final lightShape =
            AppTheme.lightTheme.cardTheme.shape as RoundedRectangleBorder;
        final darkShape =
            AppTheme.darkTheme.cardTheme.shape as RoundedRectangleBorder;
        expect(
            (lightShape.borderRadius as BorderRadius).topLeft.x,
            (darkShape.borderRadius as BorderRadius).topLeft.x);
      });

      test('FAB theme should be consistent across themes', () {
        expect(
            AppTheme.lightTheme.floatingActionButtonTheme.backgroundColor,
            AppTheme.darkTheme.floatingActionButtonTheme.backgroundColor);
        expect(
            AppTheme.lightTheme.floatingActionButtonTheme.foregroundColor,
            AppTheme.darkTheme.floatingActionButtonTheme.foregroundColor);
      });
    });

    group('Theme Type Check', () {
      test('lightTheme should be ThemeData', () {
        expect(AppTheme.lightTheme, isA<ThemeData>());
      });

      test('darkTheme should be ThemeData', () {
        expect(AppTheme.darkTheme, isA<ThemeData>());
      });
    });
  });
}
