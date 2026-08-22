import 'package:flutter/material.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_typography.dart';

class RoleBadge extends StatelessWidget {
  final String role;
  final bool isLarge;

  const RoleBadge({
    super.key,
    required this.role,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final lower = role.toLowerCase();
    Color bg;
    Color fg;
    String label;

    if (lower == 'admin' || lower == 'administrateur') {
      bg = AdminColors.primary;
      fg = AdminColors.primaryInverse;
      label = 'ADMINISTRATOR';
    } else if (lower == 'assistant' || lower == 'stock_manager') {
      bg = AdminColors.accentSubtle;
      fg = AdminColors.accent;
      label = 'STOCK MANAGER';
    } else {
      bg = AdminColors.successBg;
      fg = AdminColors.success;
      label = 'PRACTITIONER';
    }

    return Container(
      height: isLarge ? 24 : 20,
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 10 : 8,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4), // Sharp rectangular (STERIQORE_ADMIN_DESIGN_SYSTEM.md)
        border: Border.all(
          color: fg.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: AdminTypography.caption.copyWith(
            color: fg,
            fontSize: isLarge ? 11 : 9.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
