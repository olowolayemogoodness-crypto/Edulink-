import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();

    // Navigate to home after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.accentSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: AppColors.accent, width: 1.5),
                  ),
                  child: const Icon(Icons.bolt_rounded,
                      color: AppColors.accentLight, size: 44),
                ),
                const SizedBox(height: 20),
                Text('EduLink',
                    style: AppTextStyles.displayMedium),
                const SizedBox(height: 8),
                Text('AI-powered learning',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}