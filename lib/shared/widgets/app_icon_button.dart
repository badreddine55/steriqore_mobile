import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor = const Color(0x26FFFFFF),
    this.iconColor = Colors.white,
    this.size = 44.0,
    this.iconSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0x40FFFFFF),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onPressed,
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
