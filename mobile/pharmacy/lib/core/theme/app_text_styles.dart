import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AppTextStyles {
  AppTextStyles._();

  // Headings
  static TextStyle get h1 => GoogleFonts.poppins(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: Colors.black87,
    letterSpacing: -0.5,
  );

  static TextStyle get h2 => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    letterSpacing: -0.5,
  );

  static TextStyle get h3 => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  // Body
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
    height: 1.4,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
    height: 1.4,
  );

  // Labels / Buttons
  static TextStyle get button => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static TextStyle get label => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.grey,
    letterSpacing: 0.5,
  );
  
  // Specific Use Cases
  static TextStyle get kpiValue => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static TextStyle get kpiLabel => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Colors.grey,
  );
}
