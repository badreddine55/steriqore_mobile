import 'package:flutter/material.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_typography.dart';
import '../../domain/entities/cabinet_user.dart';
import 'role_badge.dart';

class UserListItem extends StatelessWidget {
  final CabinetUser user;
  final VoidCallback onTap;

  const UserListItem({
    super.key,
    required this.user,
    required this.onTap,
  });

  String get _initials {
    final parts = user.name.trim().split(RegExp(r'\s+'));
    final letters = parts.take(2).map((w) => w.isNotEmpty ? w[0] : '').join();
    return letters.isNotEmpty ? letters.toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12), // 12px radius from design system
        border: Border.all(
          color: user.isActive ? AdminColors.borderSubtle : AdminColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Avatar with circular border
                CircleAvatar(
                  radius: 20,
                  backgroundColor: user.isActive ? AdminColors.primary : AdminColors.surfaceMuted,
                  child: Text(
                    _initials,
                    style: TextStyle(
                      color: user.isActive ? AdminColors.primaryInverse : AdminColors.textTertiary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Main info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AdminTypography.h4.copyWith(
                                color: user.isActive ? AdminColors.textPrimary : AdminColors.textTertiary,
                                decoration: user.isActive ? null : TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                          if (!user.isActive) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AdminColors.errorBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'DISABLED',
                                style: AdminTypography.caption.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AdminColors.error,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AdminTypography.caption.copyWith(color: AdminColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          RoleBadge(role: user.role),
                          if (user.cabinetRoom != null) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '· ${user.cabinetRoom}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AdminTypography.caption.copyWith(
                                  fontSize: 11,
                                  color: AdminColors.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AdminColors.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
