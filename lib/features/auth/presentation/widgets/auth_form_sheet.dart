import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

class AuthFormSheet extends StatelessWidget {
  final Widget child;
  final bool showDragHandle;
  final EdgeInsetsGeometry? padding;

  const AuthFormSheet({
    super.key,
    required this.child,
    this.showDragHandle = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: padding ??
          EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            AppDimensions.s24,
            AppDimensions.screenPadding,
            max(bottomSafeArea, AppDimensions.s24) + AppDimensions.s12,
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showDragHandle) ...[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle, // #E5E5EA
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.s24),
          ],
          child,
        ],
      ),
    );
  }
}
