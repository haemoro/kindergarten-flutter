import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle _workSans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.onSurface,
    double height = 1.4,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.workSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Headline Styles
  static TextStyle get headline1 => _workSans(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static TextStyle get headline2 => _workSans(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.5,
  );

  static TextStyle get headline3 => _workSans(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.3,
  );

  static TextStyle get headline4 => _workSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle get headline5 => _workSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle get headline6 => _workSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Body Styles
  static TextStyle get body1 => _workSans(
    fontSize: 16,
    height: 1.5,
  );

  static TextStyle get body2 => _workSans(
    fontSize: 14,
    height: 1.5,
  );

  // Caption & Overline
  static TextStyle get caption => _workSans(
    fontSize: 12,
    color: AppColors.gray600,
  );

  static TextStyle get overline => _workSans(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.gray600,
    letterSpacing: 1.5,
  );

  // Button Styles
  static TextStyle get button => _workSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.25,
  );

  // App Specific Styles
  static TextStyle get kindergartenName => _workSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get kindergartenAddress => _workSans(
    fontSize: 14,
    color: AppColors.gray600,
  );

  static TextStyle get distanceText => _workSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static TextStyle get badgeText => _workSans(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  static TextStyle get tabText => _workSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get sectionTitle => _workSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get tableHeader => _workSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.gray700,
  );

  static TextStyle get tableContent => _workSans(
    fontSize: 14,
  );

  static TextStyle get chipText => _workSans(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get errorText => _workSans(
    fontSize: 14,
    color: AppColors.error,
  );

  static TextStyle get emptyStateTitle => _workSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.gray600,
  );

  static TextStyle get emptyStateSubtitle => _workSans(
    fontSize: 14,
    color: AppColors.gray500,
  );
}
