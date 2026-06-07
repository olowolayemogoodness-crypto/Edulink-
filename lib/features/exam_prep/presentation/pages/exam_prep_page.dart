import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/exam_bloc.dart';
import '../../domain/models/exam_model.dart';
import '../../data/mock_exam_data.dart';
import '../../../../core/services/user_service.dart';

class ExamPrepPage extends StatelessWidget {
  const ExamPrepPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExamBloc(),
      child: BlocBuilder<ExamBloc, ExamState>(
        builder: (context, state) {
          if (state is ExamSetup) return _SetupScreen(mode: state.mode);
          if (state is ExamObjectiveInProgress) return const _ObjectiveScreen();
          if (state is ExamTheoryInProgress) return const _TheoryScreen();
          if (state is ExamFinished) return const _ResultsScreen();
          return const _ModeScreen();
        },
      ),
    );
  }
}

// ════════════════════════════════════════
// SCREEN 0 — MODE SELECTION
// ════════════════════════════════════════
class _ModeScreen extends StatelessWidget {
  const _ModeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(children: [
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
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Exam prep',
                  style: GoogleFonts.dmSans(fontSize: 17,
                      fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text('WAEC · JAMB · IELTS · TOEFL · GRE',
                  style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
            ])),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 4),
            Text('CHOOSE EXAM FORMAT',
                style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            _ModeCard(
              icon: Icons.checklist_rounded,
              iconBg: const Color(0xFF2D1B6B),
              iconColor: AppColors.accentLight,
              bg: const Color(0xFF1E1240),
              border: const Color(0xFF2D1B6B),
              title: 'Objective',
              subtitle: 'Multiple choice · no feedback until end',
              description: 'Answer all questions first. Results and correct answers revealed at the end.',
              tags: const ['No hints', 'Auto-marked'],
              tagBg: const Color(0xFF2D1B6B),
              tagColor: AppColors.accentLight,
              onTap: () => context.read<ExamBloc>().add(ExamModeSelected(ExamMode.objective)),
            ),
            _ModeCard(
              icon: Icons.edit_note_rounded,
              iconBg: const Color(0xFF3D2900),
              iconColor: const Color(0xFFE8960F),
              bg: const Color(0xFF2D1E00),
              border: const Color(0xFFC47D0E),
              title: 'Theory',
              subtitle: 'Written answers · AI professor marking',
              description: 'Write your answer, then see model answer and Gemini breakdown. Total = 60 marks.',
              tags: const ['Gemini marks', '60 marks'],
              tagBg: const Color(0xFF3D2900),
              tagColor: const Color(0xFFE8960F),
              onTap: () => context.read<ExamBloc>().add(ExamModeSelected(ExamMode.theory)),
            ),
            _ModeCard(
              icon: Icons.layers_rounded,
              iconBg: const Color(0xFF073D27),
              iconColor: const Color(0xFF0EA472),
              bg: const Color(0xFF052E1E),
              border: const Color(0xFF0EA472),
              title: 'Combo',
              subtitle: 'Objective + theory · most realistic',
              description: 'Mirrors real WAEC/JAMB structure. Full score breakdown at the end.',
              tags: const ['Most realistic', 'Full breakdown'],
              tagBg: const Color(0xFF073D27),
              tagColor: const Color(0xFF0EA472),
              onTap: () => context.read<ExamBloc>().add(ExamModeSelected(ExamMode.combo)),
            ),
            const SizedBox(height: 24),
          ]),
        )),
      ])),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor, bg, border, tagBg, tagColor;
  final String title, subtitle, description;
  final List<String> tags;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.bg, required this.border, required this.title,
    required this.subtitle, required this.description, required this.tags,
    required this.tagBg, required this.tagColor, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.dmSans(fontSize: 13,
                fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.dmSans(fontSize: 10, color: tagColor)),
            const SizedBox(height: 4),
            Text(description, style: GoogleFonts.dmSans(fontSize: 10,
                color: AppColors.textTertiary, height: 1.5)),
            const SizedBox(height: 8),
            Row(children: tags.map((t) => Container(
              margin: const EdgeInsets.only(right: 5),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(20)),
              child: Text(t, style: GoogleFonts.dmSans(fontSize: 9,
                  fontWeight: FontWeight.w500, color: tagColor)),
            )).toList()),
          ])),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════
// SCREEN 1 — SETUP
// ════════════════════════════════════════
class _SetupScreen extends StatefulWidget {
  final ExamMode mode;
  const _SetupScreen({required this.mode});
  @override
  State<_SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<_SetupScreen> {
  ExamSubject _subject = MockExamData.subjects[0];
  int _questionCount = 10;
  int _secondsPerQ = 30;
  bool _ddOpen = false;

  String get _modeLabel => switch (widget.mode) {
    ExamMode.objective => 'Objective',
    ExamMode.theory => 'Theory',
    ExamMode.combo => 'Combo',
  };

  @override
  Widget build(BuildContext context) {
    final waec = MockExamData.subjects
        .where((s) => s.group == ExamSubjectGroup.waec).toList();
    final jamb = MockExamData.subjects
        .where((s) => s.group == ExamSubjectGroup.jamb).toList();
    final intl = MockExamData.subjects
        .where((s) => s.group == ExamSubjectGroup.international).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(children: [
            GestureDetector(
              onTap: () => context.read<ExamBloc>().add(ExamReset()),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border)),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 12),
            Text('$_modeLabel exam setup',
                style: GoogleFonts.dmSans(fontSize: 17,
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Subject dropdown
            _sectionLabel('Choose subject'),
            const SizedBox(height: 9),
            _SubjectDropdown(
              subject: _subject,
              isOpen: _ddOpen,
              waecSubjects: waec,
              jambSubjects: jamb,
              intlSubjects: intl,
              onToggle: () => setState(() => _ddOpen = !_ddOpen),
              onSelect: (s) => setState(() { _subject = s; _ddOpen = false; }),
            ),
            const SizedBox(height: 14),
            // Question count
            _sectionLabel('Number of questions'),
            const SizedBox(height: 9),
            Row(children: [10, 20, 40, 60].map((n) {
              final selected = _questionCount == n;
              return Expanded(child: GestureDetector(
                onTap: () => setState(() => _questionCount = n),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 7),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF1E1240) : AppColors.surface,
                    border: Border.all(
                        color: selected ? AppColors.accent : AppColors.border,
                        width: selected ? 1.5 : 0.5),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Column(children: [
                    Text('$n', style: GoogleFonts.dmSans(fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: selected ? AppColors.accentLight : AppColors.textTertiary)),
                    Text(n == 60 ? 'Full' : '~${n}m',
                        style: GoogleFonts.dmSans(fontSize: 9,
                            color: selected ? AppColors.accentLight : AppColors.textTertiary)),
                  ]),
                ),
              ));
            }).toList()),
            const SizedBox(height: 14),
            // Time per question
            if (widget.mode != ExamMode.theory) ...[
              _sectionLabel('Time per question'),
              const SizedBox(height: 9),
              Row(children: [
                _timeChip('30s', 'Timed', 30),
                const SizedBox(width: 7),
                _timeChip('60s', 'Standard', 60),
                const SizedBox(width: 7),
                _timeChip('∞', 'No limit', 0),
              ]),
              const SizedBox(height: 14),
            ],
            // Theory note
            if (widget.mode == ExamMode.theory || widget.mode == ExamMode.combo)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D1E00),
                  border: Border.all(color: const Color(0xFFC47D0E)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 15, color: Color(0xFFE8960F)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    'Theory marks always total 60 marks. Gemini grades like a professor — partial marks for method, accuracy and relevance.',
                    style: GoogleFonts.dmSans(fontSize: 10,
                        color: AppColors.textSecondary, height: 1.6),
                  )),
                ]),
              ),
            // Start button
            GestureDetector(
              onTap: () => context.read<ExamBloc>().add(ExamConfigured(
                ExamConfig(
                  subject: _subject,
                  mode: widget.mode,
                  questionCount: _questionCount,
                  secondsPerQuestion: _secondsPerQ,
                ),
              )),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(16)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('Start exam session',
                      style: GoogleFonts.dmSans(fontSize: 14,
                          fontWeight: FontWeight.w600, color: Colors.white)),
                ]),
              ),
            ),
            const SizedBox(height: 24),
          ]),
        )),
      ])),
    );
  }

  Widget _sectionLabel(String t) => Text(t.toUpperCase(),
      style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500,
          color: AppColors.textTertiary, letterSpacing: 0.5));

  Widget _timeChip(String label, String sub, int secs) {
    final selected = _secondsPerQ == secs;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _secondsPerQ = secs),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E1240) : AppColors.surface,
          border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
              width: selected ? 1.5 : 0.5),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 14,
              fontWeight: FontWeight.w500,
              color: selected ? AppColors.accentLight : AppColors.textTertiary)),
          Text(sub, style: GoogleFonts.dmSans(fontSize: 9,
              color: selected ? AppColors.accentLight : AppColors.textTertiary)),
        ]),
      ),
    ));
  }
}

class _SubjectDropdown extends StatelessWidget {
  final ExamSubject subject;
  final bool isOpen;
  final List<ExamSubject> waecSubjects, jambSubjects, intlSubjects;
  final VoidCallback onToggle;
  final ValueChanged<ExamSubject> onSelect;

  const _SubjectDropdown({
    required this.subject, required this.isOpen,
    required this.waecSubjects, required this.jambSubjects,
    required this.intlSubjects, required this.onToggle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GestureDetector(
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(
                color: isOpen ? AppColors.accent : AppColors.border,
                width: isOpen ? 1.5 : 1),
            borderRadius: isOpen
                ? const BorderRadius.vertical(top: Radius.circular(14))
                : BorderRadius.circular(14),
          ),
          child: Row(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                  color: const Color(0xFF1E1240),
                  borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(subject.emoji,
                  style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(subject.name, style: GoogleFonts.dmSans(fontSize: 12,
                  fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              Text(subject.hint, style: GoogleFonts.dmSans(
                  fontSize: 10, color: AppColors.textTertiary)),
            ])),
            AnimatedRotation(
              turns: isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 250),
              child: Icon(Icons.keyboard_arrow_down_rounded,
                  color: isOpen ? AppColors.accentLight : AppColors.textTertiary),
            ),
          ]),
        ),
      ),
      if (isOpen) Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.accent, width: 1.5),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
        ),
        child: Column(children: [
          _groupLabel('WAEC'),
          ...waecSubjects.map((s) => _SubjectItem(
              subject: s, selected: s.id == subject.id,
              onTap: () => onSelect(s))),
          _groupLabel('JAMB / UTME'),
          ...jambSubjects.map((s) => _SubjectItem(
              subject: s, selected: s.id == subject.id,
              onTap: () => onSelect(s))),
          _groupLabel('International'),
          ...intlSubjects.map((s) => _SubjectItem(
              subject: s, selected: s.id == subject.id,
              onTap: () => onSelect(s))),
        ]),
      ),
    ]);
  }

  Widget _groupLabel(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
    child: Text(t.toUpperCase(),
        style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500,
            color: AppColors.textTertiary, letterSpacing: 0.6)),
  );
}

class _SubjectItem extends StatelessWidget {
  final ExamSubject subject;
  final bool selected;
  final VoidCallback onTap;
  const _SubjectItem({required this.subject, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E1240) : Colors.transparent,
          border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
                color: const Color(0xFF1A1A21),
                borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(subject.emoji,
                style: const TextStyle(fontSize: 15))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(subject.name, style: GoogleFonts.dmSans(fontSize: 12,
                fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            Text(subject.hint, style: GoogleFonts.dmSans(
                fontSize: 9, color: AppColors.textTertiary)),
          ])),
          if (selected) Container(
            width: 18, height: 18,
            decoration: BoxDecoration(
                color: AppColors.accent, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, size: 10, color: Colors.white),
          ),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════
// SCREEN 2 — OBJECTIVE
// ════════════════════════════════════════
class _ObjectiveScreen extends StatefulWidget {
  const _ObjectiveScreen();
  @override
  State<_ObjectiveScreen> createState() => _ObjectiveScreenState();
}

class _ObjectiveScreenState extends State<_ObjectiveScreen> {
  Timer? _timer;
  int _secs = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secs = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secs--);
      if (_secs <= 0) { t.cancel(); context.read<ExamBloc>().add(ExamTimedOut()); }
    });
  }

  void _stopTimer() => _timer?.cancel();

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExamBloc, ExamState>(
      listener: (context, state) {
        if (state is ExamObjectiveInProgress && !state.answered) _startTimer();
      },
      builder: (context, state) {
        if (state is! ExamObjectiveInProgress) return const SizedBox();
        final s = state;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Row(children: [
                GestureDetector(
                  onTap: () { _stopTimer(); context.read<ExamBloc>().add(ExamReset()); },
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.textTertiary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Q ${s.currentIndex + 1} of ${s.questions.length}',
                        style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
                    Text('Objective',
                        style: GoogleFonts.dmSans(fontSize: 11,
                            fontWeight: FontWeight.w500, color: AppColors.accentLight)),
                  ]),
                  const SizedBox(height: 5),
                  ClipRRect(borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: s.progress, minHeight: 5,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    )),
                ])),
                const SizedBox(width: 10),
                _TimerBadge(secs: _secs),
              ]),
            ),
            // Question dots
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: List.generate(s.questions.length, (i) {
                  final answered = i < s.answers.length;
                  final isCurrent = i == s.currentIndex;
                  return Container(
                    margin: const EdgeInsets.only(right: 4),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: isCurrent ? const Color(0xFF1E1240)
                          : answered ? const Color(0xFF1E1240) : AppColors.surface,
                      border: Border.all(
                          color: isCurrent || answered ? AppColors.accent : AppColors.border),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(child: Text('${i + 1}',
                        style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500,
                            color: isCurrent || answered
                                ? AppColors.accentLight : AppColors.textTertiary))),
                  );
                })),
              ),
            ),
            // Exam mode banner
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                  color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.visibility_off_rounded,
                    size: 13, color: AppColors.textTertiary),
                const SizedBox(width: 7),
                Text('Exam mode — answers shown after all questions',
                    style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
              ]),
            ),
            Expanded(child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                // Question card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 5, height: 5,
                          decoration: const BoxDecoration(
                              color: AppColors.accent, shape: BoxShape.circle)),
                      const SizedBox(width: 7),
                      Text('Gemini · ${s.config.subject.name}',
                          style: GoogleFonts.dmSans(fontSize: 9,
                              fontWeight: FontWeight.w500, color: AppColors.accentLight)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFF1E1240),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('Medium', style: GoogleFonts.dmSans(
                            fontSize: 9, color: AppColors.accentLight)),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Text(s.currentQuestion.question,
                        style: GoogleFonts.dmSans(fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary, height: 1.6)),
                  ]),
                ),
                const SizedBox(height: 10),
                // Options
                ...List.generate(s.currentQuestion.options.length, (i) {
                  final isSelected = s.selectedIndex == i;
                  return GestureDetector(
                    onTap: s.answered ? null : () {
                      _stopTimer();
                      context.read<ExamBloc>().add(ExamObjectiveAnswered(
                          questionIndex: s.currentIndex, chosenIndex: i));
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1E1240) : AppColors.surface,
                        border: Border.all(
                            color: isSelected ? AppColors.accent : AppColors.border,
                            width: isSelected ? 1.5 : 1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 26, height: 26,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accent : AppColors.border,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(child: Text(String.fromCharCode(65 + i),
                              style: GoogleFonts.dmSans(fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? Colors.white : AppColors.textSecondary))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(s.currentQuestion.options[i],
                            style: GoogleFonts.dmSans(fontSize: 13,
                                color: isSelected ? AppColors.textPrimary
                                    : AppColors.textSecondary))),
                      ]),
                    ),
                  );
                }),
                if (s.answered) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => context.read<ExamBloc>().add(ExamObjectiveNext()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(14)),
                      child: Text(s.isLast ? 'See results →' : 'Next →',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(fontSize: 13,
                              fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      _stopTimer();
                      context.read<ExamBloc>().add(ExamObjectiveNext());
                    },
                    child: Text('Skip →',
                        style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
                  ),
                ],
                const SizedBox(height: 24),
              ]),
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
        border: Border.all(
            color: urgent ? const Color(0xFFDC2626) : const Color(0xFFEA580C)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Icon(Icons.timer_outlined, size: 11,
            color: urgent ? const Color(0xFFDC2626) : const Color(0xFFEA580C)),
        const SizedBox(width: 4),
        Text('0:${secs.toString().padLeft(2, "0")}',
            style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600,
                color: urgent ? const Color(0xFFDC2626) : const Color(0xFFEA580C))),
      ]),
    );
  }
}

// ════════════════════════════════════════
// SCREEN 3 — THEORY
// ════════════════════════════════════════
class _TheoryScreen extends StatefulWidget {
  const _TheoryScreen();
  @override
  State<_TheoryScreen> createState() => _TheoryScreenState();
}

class _TheoryScreenState extends State<_TheoryScreen> {
  final _controller = TextEditingController();
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _wordCount = _controller.text.trim().isEmpty
            ? 0
            : _controller.text.trim().split(RegExp(r'\s+')).length;
      });
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExamBloc, ExamState>(
      listener: (context, state) {
        if (state is ExamTheoryInProgress && !state.submitted) {
          _controller.clear();
        }
      },
      builder: (context, state) {
        if (state is! ExamTheoryInProgress) return const SizedBox();
        final s = state;
        final q = s.currentQuestion;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.read<ExamBloc>().add(ExamReset()),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.textTertiary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Theory ${s.currentIndex + 1} of ${s.questions.length}',
                        style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: const Color(0xFF2D1E00),
                            border: Border.all(color: const Color(0xFFC47D0E), width: 0.5),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('${q.marks} marks',
                            style: GoogleFonts.dmSans(fontSize: 9,
                                color: const Color(0xFFE8960F))),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('Total: 60',
                            style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
                      ),
                    ]),
                  ]),
                  const SizedBox(height: 5),
                  ClipRRect(borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: s.progress, minHeight: 5,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFC47D0E)),
                    )),
                ])),
              ]),
            ),
            Expanded(child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Question card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 5, height: 5,
                          decoration: const BoxDecoration(
                              color: Color(0xFFC47D0E), shape: BoxShape.circle)),
                      const SizedBox(width: 7),
                      Text('Theory · Gemini marking',
                          style: GoogleFonts.dmSans(fontSize: 9,
                              fontWeight: FontWeight.w500, color: const Color(0xFFE8960F))),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: const Color(0xFF2D1E00),
                            border: Border.all(color: const Color(0xFFC47D0E), width: 0.5),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('${q.marks} marks',
                            style: GoogleFonts.dmSans(fontSize: 9,
                                fontWeight: FontWeight.w500, color: const Color(0xFFE8960F))),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Text(q.question, style: GoogleFonts.dmSans(fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary, height: 1.6)),
                  ]),
                ),
                const SizedBox(height: 12),
                if (!s.submitted) ...[
                  Text('Your answer',
                      style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: 6,
                      style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Write your answer here. Show all working — Gemini awards partial marks for method…',
                        hintStyle: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textTertiary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('$_wordCount word${_wordCount != 1 ? "s" : ""}',
                          style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
                      Text('Show full working',
                          style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => context.read<ExamBloc>().add(ExamTheorySubmitted(
                        questionIndex: s.currentIndex, answer: _controller.text)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xFFC47D0E),
                          borderRadius: BorderRadius.circular(14)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text('Submit & see marking',
                            style: GoogleFonts.dmSans(fontSize: 13,
                                fontWeight: FontWeight.w600, color: Colors.white)),
                      ]),
                    ),
                  ),
                ] else ...[
                  // Score card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Your score',
                            style: GoogleFonts.dmSans(fontSize: 12,
                                fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                        Row(crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic, children: [
                          Text('${s.scoreAwarded ?? 0}',
                              style: GoogleFonts.dmSans(fontSize: 24,
                                  fontWeight: FontWeight.w500, color: const Color(0xFF0EA472))),
                          Text(' / ${q.marks}',
                              style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textTertiary)),
                        ]),
                      ]),
                      const SizedBox(height: 8),
                      ClipRRect(borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: (s.scoreAwarded ?? 0) / q.marks,
                          minHeight: 6,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF0EA472)),
                        )),
                      const SizedBox(height: 7),
                      Row(children: [
                        Container(width: 5, height: 5,
                            decoration: const BoxDecoration(
                                color: AppColors.accent, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('Gemini · professor mode',
                            style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.accentLight)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  // Marking breakdown
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Marking breakdown',
                          style: GoogleFonts.dmSans(fontSize: 11,
                              fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      ...q.markingPoints.map((p) => _MarkingRow(point: p)),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  // Model answer
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Model answer',
                            style: GoogleFonts.dmSans(fontSize: 11,
                                fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF1E1240),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text('Gemini', style: GoogleFonts.dmSans(
                              fontSize: 9, color: AppColors.accentLight)),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Text(q.modelAnswer, style: GoogleFonts.dmSans(fontSize: 11,
                          color: AppColors.textSecondary, height: 1.7)),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => context.read<ExamBloc>().add(ExamTheoryNext()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                          color: const Color(0xFFC47D0E),
                          borderRadius: BorderRadius.circular(14)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(s.isLast ? 'See results →' : 'Next question →',
                            style: GoogleFonts.dmSans(fontSize: 13,
                                fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 15),
                      ]),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ]),
            )),
          ])),
        );
      },
    );
  }
}

class _MarkingRow extends StatelessWidget {
  final MarkingPoint point;
  const _MarkingRow({required this.point});

  @override
  Widget build(BuildContext context) {
    final color = switch (point.status) {
      MarkingStatus.correct => const Color(0xFF0EA472),
      MarkingStatus.partial => const Color(0xFFE8960F),
      MarkingStatus.wrong   => const Color(0xFFDC2626),
    };
    final bg = switch (point.status) {
      MarkingStatus.correct => const Color(0xFF052E1E),
      MarkingStatus.partial => const Color(0xFF2D1E00),
      MarkingStatus.wrong   => const Color(0xFF1F0A0A),
    };
    final border = switch (point.status) {
      MarkingStatus.correct => const Color(0xFF0EA472),
      MarkingStatus.partial => const Color(0xFFC47D0E),
      MarkingStatus.wrong   => const Color(0xFFDC2626),
    };
    final icon = switch (point.status) {
      MarkingStatus.correct => Icons.check_rounded,
      MarkingStatus.partial => Icons.remove_rounded,
      MarkingStatus.wrong   => Icons.close_rounded,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: bg, border: Border.all(color: border, width: 0.5),
          borderRadius: BorderRadius.circular(10)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${point.label} (+${point.marks})',
              style: GoogleFonts.dmSans(fontSize: 10,
                  fontWeight: FontWeight.w500, color: color)),
          const SizedBox(height: 2),
          Text(point.feedback, style: GoogleFonts.dmSans(
              fontSize: 10, color: AppColors.textTertiary)),
        ])),
      ]),
    );
  }
}

// ════════════════════════════════════════
// SCREEN 4 — RESULTS
// ════════════════════════════════════════
class _ResultsScreen extends StatefulWidget {
  const _ResultsScreen();
  @override
  State<_ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<_ResultsScreen>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _arcAnim;
  int _displayXp = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    final state = context.read<ExamBloc>().state;
    if (state is ExamFinished) {
      _arcAnim = Tween<double>(begin: 0, end: state.result.overallPercent / 100)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
      final xpCtrl = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 1200));
      final xpAnim = Tween<double>(begin: 0, end: state.result.xpEarned.toDouble())
          .animate(CurvedAnimation(parent: xpCtrl, curve: Curves.easeOut));
      xpAnim.addListener(() => setState(() => _displayXp = xpAnim.value.round()));
      Future.delayed(const Duration(milliseconds: 300), () {
        _ctrl.forward();
        xpCtrl.forward();
      });
      UserService.awardXP(state.result.xpEarned, reason: 'exam_prep');
      UserService.updateStreak();
      UserService.updateLeaderboard();
    } else {
      _arcAnim = const AlwaysStoppedAnimation(0);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExamBloc, ExamState>(
      builder: (context, state) {
        if (state is! ExamFinished) return const SizedBox();
        final r = state.result;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              const SizedBox(height: 20),
              // Certificate icon
              Container(
                width: 68, height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1240),
                  border: Border.all(color: AppColors.accent, width: 2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    size: 30, color: AppColors.accentLight),
              ),
              const SizedBox(height: 12),
              Text('Exam complete!',
                  style: GoogleFonts.dmSans(fontSize: 20,
                      fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 3),
              Text('${r.config.subject.name} · ${r.config.mode.name}',
                  style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
              const SizedBox(height: 14),
              // Score arc
              SizedBox(
                width: 110, height: 110,
                child: AnimatedBuilder(
                  animation: _arcAnim,
                  builder: (_, _) => CustomPaint(
                    painter: _ArcPainter(
                        progress: _arcAnim.value,
                        color: AppColors.accent,
                        trackColor: AppColors.border),
                    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('${r.overallPercent}%',
                          style: GoogleFonts.dmSans(fontSize: 22,
                              fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Text('overall',
                          style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
                    ])),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Stats grid
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.2,
                children: [
                  if (r.objectiveAnswers.isNotEmpty)
                    _StatTile(label: 'Objective',
                        value: '${r.objectiveCorrect}/${r.objectiveTotal}',
                        color: AppColors.accentLight),
                  if (r.theoryAnswers.isNotEmpty)
                    _StatTile(label: 'Theory',
                        value: '${r.theoryScore}/${r.theoryTotal}',
                        color: const Color(0xFFE8960F)),
                  _StatTile(label: 'XP earned',
                      value: '+$_displayXp', color: const Color(0xFFE8960F)),
                  _StatTile(label: 'Grade',
                      value: r.grade, color: const Color(0xFF0EA472)),
                ],
              ),
              const SizedBox(height: 12),
              // Gemini analysis
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1240),
                  border: Border.all(color: const Color(0xFF2D1B6B)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 5, height: 5,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                          color: AppColors.accent, shape: BoxShape.circle)),
                  const SizedBox(width: 9),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Gemini analysis',
                        style: GoogleFonts.dmSans(fontSize: 11,
                            fontWeight: FontWeight.w500, color: AppColors.accentLight)),
                    const SizedBox(height: 3),
                    Text('Strong on algebra and trigonometry. Theory shows understanding but lacks formal proof statements. Focus next on Circle Geometry proofs and Calculus.',
                        style: GoogleFonts.dmSans(fontSize: 11,
                            color: AppColors.textSecondary, height: 1.6)),
                  ])),
                ]),
              ),
              const SizedBox(height: 12),
              // Objective review dots
              if (r.objectiveAnswers.isNotEmpty) ...[
                Align(alignment: Alignment.centerLeft,
                  child: Text('OBJECTIVE REVIEW',
                      style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary, letterSpacing: 0.5))),
                const SizedBox(height: 7),
                Wrap(spacing: 4, runSpacing: 4,
                  children: r.objectiveAnswers.map((a) => Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      color: a.correct ? const Color(0xFF052E1E) : const Color(0xFF1F0A0A),
                      border: Border.all(
                          color: a.correct
                              ? const Color(0xFF059669) : const Color(0xFFDC2626)),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Center(child: Text(a.correct ? '✓' : '✗',
                        style: TextStyle(fontSize: 11,
                            color: a.correct
                                ? const Color(0xFF6EE7B7) : const Color(0xFFFCA5A5)))),
                  )).toList()),
                const SizedBox(height: 12),
              ],
              // CTAs
              GestureDetector(
                onTap: () => context.read<ExamBloc>().add(ExamReset()),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(14)),
                  child: Text('New session',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(fontSize: 13,
                          fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  context.read<ExamBloc>().add(ExamReset());
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border, width: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('Back to exam prep',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary)),
                ),
              ),
              const SizedBox(height: 24),
            ]),
          )),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value, style: GoogleFonts.dmSans(fontSize: 20,
            fontWeight: FontWeight.w600, color: color)),
        Text(label, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
      ]),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color, trackColor;
  const _ArcPainter({required this.progress, required this.color, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;
    canvas.drawCircle(center, radius,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 7..color = trackColor);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2, 2 * 3.14159 * progress, false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 7
            ..strokeCap = StrokeCap.round..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}