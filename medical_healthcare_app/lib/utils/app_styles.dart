// lib/utils/app_styles.dart
import 'package:flutter/material.dart';
import 'package:medical_healthcare_app/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart'; // New: Import google_fonts

class AppStyles {
  // New: Using GoogleFonts.inter() for all text styles
  static TextStyle headline1 = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static TextStyle headline2 = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static TextStyle titleStyle = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );

  static TextStyle subtitleStyle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.lightTextColor,
  );

  static TextStyle bodyText1 = GoogleFonts.inter(
    fontSize: 16,
    color: AppColors.textColor,
  );

  static TextStyle bodyText2 = GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.lightTextColor,
  );

  static TextStyle buttonTextStyle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle cardTitleStyle = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );

  static TextStyle cardSubtitleStyle = GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.lightTextColor,
  );
}
