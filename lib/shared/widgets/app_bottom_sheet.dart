import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final double? maxHeight;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.maxHeight,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: AppBottomSheet(
          title: title,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: maxHeight != null ? BoxConstraints(maxHeight: maxHeight!) : null,
      decoration: const BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radius2xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: AppDimensions.s12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.s24,
                  AppDimensions.s4,
                  AppDimensions.s24,
                  AppDimensions.s16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
