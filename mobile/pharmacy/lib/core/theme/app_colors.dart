import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Palette
  static const Color primary = Color(0xFF2E7D32); // Medical Green
  static const Color primaryLight = Color(0xFFE8F5E9); // Light Green bg
  static const Color primaryDark = Color(0xFF1B5E20);

  // Secondary Palette
  static const Color secondary = Color(0xFF5C6BC0); // Soft Indigo
  static const Color secondaryLight = Color(0xFFE8EAF6);
  static const Color accent = Color(0xFF26A69A); // Teal

  // Status Colors
  static const Color success = Color(0xFF43A047);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF1E88E5);
  static const Color urgent = Color(0xFFD32F2F);

  // Status Backgrounds (Soft)
  static const Color successBg = Color(0xFFF1F8E9); // Very light green
  static const Color errorBg = Color(0xFFFFEBEE);   // Very light red
  static const Color warningBg = Color(0xFFFFF8E1); // Very light amber
  static const Color infoBg = Color(0xFFE3F2FD);    // Very light blue

  // Neutral / Foundation
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color border = Color(0xFFE0E0E0);
  
  // Shadows
  static Color shadow = const Color(0xFF8D8D8D).withOpacity(0.08);
}
