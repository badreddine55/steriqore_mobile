import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/steriqore_shared.dart';

/// Animated corner-bracket reticle overlay for DataMatrix and QR code scanning
class ScanReticleOverlay extends StatefulWidget {
  final double cutOutSize;
  final String hintText;

  const ScanReticleOverlay({
    super.key,
    this.cutOutSize = 240.0,
    this.hintText = 'Align DataMatrix or QR label within frame',
  });

  @override
  State<ScanReticleOverlay> createState() => _ScanReticleOverlayState();
}

class _ScanReticleOverlayState extends State<ScanReticleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cutOut = widget.cutOutSize.clamp(200.0, size.width * 0.75);

    return Stack(
      children: [
        // Semi-transparent dark mask with clear center hole
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.65),
            BlendMode.srcOut,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: cutOut,
                  height: cutOut,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Corner brackets frame
        Center(
          child: SizedBox(
            width: cutOut,
            height: cutOut,
            child: Stack(
              children: [
                // Top-Left corner
                const Positioned(
                  top: 0,
                  left: 0,
                  child: _CornerBracket(isTop: true, isLeft: true),
                ),
                // Top-Right corner
                const Positioned(
                  top: 0,
                  right: 0,
                  child: _CornerBracket(isTop: true, isLeft: false),
                ),
                // Bottom-Left corner
                const Positioned(
                  bottom: 0,
                  left: 0,
                  child: _CornerBracket(isTop: false, isLeft: true),
                ),
                // Bottom-Right corner
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: _CornerBracket(isTop: false, isLeft: false),
                ),

                // Animated Laser Line
                AnimatedBuilder(
                  animation: _laserAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: cutOut * _laserAnimation.value,
                      left: 12,
                      right: 12,
                      child: Container(
                        height: 2.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accent.withValues(alpha: 0.1),
                              AppColors.accent,
                              AppColors.accent.withValues(alpha: 0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.6),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Bottom instruction badge
        Positioned(
          left: 20,
          right: 20,
          bottom: (size.height / 2) - (cutOut / 2) - 60,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, size: 16, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.hintText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: steriqoreFont(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CornerBracket extends StatelessWidget {
  final bool isTop;
  final bool isLeft;
  static const double length = 26.0;
  static const double thickness = 3.5;

  const _CornerBracket({
    required this.isTop,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: length,
      height: length,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: AppColors.accent, width: thickness)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: AppColors.accent, width: thickness)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: AppColors.accent, width: thickness)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: AppColors.accent, width: thickness)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(12) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(12) : Radius.zero,
          bottomLeft: !isTop && isLeft ? const Radius.circular(12) : Radius.zero,
          bottomRight: !isTop && !isLeft ? const Radius.circular(12) : Radius.zero,
        ),
      ),
    );
  }
}
