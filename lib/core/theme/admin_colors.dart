import 'package:flutter/material.dart';

/// Clinical Authority Design System Tokens for Administrator Module
/// Specified in STERIQORE_ADMIN_DESIGN_SYSTEM.md
class AdminColors {
  AdminColors._();

  // Core Identity
  static const Color primary = Color(0xFF0A1628); // Deep Navy rgb(10, 22, 40)
  static const Color primaryInverse = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF0D9488); // Teal rgb(13, 148, 136)
  static const Color accentLight = Color(0xFF14B8A6); // rgb(20, 184, 166)
  static const Color accentSubtle = Color(0xFFCCFBF1); // rgb(204, 251, 241)
  static const Color secondary = Color(0xFF334155); // Slate rgb(51, 65, 85)

  // Surfaces & Backgrounds
  static const Color background = Color(0xFFF8FAFC); // Main app canvas rgb(248, 250, 252)
  static const Color surfaceElevated = Color(0xFFFFFFFF); // Cards, tables, modals
  static const Color surfaceMuted = Color(0xFFF1F5F9); // Chip default, hover, secondary
  static const Color backgroundDark = Color(0xFF0F172A); // Dark mode surfaces rgb(15, 23, 42)

  // Text
  static const Color textPrimary = Color(0xFF0F172A); // Main headings & body rgb(15, 23, 42)
  static const Color textSecondary = Color(0xFF475569); // Descriptions, metadata rgb(71, 85, 105)
  static const Color textTertiary = Color(0xFF94A3B8); // Timestamps, captions rgb(148, 163, 184)
  static const Color textInverse = Color(0xFFFFFFFF);

  // Borders
  static const Color borderSubtle = Color(0xFFE2E8F0); // Card dividers, borders rgb(226, 232, 240)
  static const Color borderStrong = Color(0xFFCBD5E1); // Focused input borders rgb(203, 213, 225)

  // Semantics & Status
  static const Color success = Color(0xFF059669); // rgb(5, 150, 105)
  static const Color successBg = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFD97706); // rgb(217, 119, 6)
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFDC2626); // rgb(220, 38, 38)
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF0D9488);
  static const Color infoBg = Color(0xFFF0FDFA);
}
