import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

class TorchButton extends StatelessWidget {
  final bool isTorchOn;
  final VoidCallback onToggle;

  const TorchButton({
    super.key,
    required this.isTorchOn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s16, vertical: 10),
        decoration: BoxDecoration(
          color: isTorchOn ? AppColors.accent : Colors.black.withValues(alpha: 0.60),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isTorchOn ? AppColors.accent : Colors.white.withValues(alpha: 0.20),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isTorchOn ? AppColors.accent.withValues(alpha: 0.40) : Colors.black26,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isTorchOn ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
              size: 18,
              color: isTorchOn ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: AppDimensions.s8),
            Text(
              isTorchOn ? 'Torch ON' : 'Torch OFF',
              style: AppTypography.caption.copyWith(
                color: isTorchOn ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
