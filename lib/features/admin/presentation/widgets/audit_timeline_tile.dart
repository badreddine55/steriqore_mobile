import 'package:flutter/material.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/audit_entry.dart';

class AuditTimelineTile extends StatelessWidget {
  final AuditEntry entry;
  final VoidCallback onTap;

  const AuditTimelineTile({
    super.key,
    required this.entry,
    required this.onTap,
  });

  Color _getActionColor(String action) {
    switch (action.toUpperCase()) {
      case 'CREATE_USER':
      case 'ACTIVATE_USER':
      case 'VALIDATE_CYCLE':
        return AdminColors.success;
      case 'RECORD_USAGE':
        return AdminColors.accent;
      case 'UPDATE_SETTINGS':
      case 'UPDATE_USER':
        return AdminColors.warning;
      case 'DEACTIVATE_USER':
      case 'DELETE_LOT':
      case 'BLOCK_LABEL':
        return AdminColors.error;
      default:
        return AdminColors.primary;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action.toUpperCase()) {
      case 'CREATE_USER':
        return Icons.person_add_alt_1_rounded;
      case 'DEACTIVATE_USER':
        return Icons.person_off_rounded;
      case 'ACTIVATE_USER':
        return Icons.person_rounded;
      case 'VALIDATE_CYCLE':
        return Icons.verified_rounded;
      case 'RECORD_USAGE':
        return Icons.qr_code_scanner_rounded;
      case 'UPDATE_SETTINGS':
        return Icons.tune_rounded;
      default:
        return Icons.history_edu_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getActionColor(entry.action);
    final icon = _getActionIcon(entry.action);

    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.borderSubtle),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action Icon Bubble
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              entry.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AdminTypography.h4.copyWith(fontSize: 14),
                            ),
                          ),
                          Text(
                            DateFormatter.formatDateTime(entry.timestamp),
                            style: AdminTypography.caption.copyWith(
                              fontSize: 11,
                              color: AdminColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AdminColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AdminColors.borderSubtle),
                        ),
                        child: Text(
                          entry.action,
                          style: AdminTypography.caption.copyWith(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: color,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.details,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AdminTypography.bodySmall.copyWith(
                          color: AdminColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.lan_outlined, size: 12, color: AdminColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            entry.ipAddress,
                            style: AdminTypography.mono.copyWith(
                              fontSize: 11,
                              color: AdminColors.textTertiary,
                            ),
                          ),
                          if (entry.entityId != null) ...[
                            const SizedBox(width: 8),
                            const Text('·', style: TextStyle(color: AdminColors.textTertiary)),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                entry.entityId!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AdminTypography.mono.copyWith(
                                  fontSize: 11,
                                  color: AdminColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
