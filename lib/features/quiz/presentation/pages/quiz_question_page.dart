
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/quiz_bloc.dart';
import '../../domain/models/quiz_question.dart';

class QuizQuestionPage extends StatefulWidget {
  const QuizQuestionPage({super.key});
  @override
  State<QuizQuestionPage> createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage> with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _timerSecs = 30;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timerSecs = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _timerSecs--);
      if (_timerSecs <= 0) { t.cancel(); context.read<QuizBloc>().add(QuizTimedOut()); }
    });
  }

  void _stopTimer() => _timer?.cancel();

  @override
  void dispose() { _timer?.cancel(); _fadeCtrl.dispose(); super.dispose(); }

  void _onAnswer(int idx) {
    _stopTimer();
    final elapsed = 30 - _timerSecs;
    context.read<QuizBloc>().add(QuizAnswerSelected(selectedIndex: idx, secondsTaken: elapsed));
  }

  void _onNext(QuizInProgress s) {
    if (!s.isLastQuestion) { _fadeCtrl.reset(); _startTimer(); _fadeCtrl.forward(); }
    context.read<QuizBloc>().add(QuizNextQuestion());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizBloc, QuizState>(
      builder: (context, state) {
        if (state is! QuizInProgress) return const SizedBox();
        final s = state;
        final isTimed = s.mode == QuizMode.timed;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Row(children: [
                GestureDetector(
                  onTap: () { _stopTimer(); context.read<QuizBloc>().add(QuizReset()); },
                  child: const Icon(Icons.close_rounded, color: AppColors.textTertiary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Question ${s.currentIndex + 1} of ${s.questions.length}',
                      style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
                    Text('+${50 + s.bestStreak * 5} XP',
                      style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.accentLight)),
                  ]),
                  const SizedBox(height: 5),
                  ClipRRect(borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: s.progress, minHeight: 6,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    )),
                ])),
                if (isTimed) ...[const SizedBox(width: 10), _TimerBadge(secs: _timerSecs)],
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(children: [
                ...List.generate(3, (i) => Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: i < s.lives ? 1.0 : 0.2,
                    child: const Text('❤️', style: TextStyle(fontSize: 16)),
                  ),
                )),
                Text(' ${s.lives} lives', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFF2D1E00), borderRadius: BorderRadius.circular(20)),
                  child: Text('🔥 ${s.streak}', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFFE8960F))),
                ),
              ]),
            ),
            Expanded(child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(children: [
                  _QuestionCard(question: s.currentQuestion, difficulty: s.difficulty),
                  const SizedBox(height: 14),
                  _OptionsWidget(
                    question: s.currentQuestion,
                    selectedIndex: s.selectedIndex,
                    answered: s.answered,
                    onAnswer: _onAnswer,
                  ),
                  if (s.answered) ...[
                    const SizedBox(height: 10),
                    _FeedbackPanel(
                      isCorrect: s.selectedIndex == s.currentQuestion.correctIndex,
                      timedOut: s.selectedIndex == -1,
                      explanation: s.currentQuestion.explanation,
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _onNext(s),
                      child: Container(
                        width: double.infinity, padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: s.isLastQuestion ? const Color(0xFF059669) : AppColors.accent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(s.isLastQuestion ? 'See results →' : 'Next question →',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ]),
              ),
            )),
          ])),
        );
      },
    );
  }
}

class _TimerBadge extends StatelessWidget {
  final int secs;
  const _TimerBadge({required this.secs});
  @override
  Widget build(BuildContext context) {
    final urgent = secs <= 10;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: urgent ? const Color(0xFF2D1200) : const Color(0xFF1A0800),
        border: Border.all(color: urgent ? const Color(0xFFDC2626) : const Color(0xFFEA580C)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Icon(Icons.timer_outlined, size: 11, color: urgent ? const Color(0xFFDC2626) : const Color(0xFFEA580C)),
        const SizedBox(width: 4),
        Text('0:${secs.toString().padLeft(2, "0")}',
          style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600,
            color: urgent ? const Color(0xFFDC2626) : const Color(0xFFEA580C))),
      ]),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QuizQuestion question;
  final QuizDifficulty difficulty;
  const _QuestionCard({required this.question, required this.difficulty});

  String get _diffLabel => switch (difficulty) {
    QuizDifficulty.easy => 'Easy',
    QuizDifficulty.medium => 'Medium',
    QuizDifficulty.hard => 'Hard',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Text('Gemini · Data Structures', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500, color: AppColors.accentLight)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFF1E1240), borderRadius: BorderRadius.circular(20)),
            child: Text(_diffLabel, style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.accentLight)),
          ),
        ]),
        const SizedBox(height: 10),
        Text(question.question, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.6)),
      ]),
    );
  }
}

class _OptionsWidget extends StatelessWidget {
  final QuizQuestion question;
  final int? selectedIndex;
  final bool answered;
  final ValueChanged<int> onAnswer;
  const _OptionsWidget({required this.question, required this.selectedIndex, required this.answered, required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    return Column(children: List.generate(question.options.length, (i) {
      final isSelected = selectedIndex == i;
      final isCorrect = i == question.correctIndex;
      Color bg = AppColors.surface;
      Color border = AppColors.border;
      Color textColor = AppColors.textSecondary;
      double opacity = 1.0;

      if (answered) {
        if (isCorrect) { bg = const Color(0xFF052E1E); border = const Color(0xFF059669); textColor = const Color(0xFF6EE7B7); }
        else if (isSelected) { bg = const Color(0xFF1F0A0A); border = const Color(0xFFDC2626); textColor = const Color(0xFFFCA5A5); }
        else { opacity = 0.3; }
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: answered ? null : () => onAnswer(i),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: opacity,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(color: bg, border: Border.all(color: border, width: 1.5), borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: answered && isCorrect ? const Color(0xFF059669) : answered && isSelected ? const Color(0xFFDC2626) : AppColors.border,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(child: Text(String.fromCharCode(65 + i),
                    style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500,
                      color: answered && (isCorrect || isSelected) ? Colors.white : AppColors.textSecondary))),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(question.options[i], style: GoogleFonts.dmSans(fontSize: 13, color: textColor))),
                if (answered && isCorrect) const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 16),
                if (answered && isSelected && !isCorrect) const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 16),
              ]),
            ),
          ),
        ),
      );
    }));
  }
}

class _FeedbackPanel extends StatelessWidget {
  final bool isCorrect, timedOut;
  final String explanation;
  const _FeedbackPanel({required this.isCorrect, required this.timedOut, required this.explanation});

  @override
  Widget build(BuildContext context) {
    final title = timedOut ? "⏱ Time's up!" : isCorrect ? '✓ Correct! +10 XP' : '✗ Not quite';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFF052E1E) : const Color(0xFF1F0A0A),
        border: Border.all(color: isCorrect ? const Color(0xFF059669) : const Color(0xFFDC2626), width: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600,
          color: isCorrect ? const Color(0xFF6EE7B7) : const Color(0xFFFCA5A5))),
        const SizedBox(height: 4),
        Text(explanation, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textSecondary, height: 1.6)),
      ]),
    );
  }
}
