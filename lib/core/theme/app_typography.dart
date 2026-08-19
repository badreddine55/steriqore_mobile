import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get heroTitle => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get heroTitleInverse => heroTitle.copyWith(
        color: AppColors.textInverse,
      );

  static TextStyle get h1 => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.21,
        letterSpacing: -0.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get h2 => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.27,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get h3 => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get h4 => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.375,
        letterSpacing: -0.1,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.41,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLargeInverse => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: -0.2,
        color: const Color(0xBFFFFFFF), // 75% white
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.47,
        letterSpacing: -0.1,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.38,
        color: AppColors.textSecondary,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.1,
        color: AppColors.textTertiary,
      );

  static TextStyle get buttonLarge => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.29,
        letterSpacing: -0.2,
        color: AppColors.primaryInverse,
      );

  static TextStyle get buttonLargeDark => buttonLarge.copyWith(
        color: AppColors.primary,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: -0.1,
        color: AppColors.primaryInverse,
      );

  static TextStyle get buttonInverse => button.copyWith(
        color: AppColors.textInverse,
      );

  static TextStyle get navLabel => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.27,
        letterSpacing: 0.2,
        color: AppColors.textSecondary,
      );

  static TextStyle get dataLarge => GoogleFonts.jetBrainsMono(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get data => GoogleFonts.jetBrainsMono(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.375,
        letterSpacing: -0.1,
        color: AppColors.textPrimary,
      );
}
