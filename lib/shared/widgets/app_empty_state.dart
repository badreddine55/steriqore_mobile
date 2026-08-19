import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  final Widget? icon;
  final String title;
  final String? subtitle;
  final String? message;
  final String? actionLabel;
  final String? buttonLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.message,
    this.actionLabel,
    this.buttonLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final sub = message ?? subtitle ?? '';
    final btn = buttonLabel ?? actionLabel;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(AppDimensions.s20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: icon!,
              ),
              const SizedBox(height: AppDimensions.s20),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.h3,
            ),
            if (sub.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.s8),
              Text(
                sub,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall,
              ),
            ],
            if (btn != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.s24),
              AppButton.primary(
                label: btn,
                onPressed: onAction,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
