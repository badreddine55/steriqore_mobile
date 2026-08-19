import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class AppShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AppShimmer({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = AppDimensions.radiusMd,
  });

  const AppShimmer.circular({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = AppDimensions.radiusFull;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.borderSubtle,
      highlightColor: AppColors.elevated,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.borderSubtle,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
