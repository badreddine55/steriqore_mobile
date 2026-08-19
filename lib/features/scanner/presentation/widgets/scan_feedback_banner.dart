import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/scanner_state.dart';

/// Clean, high-contrast, responsive inline notification banner shown during scanning
class ScanFeedbackBanner extends StatelessWidget {
  final ScannerState state;
  final VoidCallback onDismiss;

  const ScanFeedbackBanner({
    super.key,
    required this.state,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (state is ScannerLabelNotFound) {
      final notFound = state as ScannerLabelNotFound;
      return _buildInlineBanner(
        context: context,
        icon: Icons.search_off_rounded,
        title: 'Package Not Found',
        badgeText: '404',
        message: notFound.message.isNotEmpty
            ? notFound.message
            : 'Barcode not registered in the sterilization database. Verify the pouch label or use manual code entry.',
        code: notFound.code,
        accentColor: AppColors.error,
        backgroundColor: const Color(0xF21C1111),
      );
    }

    if (state is ScannerAlreadyUsed) {
      final alreadyUsed = state as ScannerAlreadyUsed;
      return _buildInlineBanner(
        context: context,
        icon: Icons.history_rounded,
        title: 'Package Already Used',
        badgeText: '409',
        message: alreadyUsed.message.isNotEmpty
            ? alreadyUsed.message
            : 'This sterilized pouch has already been recorded on a patient. It must undergo full reprocessing before reuse.',
        code: alreadyUsed.code,
        accentColor: AppColors.warning,
        backgroundColor: const Color(0xF21C1610),
      );
    }

    if (state is ScannerRateLimited) {
      final rateLimited = state as ScannerRateLimited;
      return _buildInlineBanner(
        context: context,
        icon: Icons.timer_outlined,
        title: 'Scanning Rate Limit',
        badgeText: '429',
        message: rateLimited.message.isNotEmpty
            ? '${rateLimited.message} (${rateLimited.cooldownSeconds}s cooldown)'
            : 'Too many scan requests. Please pause for ${rateLimited.cooldownSeconds}s before scanning again.',
        accentColor: AppColors.warning,
        backgroundColor: const Color(0xF21C1610),
      );
    }

    if (state is ScannerOffline) {
      final offline = state as ScannerOffline;
      return _buildInlineBanner(
        context: context,
        icon: Icons.cloud_off_rounded,
        title: 'Offline Mode Active',
        badgeText: 'OUTBOX',
        message: offline.message.isNotEmpty
            ? offline.message
            : 'Scan captured and queued in device outbox. It will sync automatically once network is restored.',
        code: offline.code,
        accentColor: AppColors.accent,
        backgroundColor: const Color(0xF2101724),
      );
    }

    if (state is ScannerError) {
      final error = state as ScannerError;
      return _buildInlineBanner(
        context: context,
        icon: Icons.error_outline_rounded,
        title: 'Scanner Notice',
        badgeText: 'NOTICE',
        message: error.message.isNotEmpty
            ? error.message
            : 'Unable to verify barcode. Please adjust lighting or reposition the sterilization pouch.',
        accentColor: AppColors.error,
        backgroundColor: const Color(0xF21C1111),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInlineBanner({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String badgeText,
    required String message,
    String? code,
    required Color accentColor,
    required Color backgroundColor,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppDimensions.s12, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.55),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 18,
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
                  color: accentColor.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeText,
                            style: AppTypography.caption.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        if (code != null && code.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                code,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.data.copyWith(
                                  fontSize: 10.5,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      message,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.90),
                        fontSize: 12.5,
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 18),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                tooltip: 'Dismiss',
                onPressed: onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
