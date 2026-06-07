import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _ctrl = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(icon: Icons.auto_awesome_rounded, iconBg: AppColors.accentSurface, iconColor: AppColors.accentLight, title: 'AI tutor,\nalways ready', body: 'Ask anything about WAEC, JAMB, IELTS or TOEFL. Gemini AI explains concepts and quizzes you step by step.'),
    _Slide(icon: Icons.emoji_events_rounded, iconBg: AppColors.successSurface, iconColor: AppColors.success, title: 'Compete &\nwin prizes', body: 'Climb the leaderboard, challenge friends in duels and enter scholarship competitions for exciting prizes.'),
    _Slide(icon: Icons.groups_rounded, iconBg: AppColors.accentSurface, iconColor: AppColors.accentLight, title: 'Live study\nrooms', body: 'Join real-time study sessions with peers. Solve Gemini quiz widgets together and learn faster as a group.'),
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _next() async {
    HapticFeedback.selectionClick();
    if (_page < 2) {
      _ctrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_onboarded', true);
      if (mounted) context.go('/student-type');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(children: [
        Align(alignment: Alignment.centerRight, child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 18, 0),
          child: GestureDetector(onTap: () => context.go('/login'), child: Text('Skip', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textTertiary))),
        )),
        Expanded(child: PageView.builder(
          controller: _ctrl,
          onPageChanged: (i) { HapticFeedback.selectionClick(); setState(() => _page = i); },
          itemCount: _slides.length,
          itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
        )),
        // Dots
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == _page ? 14 : 4, height: 4,
          decoration: BoxDecoration(color: i == _page ? AppColors.accent : AppColors.border, borderRadius: BorderRadius.circular(2)),
        ))),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: GestureDetector(
            onTap: _next,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(_page == 2 ? 'Get started' : 'Continue', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white))),
            ),
          ),
        ),
      ])),
    );
  }
}

class _Slide {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, body;
  const _Slide({required this.icon, required this.iconBg, required this.iconColor, required this.title, required this.body});
}

class _SlideView extends StatelessWidget {
  final _Slide slide;
  const _SlideView({required this.slide});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(color: slide.iconBg, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.accent, width: 1.5)),
          child: Icon(slide.icon, color: slide.iconColor, size: 38)),
        const SizedBox(height: 28),
        Text(slide.title, style: GoogleFonts.dmSans(fontSize: 26, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.3), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(slide.body, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textTertiary, height: 1.65), textAlign: TextAlign.center),
      ]),
    );
  }
}