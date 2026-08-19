export '../core/utils/responsive.dart';
export 'dentistrack_shared.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'dentistrack_shared.dart';

class SteriqoreColors {
  SteriqoreColors._();

  static const Color bg = AppColors.backgroundDefault;
  static const Color cardBg = AppColors.backgroundElevated;
  static const Color cardBorder = AppColors.borderSubtle;

  static const Color brand = AppColors.primary;
  static const Color accent = AppColors.accent;
  static const Color purple = AppColors.info;

  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color error = AppColors.error;

  static const Color textSecondary = AppColors.textSecondary;
  static const Color textFaint = AppColors.textTertiary;
}

TextStyle steriqoreFont({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  double letterSpacing = 0,
  Color color = AppColors.textPrimary,
  double height = 1.35,
}) {
  return dentistrackFont(
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    color: color,
    height: height,
  );
}
