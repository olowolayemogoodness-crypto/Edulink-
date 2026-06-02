import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class ContinueButton extends StatelessWidget {
  const ContinueButton({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.play_arrow_rounded, size: 20),
        label: const Text("Continue today's lesson"),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent, foregroundColor: Colors.white,
          textStyle: AppTextStyles.button, minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
      ),
    );
  }
}