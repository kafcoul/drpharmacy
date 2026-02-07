/// Thèmes accessibles avec contraste élevé
library;

import 'package:flutter/material.dart';
import 'accessibility_utils.dart';

/// Thèmes accessibles avec contraste élevé
class AccessibleThemes {
  AccessibleThemes._();

  /// Couleurs accessibles (WCAG AA compliant)
  static const accessibleColors = AccessibleColorScheme(
    // Texte sur fond clair - ratio >= 4.5:1
    textOnLight: Color(0xFF1A1A1A),
    textSecondaryOnLight: Color(0xFF4A4A4A),
    
    // Texte sur fond sombre - ratio >= 4.5:1  
    textOnDark: Color(0xFFFAFAFA),
    textSecondaryOnDark: Color(0xFFB8B8B8),
    
    // Couleurs d'action accessibles
    primary: Color(0xFF0055AA), // Bleu accessible
    primaryOnDark: Color(0xFF4DA6FF),
    
    // États
    error: Color(0xFFC62828), // Rouge accessible
    errorOnDark: Color(0xFFFF5252),
    success: Color(0xFF2E7D32), // Vert accessible
    successOnDark: Color(0xFF69F0AE),
    warning: Color(0xFFE65100), // Orange accessible
    warningOnDark: Color(0xFFFFAB40),
    
    // Fond
    backgroundLight: Color(0xFFFFFFFF),
    backgroundDark: Color(0xFF121212),
    surfaceLight: Color(0xFFF5F5F5),
    surfaceDark: Color(0xFF1E1E1E),
  );

  /// Crée un thème clair accessible
  static ThemeData lightAccessible({
    Color? seedColor,
    bool highContrast = false,
  }) {
    final colors = highContrast
        ? _highContrastLightColors
        : accessibleColors;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        onPrimary: Colors.white,
        secondary: colors.primary,
        onSecondary: Colors.white,
        error: colors.error,
        onError: Colors.white,
        surface: colors.surfaceLight,
        onSurface: colors.textOnLight,
      ),
      scaffoldBackgroundColor: colors.backgroundLight,
      textTheme: _accessibleTextTheme(
        colors.textOnLight,
        colors.textSecondaryOnLight,
      ),
      elevatedButtonTheme: _accessibleButtonTheme(colors.primary),
      outlinedButtonTheme: _accessibleOutlinedButtonTheme(colors.primary),
      textButtonTheme: _accessibleTextButtonTheme(colors.primary),
      inputDecorationTheme: _accessibleInputTheme(colors),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      iconTheme: IconThemeData(
        color: colors.textOnLight,
        size: 24,
      ),
    );
  }

  /// Crée un thème sombre accessible
  static ThemeData darkAccessible({
    Color? seedColor,
    bool highContrast = false,
  }) {
    final colors = highContrast
        ? _highContrastDarkColors
        : accessibleColors;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: colors.primaryOnDark,
        onPrimary: colors.backgroundDark,
        secondary: colors.primaryOnDark,
        onSecondary: colors.backgroundDark,
        error: colors.errorOnDark,
        onError: colors.backgroundDark,
        surface: colors.surfaceDark,
        onSurface: colors.textOnDark,
      ),
      scaffoldBackgroundColor: colors.backgroundDark,
      textTheme: _accessibleTextTheme(
        colors.textOnDark,
        colors.textSecondaryOnDark,
      ),
      elevatedButtonTheme: _accessibleButtonTheme(colors.primaryOnDark),
      outlinedButtonTheme: _accessibleOutlinedButtonTheme(colors.primaryOnDark),
      textButtonTheme: _accessibleTextButtonTheme(colors.primaryOnDark),
      inputDecorationTheme: _accessibleInputThemeDark(colors),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surfaceDark,
        foregroundColor: colors.textOnDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colors.textOnDark,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: colors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      iconTheme: IconThemeData(
        color: colors.textOnDark,
        size: 24,
      ),
    );
  }

  /// Couleurs à contraste élevé (mode clair)
  static const _highContrastLightColors = AccessibleColorScheme(
    textOnLight: Color(0xFF000000),
    textSecondaryOnLight: Color(0xFF333333),
    textOnDark: Color(0xFFFFFFFF),
    textSecondaryOnDark: Color(0xFFCCCCCC),
    primary: Color(0xFF0000CC),
    primaryOnDark: Color(0xFF6699FF),
    error: Color(0xFFCC0000),
    errorOnDark: Color(0xFFFF6666),
    success: Color(0xFF006600),
    successOnDark: Color(0xFF66FF66),
    warning: Color(0xFFCC6600),
    warningOnDark: Color(0xFFFFAA33),
    backgroundLight: Color(0xFFFFFFFF),
    backgroundDark: Color(0xFF000000),
    surfaceLight: Color(0xFFEEEEEE),
    surfaceDark: Color(0xFF111111),
  );

  /// Couleurs à contraste élevé (mode sombre)
  static const _highContrastDarkColors = _highContrastLightColors;

  static TextTheme _accessibleTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primary,
        height: 1.3,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primary,
        height: 1.3,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: primary,
        height: 1.3,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: primary,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primary,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primary,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: primary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: primary,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: secondary,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primary,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primary,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondary,
        height: 1.4,
      ),
    );
  }

  static ElevatedButtonThemeData _accessibleButtonTheme(Color primary) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(
          A11yConstants.minTouchTargetSize,
          A11yConstants.minTouchTargetSize,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _accessibleOutlinedButtonTheme(Color primary) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        minimumSize: const Size(
          A11yConstants.minTouchTargetSize,
          A11yConstants.minTouchTargetSize,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: primary, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static TextButtonThemeData _accessibleTextButtonTheme(Color primary) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        minimumSize: const Size(
          A11yConstants.minTouchTargetSize,
          A11yConstants.minTouchTargetSize,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static InputDecorationTheme _accessibleInputTheme(AccessibleColorScheme colors) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.textSecondaryOnLight, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.textSecondaryOnLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.error, width: 2),
      ),
      labelStyle: TextStyle(
        color: colors.textOnLight,
        fontSize: 16,
      ),
      hintStyle: TextStyle(
        color: colors.textSecondaryOnLight,
        fontSize: 16,
      ),
      errorStyle: TextStyle(
        color: colors.error,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static InputDecorationTheme _accessibleInputThemeDark(AccessibleColorScheme colors) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.textSecondaryOnDark, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.textSecondaryOnDark, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.primaryOnDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.errorOnDark, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.errorOnDark, width: 2),
      ),
      labelStyle: TextStyle(
        color: colors.textOnDark,
        fontSize: 16,
      ),
      hintStyle: TextStyle(
        color: colors.textSecondaryOnDark,
        fontSize: 16,
      ),
      errorStyle: TextStyle(
        color: colors.errorOnDark,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Schéma de couleurs accessibles
class AccessibleColorScheme {
  final Color textOnLight;
  final Color textSecondaryOnLight;
  final Color textOnDark;
  final Color textSecondaryOnDark;
  final Color primary;
  final Color primaryOnDark;
  final Color error;
  final Color errorOnDark;
  final Color success;
  final Color successOnDark;
  final Color warning;
  final Color warningOnDark;
  final Color backgroundLight;
  final Color backgroundDark;
  final Color surfaceLight;
  final Color surfaceDark;

  const AccessibleColorScheme({
    required this.textOnLight,
    required this.textSecondaryOnLight,
    required this.textOnDark,
    required this.textSecondaryOnDark,
    required this.primary,
    required this.primaryOnDark,
    required this.error,
    required this.errorOnDark,
    required this.success,
    required this.successOnDark,
    required this.warning,
    required this.warningOnDark,
    required this.backgroundLight,
    required this.backgroundDark,
    required this.surfaceLight,
    required this.surfaceDark,
  });
}
