import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/steriqore_shared.dart';

/// Thumb-reachable toggle button for camera flashlight / torch
class TorchToggleButton extends StatelessWidget {
  final bool isTorchOn;
  final VoidCallback onToggle;

  const TorchToggleButton({
    super.key,
    required this.isTorchOn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isTorchOn ? AppColors.accent : Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isTorchOn
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.20),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isTorchOn
                  ? AppColors.accent.withValues(alpha: 0.40)
                  : Colors.black.withValues(alpha: 0.30),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isTorchOn ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
              size: 20,
              color: isTorchOn ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 8),
            Text(
              isTorchOn ? 'Torch ON' : 'Torch OFF',
              style: steriqoreFont(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isTorchOn ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
