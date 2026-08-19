import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

class ScanOverlayWidget extends StatefulWidget {
  final double cutOutSize;
  final String hintText;

  const ScanOverlayWidget({
    super.key,
    this.cutOutSize = 280.0,
    this.hintText = 'Align the code within the frame',
  });

  @override
  State<ScanOverlayWidget> createState() => _ScanOverlayWidgetState();
}

class _ScanOverlayWidgetState extends State<ScanOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final maxAllowed = math.min(size.width * 0.78, size.height * 0.52);
    final cutOut = widget.cutOutSize.clamp(200.0, math.max(200.0, maxAllowed)).toDouble();
    final pillBottom = math.max(90.0, (size.height / 2) - (cutOut / 2) - 48).toDouble();

    return Stack(
      children: [
        // Darkened background vignette with transparent central window
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
                    borderRadius: BorderRadius.circular(AppDimensions.radius2xl),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Corner L-shape Brackets
        Center(
          child: SizedBox(
            width: cutOut,
            height: cutOut,
            child: Stack(
              children: [
                // Top-Left Corner
                const Positioned(
                  top: 0,
                  left: 0,
                  child: _CornerBracket(isTop: true, isLeft: true),
                ),
                // Top-Right Corner
                const Positioned(
                  top: 0,
                  right: 0,
                  child: _CornerBracket(isTop: true, isLeft: false),
                ),
                // Bottom-Left Corner
                const Positioned(
                  bottom: 0,
                  left: 0,
                  child: _CornerBracket(isTop: false, isLeft: true),
                ),
                // Bottom-Right Corner
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: _CornerBracket(isTop: false, isLeft: false),
                ),

                // Animated Laser Scan Bar
                AnimatedBuilder(
                  animation: _laserAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: cutOut * _laserAnimation.value,
                      left: 14,
                      right: 14,
                      child: Container(
                        height: 2.5,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.accent,
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.8),
                              blurRadius: 10,
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

        // Bottom Instruction Pill (Responsive safe placement)
        Positioned(
          left: 20,
          right: 20,
          bottom: pillBottom,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
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
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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
  static const double length = 28.0;
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
          top: isTop ? const BorderSide(color: Colors.white, width: thickness) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Colors.white, width: thickness) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Colors.white, width: thickness) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Colors.white, width: thickness) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(14) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(14) : Radius.zero,
          bottomLeft: !isTop && isLeft ? const Radius.circular(14) : Radius.zero,
          bottomRight: !isTop && !isLeft ? const Radius.circular(14) : Radius.zero,
        ),
      ),
    );
  }
}
