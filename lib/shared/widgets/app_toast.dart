import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';

enum AppToastType { success, error, warning, info }

class AppToast {
  AppToast._();

  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color bgColor;
    IconData icon;

    switch (type) {
      case AppToastType.success:
        bgColor = AppColors.success;
        icon = Icons.check_circle_rounded;
        break;
      case AppToastType.error:
        bgColor = AppColors.error;
        icon = Icons.dangerous_rounded;
        break;
      case AppToastType.warning:
        bgColor = AppColors.warning;
        icon = Icons.warning_amber_rounded;
        break;
      case AppToastType.info:
        bgColor = AppColors.accent;
        icon = Icons.info_outline_rounded;
        break;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s16, vertical: AppDimensions.s12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            boxShadow: [
              BoxShadow(
                color: bgColor.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
