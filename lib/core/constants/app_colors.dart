import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background     = Color(0xFF0D0D0F);
  static const Color surface        = Color(0xFF1A1A1F);
  static const Color surfaceVariant = Color(0xFF222228);
  static const Color card           = Color(0xFF1E1E24);

  static const Color accent         = Color(0xFF7C3AED);
  static const Color accentLight    = Color(0xFF9F67F5);
  static const Color accentDark     = Color(0xFF5B21B6);
  static const Color accentSurface  = Color(0xFF2D1B69);

  static const Color textPrimary    = Color(0xFFF5F5F7);
  static const Color textSecondary  = Color(0xFFAAAAAF);
  static const Color textTertiary   = Color(0xFF6B6B74);
  static const Color textDisabled   = Color(0xFF44444A);

  static const Color border         = Color(0xFF2A2A32);
  static const Color borderFocus    = Color(0xFF7C3AED);

  static const Color success        = Color(0xFF22C55E);
  static const Color successSurface = Color(0xFF0F2A1A);
  static const Color warning        = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFF2A1F0A);
  static const Color error          = Color(0xFFEF4444);
  static const Color errorSurface   = Color(0xFF2A0F0F);
  static const Color info           = Color(0xFF3B82F6);
  static const Color infoSurface    = Color(0xFF0F1A2A);

  static const Color streak         = Color(0xFFFF6B2B);
  static const Color gold           = Color(0xFFFFD700);
  static const Color silver         = Color(0xFFC0C0C0);
  static const Color bronze         = Color(0xFFCD7F32);
  static const Color xp             = Color(0xFF06B6D4);

  static const Color chart1         = Color(0xFF7C3AED);
  static const Color chart2         = Color(0xFF06B6D4);
  static const Color chart3         = Color(0xFF22C55E);
  static const Color chart4         = Color(0xFFF59E0B);
  static const Color chart5         = Color(0xFFEF4444);

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF9F67F5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient streakGradient = LinearGradient(
    colors: [Color(0xFFFF6B2B), Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1E24), Color(0xFF222228)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}