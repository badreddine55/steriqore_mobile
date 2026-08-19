import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.s16),
    this.onTap,
    this.backgroundColor = AppColors.elevated,
    this.borderColor = AppColors.borderSubtle,
    this.borderRadius = AppDimensions.radiusXl,
    this.boxShadow = const [
      BoxShadow(
        color: AppColors.cardShadow,
        blurRadius: 14,
        offset: Offset(0, 4),
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
        boxShadow: boxShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
