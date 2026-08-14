import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({
    super.key,
    this.size = 44.0,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : const Color(0xFF18181B);
    final iconColor = isDark ? Colors.black : Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              Icons.shield_outlined,
              size: size * 0.55,
              color: iconColor,
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          Text(
            'Steriqore',
            style: GoogleFonts.instrumentSans(
              fontSize: size * 0.52,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: isDark ? const Color(0xFFEDEDEC) : const Color(0xFF18181B),
            ),
          ),
        ],
      ],
    );
  }
}
