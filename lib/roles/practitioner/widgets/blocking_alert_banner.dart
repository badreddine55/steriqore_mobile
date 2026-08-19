import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/steriqore_shared.dart';

/// Full-width prominent compliance alert banner for safety gates (410 Expired/Recalled or 409 Conflict)
class BlockingAlertBanner extends StatelessWidget {
  final String title;
  final String message;
  final bool isBlocking; // Red 410 gate vs Amber 409 warning
  final VoidCallback? onDetails;

  const BlockingAlertBanner.blocked({
    super.key,
    this.title = 'CRITICAL COMPLIANCE GATE: INSTRUMENT BLOCKED',
    required this.message,
    this.onDetails,
  }) : isBlocking = true;

  const BlockingAlertBanner.warning({
    super.key,
    this.title = 'ATTENTION: USAGE NOTICE',
    required this.message,
    this.onDetails,
  }) : isBlocking = false;

  @override
  Widget build(BuildContext context) {
    final color = isBlocking ? AppColors.error : AppColors.warning;
    final icon = isBlocking ? Icons.gpp_bad_rounded : Icons.warning_amber_rounded;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: steriqoreFont(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: steriqoreFont(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isBlocking) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Recording patient usage is strictly locked to protect patient safety and audit traceability.',
                    style: steriqoreFont(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
