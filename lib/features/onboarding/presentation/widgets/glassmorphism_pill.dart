import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';

class GlassmorphismPill extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double blur;

  const GlassmorphismPill({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.blur = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF), // rgba(255, 255, 255, 0.20)
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: const Color(0x66FFFFFF), // rgba(255, 255, 255, 0.40)
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
