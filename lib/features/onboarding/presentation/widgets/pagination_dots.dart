import 'package:flutter/material.dart';

class PaginationDots extends StatelessWidget {
  final int count;
  final int currentIndex;
  final double dotSize;
  final double spacing;
  final Duration animationDuration;
  final ValueChanged<int>? onDotTapped;

  const PaginationDots({
    super.key,
    required this.count,
    required this.currentIndex,
    this.dotSize = 8.0,
    this.spacing = 8.0,
    this.animationDuration = const Duration(milliseconds: 250),
    this.onDotTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final bool isActive = index == currentIndex;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onDotTapped != null ? () => onDotTapped!(index) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            margin: EdgeInsets.only(right: index == count - 1 ? 0 : spacing),
            child: AnimatedContainer(
              duration: animationDuration,
              curve: Curves.easeOutCubic,
              width: isActive ? dotSize * 3 : dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(dotSize / 2),
                color: isActive ? Colors.white : const Color(0x66FFFFFF),
              ),
            ),
          ),
        );
      }),
    );
  }
}
