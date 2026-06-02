
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/quiz_bloc.dart';

class QuizResultsPage extends StatefulWidget {
  const QuizResultsPage({super.key});
  @override
  State<QuizResultsPage> createState() => _QuizResultsPageState();
}

class _QuizResultsPageState extends State<QuizResultsPage> with TickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late Animation<double> _ringAnim;
  int _displayXp = 0;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    final state = context.read<QuizBloc>().state;
    if (state is QuizFinished) {
      _ringAnim = Tween<double>(begin: 0, end: state.result.accuracyPercent / 100)
          .animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeInOut));
      final xpCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
      final xpAnim = Tween<double>(begin: 0, end: state.result.xpEarned.toDouble())
          .animate(CurvedAnimation(parent: xpCtrl, curve: Curves.easeOut));
      xpAnim.addListener(() => setState(() => _displayXp = xpAnim.value.round()));
      Future.delayed(const Duration(milliseconds: 300), () { _ringCtrl.forward(); xpCtrl.forward(); });
    } else {
      _ringAnim = const AlwaysStoppedAnimation(0);
    }
  }

  @override
  void dispose() { _ringCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizBloc, QuizState>(builder: (context, state) {
      if (state is! QuizFinished) return const SizedBox();
      final r = state.result;
      final pct = r.accuracyPercent;
      final title = pct >= 80 ? 'Excellent! 🎉' : pct >= 60 ? 'Good job! 👍' : 'Keep practising 💪';
      final arcColor = pct >= 80 ? const Color(0xFF059669) : pct >= 60 ? AppColors.accent : const Color(0xFFEA580C);

      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [
            const SizedBox(height: 20),
            SizedBox(width: 130, height: 130,
              child: AnimatedBuilder(
                animation: _ringAnim,
                builder: (_, _) => CustomPaint(
                  painter: _RingPainter(progress: _ringAnim.value, color: arcColor, trackColor: AppColors.border),
                  child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('$pct%', style: GoogleFonts.dmSans(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text('accuracy', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
                  ])),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('Data Structures · Binary Trees', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textTertiary)),
            const SizedBox(height: 18),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D1E00), border: Border.all(color: const Color(0xFFC47D0E), width: 1.5),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(children: [
                Text('XP earned', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
                const SizedBox(height: 6),
                Text('+$_displayXp', style: GoogleFonts.dmSans(fontSize: 36, fontWeight: FontWeight.w600, color: const Color(0xFFE8960F))),
                Text('Base 50 · streak bonus +${r.bestStreak * 5}', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
              ]),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.5,
              children: [
                _StatTile(label: 'Correct', value: '${r.correct}', color: const Color(0xFF059669)),
                _StatTile(label: 'Incorrect', value: '${r.wrong}', color: const Color(0xFFEA580C)),
                _StatTile(label: 'Best streak', value: '${r.bestStreak}', color: AppColors.accentLight),
                _StatTile(label: 'Avg / question', value: '${r.avgTimeSeconds.round()}s', color: const Color(0xFFE8960F)),
              ],
            ),
            const SizedBox(height: 12),
            if (r.answers.isNotEmpty) Container(
              width: double.infinity, padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Quick review', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                ...r.answers.take(5).map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.background, border: Border.all(color: AppColors.border, width: 0.5), borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(shape: BoxShape.circle,
                          color: a.correct ? const Color(0xFF052E1E) : const Color(0xFF1F0A0A),
                          border: Border.all(color: a.correct ? const Color(0xFF059669) : const Color(0xFFDC2626))),
                        child: Icon(a.correct ? Icons.check_rounded : Icons.close_rounded, size: 10,
                          color: a.correct ? const Color(0xFF059669) : const Color(0xFFDC2626)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(
                        a.question.length > 48 ? '${a.question.substring(0, 48)}…' : a.question,
                        style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      )),
                    ]),
                  ),
                )),
              ]),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.read<QuizBloc>().add(QuizReset()),
              child: Container(width: double.infinity, padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(14)),
                child: Text('Try again ↻', textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () { context.read<QuizBloc>().add(QuizReset()); Navigator.pop(context); },
              child: Container(width: double.infinity, padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border, width: 0.5), borderRadius: BorderRadius.circular(14)),
                child: Text('Back to home', textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary))),
            ),
            const SizedBox(height: 24),
          ]),
        )),
      );
    });
  }
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value, style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w600, color: color)),
        Text(label, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
      ]),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color, trackColor;
  const _RingPainter({required this.progress, required this.color, required this.trackColor});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;
    canvas.drawCircle(center, radius, Paint()..style = PaintingStyle.stroke..strokeWidth = 8..color = trackColor);
    if (progress > 0) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, 2 * math.pi * progress, false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round..color = color);
    }
  }
  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
