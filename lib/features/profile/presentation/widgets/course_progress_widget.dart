import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class CourseProgressWidget extends StatefulWidget {
  const CourseProgressWidget({super.key});
  @override
  State<CourseProgressWidget> createState() => _State();
}

class _State extends State<CourseProgressWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _ctrl.forward(); });
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _anim, builder: (_, _) => Column(children: [
      _CourseCard(emoji: '💻', emojiBg: const Color(0xFF1E1D3A),
          title: 'Data Structures & Algorithms', sub: '12 of 18 modules · Exam in 21 days',
          progress: _anim.value * 0.67, pColor: const Color(0xFF534AB7), pLabel: '67%',
          sLabel: 'On track', sBg: const Color(0xFF1E2E1A), sColor: const Color(0xFF3B6D11),
          nLabel: 'Next: Binary Trees'),
      const SizedBox(height: 8),
      _CourseCard(emoji: '🌍', emojiBg: const Color(0xFF0D2219),
          title: 'IELTS Preparation', sub: 'Reading · Writing · Listening · Speaking',
          progress: _anim.value * 0.48, pColor: const Color(0xFF1D9E75), pLabel: '48%',
          sLabel: 'Needs focus', sBg: const Color(0xFF2E1A0F), sColor: const Color(0xFFD85A30),
          nLabel: 'Next: Writing Task 2'),
    ]));
  }
}

class _CourseCard extends StatelessWidget {
  final String emoji, title, sub, pLabel, sLabel, nLabel;
  final Color emojiBg, pColor, sBg, sColor;
  final double progress;
  const _CourseCard({required this.emoji, required this.emojiBg, required this.title,
      required this.sub, required this.progress, required this.pColor, required this.pLabel,
      required this.sLabel, required this.sBg, required this.sColor, required this.nLabel});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1A1A18), borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Row(children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(color: emojiBg, borderRadius: BorderRadius.circular(9)),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 15)))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            Text(sub, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
          ])),
          Text(pLabel, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: pColor)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(value: progress, minHeight: 4,
                backgroundColor: const Color(0xFF222222), valueColor: AlwaysStoppedAnimation(pColor))),
        const SizedBox(height: 7),
        Row(children: [
          _Tag(label: sLabel, bg: sBg, color: sColor),
          const SizedBox(width: 5),
          _Tag(label: nLabel, bg: const Color(0xFF1E1D3A), color: const Color(0xFFAFA9EC)),
        ]),
      ]),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label; final Color bg, color;
  const _Tag({required this.label, required this.bg, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500, color: color)));
  }
}
