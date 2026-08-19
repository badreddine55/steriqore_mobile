import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  final String imagePath;

  const AuthBackground({
    super.key,
    required this.child,
    this.imagePath = 'assets/images/auth_background.jpg',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer 1: Full-bleed background image
        Positioned.fill(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/dentistrack_auth_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF020617),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Layer 2: Dark overlay (solid + gradient)
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x40000000), // 25% black at top
                  Color(0x80000000), // 50% black at 30%
                  Color(0xCC000000), // 80% black at 60%
                ],
                stops: [0.0, 0.3, 0.6],
              ),
            ),
          ),
        ),

        // Layer 3: Child content
        child,
      ],
    );
  }
}
