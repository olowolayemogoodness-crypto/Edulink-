
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/quiz_bloc.dart';
import '../../domain/models/quiz_question.dart';

class QuizSetupPage extends StatefulWidget {
  final String topic;
  const QuizSetupPage({super.key, this.topic = 'Data Structures'});

  @override
  State<QuizSetupPage> createState() => _QuizSetupPageState();
}

class _QuizSetupPageState extends State<QuizSetupPage> {
  QuizDifficulty _difficulty = QuizDifficulty.easy;
  QuizMode _mode = QuizMode.timed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 12),
              Text('Quick quiz', style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ]),
          ),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 8),
              _TopicCard(topic: widget.topic),
              const SizedBox(height: 20),
              _label('Choose difficulty'),
              const SizedBox(height: 10),
              _DifficultySelector(selected: _difficulty, onChanged: (d) => setState(() => _difficulty = d)),
              const SizedBox(height: 20),
              _label('Quiz mode'),
              const SizedBox(height: 10),
              _ModeSelector(selected: _mode, onChanged: (m) => setState(() => _mode = m)),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => context.read<QuizBloc>().add(
                  QuizStarted(topic: widget.topic, difficulty: _difficulty, mode: _mode)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(16)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('Start quiz', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  ]),
                ),
              ),
              const SizedBox(height: 24),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _label(String t) => Text(t.toUpperCase(),
    style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textTertiary, letterSpacing: 0.5));
}

class _TopicCard extends StatelessWidget {
  final String topic;
  const _TopicCard({required this.topic});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1240), border: Border.all(color: const Color(0xFF2D1B6B)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: [
        const Text('⚡', style: TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(topic, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text('10 questions · ~5 min', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _chip('+50', 'XP reward', AppColors.accentLight),
          const SizedBox(width: 8),
          _chip('10', 'questions', const Color(0xFFE8960F)),
          const SizedBox(width: 8),
          _chip('5m', 'time limit', const Color(0xFF0EA472)),
        ]),
      ]),
    );
  }

  Widget _chip(String val, String lbl, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: const Color(0xFF0D0D0F), borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Text(val, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      Text(lbl, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
    ]),
  );
}

class _DifficultySelector extends StatelessWidget {
  final QuizDifficulty selected;
  final ValueChanged<QuizDifficulty> onChanged;
  const _DifficultySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _tile('🌱', 'Easy', 'Warm up · foundational concepts', QuizDifficulty.easy,
        const Color(0xFF052E1E), const Color(0xFF0EA472), const Color(0xFF0EA472)),
      const SizedBox(height: 8),
      _tile('🔥', 'Medium', 'Challenge mode · mixed topics', QuizDifficulty.medium,
        const Color(0xFF2D1E00), const Color(0xFFC47D0E), const Color(0xFFE8960F)),
      const SizedBox(height: 8),
      _tile('💀', 'Hard', 'Expert level · exam simulation', QuizDifficulty.hard,
        const Color(0xFF2D1200), const Color(0xFFEA580C), const Color(0xFFEA580C)),
    ]);
  }

  Widget _tile(String emoji, String label, String sub, QuizDifficulty diff,
      Color activeBg, Color activeBorder, Color activeText) {
    final active = selected == diff;
    return GestureDetector(
      onTap: () => onChanged(diff),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: active ? activeBg : const Color(0xFF141418),
          border: Border.all(color: active ? activeBorder : const Color(0xFF2A2A35), width: active ? 1.5 : 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(color: active ? activeBg : const Color(0xFF0D0D0F), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18)))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500,
              color: active ? activeText : const Color(0xFFA09CB8))),
            Text(sub, style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFF5A5670))),
          ])),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 18, height: 18,
            decoration: BoxDecoration(shape: BoxShape.circle, color: active ? activeBorder : const Color(0xFF2A2A35)),
            child: active ? const Icon(Icons.check_rounded, size: 10, color: Colors.white) : null,
          ),
        ]),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final QuizMode selected;
  final ValueChanged<QuizMode> onChanged;
  const _ModeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _tile('⏱', 'Timed', '30s per Q', QuizMode.timed),
      const SizedBox(width: 8),
      _tile('🧘', 'Free', 'No limit', QuizMode.free),
      const SizedBox(width: 8),
      _tile('⚔️', 'Battle', 'vs friend', QuizMode.battle),
    ]);
  }

  Widget _tile(String emoji, String label, String sub, QuizMode mode) {
    final active = selected == mode;
    return Expanded(child: GestureDetector(
      onTap: () => onChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1E1240) : const Color(0xFF141418),
          border: Border.all(color: active ? const Color(0xFF7C3AED) : const Color(0xFF2A2A35), width: active ? 1.5 : 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500,
            color: active ? const Color(0xFF9D6FEC) : const Color(0xFFA09CB8))),
          Text(sub, style: GoogleFonts.dmSans(fontSize: 9, color: const Color(0xFF5A5670))),
        ]),
      ),
    ));
  }
}
