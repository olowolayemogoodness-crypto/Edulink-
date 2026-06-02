import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.dmSans();

  static TextStyle get displayLarge => _base.copyWith(
        fontSize: 36, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, letterSpacing: -0.5, height: 1.1);

  static TextStyle get displayMedium => _base.copyWith(
        fontSize: 28, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, letterSpacing: -0.3, height: 1.2);

  static TextStyle get headlineLarge => _base.copyWith(
        fontSize: 24, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary, height: 1.3);

  static TextStyle get headlineMedium => _base.copyWith(
        fontSize: 20, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary, height: 1.3);

  static TextStyle get headlineSmall => _base.copyWith(
        fontSize: 18, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary, height: 1.4);

  static TextStyle get titleLarge => _base.copyWith(
        fontSize: 16, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary, height: 1.4);

  static TextStyle get titleMedium => _base.copyWith(
        fontSize: 15, fontWeight: FontWeight.w500,
        color: AppColors.textPrimary, height: 1.4);

  static TextStyle get titleSmall => _base.copyWith(
        fontSize: 14, fontWeight: FontWeight.w500,
        color: AppColors.textPrimary, height: 1.4);

  static TextStyle get bodyLarge => _base.copyWith(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: AppColors.textPrimary, height: 1.6);

  static TextStyle get bodyMedium => _base.copyWith(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: AppColors.textPrimary, height: 1.6);

  static TextStyle get bodySmall => _base.copyWith(
        fontSize: 13, fontWeight: FontWeight.w400,
        color: AppColors.textSecondary, height: 1.5);

  static TextStyle get labelLarge => _base.copyWith(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary, letterSpacing: 0.1);

  static TextStyle get labelMedium => _base.copyWith(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: AppColors.textSecondary, letterSpacing: 0.2);

  static TextStyle get labelSmall => _base.copyWith(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: AppColors.textTertiary, letterSpacing: 0.3);

  static TextStyle get caption => _base.copyWith(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: AppColors.textTertiary, height: 1.4);

  static TextStyle get button => _base.copyWith(
        fontSize: 15, fontWeight: FontWeight.w600,
        color: Colors.white, letterSpacing: 0.1);

  static TextStyle get overline => _base.copyWith(
        fontSize: 11, fontWeight: FontWeight.w600,
        color: AppColors.textTertiary, letterSpacing: 1.0);

  static TextStyle get mono => GoogleFonts.jetBrainsMono(
        fontSize: 13, fontWeight: FontWeight.w400,
        color: AppColors.textPrimary);

  static TextStyle get accentLabel =>
      labelMedium.copyWith(color: AppColors.accentLight);

  static TextStyle get streakCount => _base.copyWith(
        fontSize: 22, fontWeight: FontWeight.w700,
        color: AppColors.streak, height: 1.0);
}