import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  const GoogleSignInButton({super.key, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: double.infinity, height: 52,
      child: OutlinedButton(onPressed: onPressed,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Center(child: Text('G', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4285F4))))),
          const SizedBox(width: 12),
          Text('Continue with Google', style: AppTextStyles.button.copyWith(color: AppColors.textPrimary)),
        ])));
  }
}