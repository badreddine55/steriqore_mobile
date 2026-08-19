import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

class RoleSelectionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleSelectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  State<RoleSelectionCard> createState() => _RoleSelectionCardState();
}

class _RoleSelectionCardState extends State<RoleSelectionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundDefault, // #F2F2F7
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg), // 16px
            border: Border.all(
              color: widget.isSelected ? AppColors.primary : Colors.transparent,
              width: 2.0,
            ),
          ),
          child: Row(
            children: [
              // Left Icon in 48px circle
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: 28,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Center text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: AppTypography.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Right Chevron
              Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: widget.isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
