import 'package:flutter/material.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_typography.dart';

class UserStatusToggle extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool> onChanged;

  const UserStatusToggle({
    super.key,
    required this.isActive,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? AdminColors.successBg : AdminColors.errorBg,
        borderRadius: BorderRadius.circular(8), // 8px radius from design system
        border: Border.all(
          color: isActive
              ? AdminColors.success.withValues(alpha: 0.25)
              : AdminColors.error.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isActive ? Icons.check_circle_outline_rounded : Icons.block_rounded,
                size: 20,
                color: isActive ? AdminColors.success : AdminColors.error,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isActive ? 'Account Active' : 'Account Disabled (Soft Delete)',
                    style: AdminTypography.h4.copyWith(
                      color: isActive ? AdminColors.success : AdminColors.error,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isActive
                        ? 'User is authorized to sign in and operate'
                        : 'Access revoked · Complete audit history preserved',
                    style: AdminTypography.caption.copyWith(
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch.adaptive(
            value: isActive,
            activeTrackColor: AdminColors.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
