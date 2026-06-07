import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/user_service.dart';
// ── Models ──
class _PracticeTest {
  final String emoji, title, subtitle, paper, tag;
  final Color tagColor, tagBg, iconBg, iconBorder;
  final int questions, minutes;
  final String? best;
  final int attempts;
  final bool recommended;
  const _PracticeTest({
    required this.emoji, required this.title, required this.subtitle,
    required this.paper, required this.tag, required this.tagColor,
    required this.tagBg, required this.iconBg, required this.iconBorder,
    required this.questions, required this.minutes,
    this.best, this.attempts = 0, this.recommended = false,
  });
}

class _Question {
  final String q, topic, diff;
  final List<String> opts;
  final int ans;
  const _Question({required this.q, required this.topic, required this.diff, required this.opts, required this.ans});
}

// ── Mock data ──
const _tests = [
  _PracticeTest(emoji: '📐', title: 'WAEC Mathematics 2023', subtitle: '2023 past paper · Paper 1', paper: 'Paper 1 — Obj.', tag: 'Recommended', tagColor: Color(0xFFE8960F), tagBg: Color(0xFF2D1E00), iconBg: Color(0xFF2D1E00), iconBorder: Color(0xFFC47D0E), questions: 40, minutes: 90, best: '68%', attempts: 3, recommended: true),
  _PracticeTest(emoji: '🌍', title: 'IELTS Academic Reading', subtitle: 'Full mock test', paper: 'Reading', tag: 'IELTS', tagColor: AppColors.success, tagBg: AppColors.successSurface, iconBg: AppColors.successSurface, iconBorder: AppColors.success, questions: 40, minutes: 60, best: '65%', attempts: 1),
  _PracticeTest(emoji: '🧮', title: 'JAMB Mathematics 2022', subtitle: 'UTME paper', paper: 'UTME', tag: 'JAMB', tagColor: AppColors.accentLight, tagBg: AppColors.accentSurface, iconBg: AppColors.accentSurface, iconBorder: AppColors.accent, questions: 40, minutes: 40, best: null, attempts: 0),
  _PracticeTest(emoji: '⚗️', title: 'WAEC Chemistry 2023', subtitle: 'Objective paper', paper: 'Paper 1', tag: 'WAEC', tagColor: AppColors.textTertiary, tagBg: AppColors.surface, iconBg: AppColors.surface, iconBorder: AppColors.border, questions: 50, minutes: 75, best: '74%', attempts: 2),
  _PracticeTest(emoji: '⚡', title: 'Quick drill — 10 questions', subtitle: 'Mixed topics · warm up', paper: 'Mixed', tag: '+50 XP', tagColor: AppColors.accentLight, tagBg: AppColors.accentSurface, iconBg: const Color(0xFF2D1200), iconBorder: const Color(0xFFEA580C), questions: 10, minutes: 10, best: null, attempts: 0),
];

const _questions = [
  _Question(q: 'If sin θ = 3/5 and θ is in Q1, find cos θ.', opts: ['3/4', '4/5', '5/4', '3/5'], ans: 1, topic: 'Trigonometry', diff: 'Medium'),
  _Question(q: 'What is the derivative of f(x) = 3x² + 2x − 5?', opts: ['6x + 2', '3x + 2', '6x − 5', '3x²'], ans: 0, topic: 'Calculus', diff: 'Easy'),
  _Question(q: 'Sum of interior angles of a hexagon:', opts: ['540°', '720°', '360°', '900°'], ans: 1, topic: 'Geometry', diff: 'Easy'),
  _Question(q: 'Simplify (x² − 4) ÷ (x − 2):', opts: ['x − 2', 'x + 2', 'x² + 2', '2x'], ans: 1, topic: 'Algebra', diff: 'Easy'),
  _Question(q: '15% of 240:', opts: ['30', '36', '24', '42'], ans: 1, topic: 'Arithmetic', diff: 'Easy'),
  _Question(q: 'Find x if 2ˣ = 32:', opts: ['4', '5', '6', '3'], ans: 1, topic: 'Indices', diff: 'Medium'),
  _Question(q: 'Circle with centre (3,−2) and r=5. Its equation:', opts: ['(x+3)²+(y−2)²=5', '(x−3)²+(y+2)²=25', '(x+3)²+(y+2)²=25', '(x−3)²+(y−2)²=5'], ans: 1, topic: 'Circle geo.', diff: 'Hard'),
  _Question(q: 'Solve: 3x + 7 = 22', opts: ['3', '4', '5', '6'], ans: 2, topic: 'Algebra', diff: 'Easy'),
  _Question(q: 'P(even number) on a standard die:', opts: ['1/3', '1/2', '2/3', '1/6'], ans: 1, topic: 'Statistics', diff: 'Easy'),
  _Question(q: 'log₂(64) = ?', opts: ['4', '5', '6', '7'], ans: 2, topic: 'Logarithms', diff: 'Medium'),
];

enum _PracticeTab { browse, setup, exam, results, review }

class PracticeTestPage extends StatefulWidget {
  const PracticeTestPage({super.key});
  @override
  State<PracticeTestPage> createState() => _PracticeTestPageState();
}

class _PracticeTestPageState extends State<PracticeTestPage> with TickerProviderStateMixin {
  _PracticeTab _tab = _PracticeTab.browse;
  _PracticeTest _selected = _tests[0];
  int _qi = 0;
  final List<int?> _answers = List.filled(10, null);
  final List<bool> _flagged = List.filled(10, false);
  late DateTime _startTime;
  int _elapsed = 0;
  int _timerSecs = 5400;

  // Toggles
  bool _togTimer = true, _togAns = true, _togSound = false;
  Timer? _countdownTimer;
  late AnimationController _ringCtrl;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _ringAnim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _ringCtrl.dispose();
    super.dispose();
  }

  void _go(_PracticeTab tab) {
    HapticFeedback.selectionClick();
    setState(() => _tab = tab);
    if (tab == _PracticeTab.exam) {
      _qi = 0;
      _answers.fillRange(0, 10, null);
      _flagged.fillRange(0, 10, false);
      _startTime = DateTime.now();
      _timerSecs = _selected.minutes * 60;
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (tab != _PracticeTab.exam) _countdownTimer?.cancel();
        if (!mounted) return;
        setState(() {
          if (_timerSecs > 0) {
            _timerSecs--;
          } else {
            _countdownTimer?.cancel();
            _go(_PracticeTab.results);
          }
        });
      });
    }
    if (tab == _PracticeTab.results) {
      _elapsed = DateTime.now().difference(_startTime).inSeconds;
      Future.delayed(const Duration(milliseconds: 300), () => _ringCtrl.forward(from: 0));
      UserService.awardXP(_correct * 20, reason: 'practice_test');
      UserService.updateStreak();
      UserService.updateLeaderboard();
    }
  }

  int get _correct => _answers.asMap().entries.where((e) => e.value == _questions[e.key].ans).length;
  int get _wrong => _answers.where((a) => a != null).length - _correct;
  int get _skipped => _answers.where((a) => a == null).length;
  int get _pct => (_correct / _questions.length * 100).round();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    switch (_tab) {
      case _PracticeTab.browse:  return _browse();
      case _PracticeTab.setup:   return _setup();
      case _PracticeTab.exam:    return _exam();
      case _PracticeTab.results: return _results();
      case _PracticeTab.review:  return _review();
    }
  }

  // ══════════════════════════════════════════
  // BROWSE
  // ══════════════════════════════════════════
  Widget _browse() => Column(children: [
    // Header
    Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Practice tests', style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text('Timed · exam conditions · no hints', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
        ])),
      ]),
    ),

    // Stats strip
    Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        Expanded(child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(border: Border(right: BorderSide(color: AppColors.border))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('14', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text('Tests taken', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
          ]),
        )),
        Expanded(child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(border: Border(right: BorderSide(color: AppColors.border))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('72%', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.success)),
            Text('Average score', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
          ]),
        )),
        Expanded(child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('+8%', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFFE8960F))),
            Text('This week', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
          ]),
        )),
      ]),
    ),

    // Test list
    Expanded(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
        child: Text('RECOMMENDED', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.6)),
      ),
      ..._tests.where((t) => t.recommended).map((t) => _testRow(t)),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
        child: Text('ALL TESTS', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.6)),
      ),
      ..._tests.where((t) => !t.recommended).map((t) => _testRow(t)),
      const SizedBox(height: 16),
    ]))),
  ]);

  Widget _testRow(_PracticeTest t) => GestureDetector(
    onTap: () { HapticFeedback.selectionClick(); setState(() => _selected = t); _go(_PracticeTab.setup); },
    child: Container(
      padding: const EdgeInsets.all(13),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: t.iconBg, border: Border.all(color: t.iconBorder), borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(t.emoji, style: const TextStyle(fontSize: 19)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(t.title, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
            if (t.recommended) Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: t.tagBg, borderRadius: BorderRadius.circular(4)),
              child: Text(t.tag, style: GoogleFonts.dmSans(fontSize: 9, color: t.tagColor))),
          ]),
          const SizedBox(height: 2),
          Text(t.subtitle, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
          const SizedBox(height: 5),
          Row(children: [
            _metaChip(Icons.timer_outlined, '${t.minutes} min'),
            const SizedBox(width: 10),
            if (t.best != null) _metaChip(Icons.bar_chart_rounded, 'Best: ${t.best}'),
            if (t.best == null) Text('Not attempted', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textDisabled)),
            if (t.attempts > 0) ...[const SizedBox(width: 10), _metaChip(Icons.refresh_rounded, '${t.attempts} attempts')],
          ]),
        ])),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textDisabled),
      ]),
    ),
  );

  Widget _metaChip(IconData icon, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 11, color: AppColors.textDisabled),
    const SizedBox(width: 3),
    Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textDisabled)),
  ]);

  // ══════════════════════════════════════════
  // SETUP
  // ══════════════════════════════════════════
  Widget _setup() => Column(children: [
    Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        GestureDetector(onTap: () => _go(_PracticeTab.browse), child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
        const SizedBox(width: 12),
        Expanded(child: Text(_selected.title, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
      ]),
    ),
    Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(0), child: Column(children: [
      // Meta grid
      Padding(
        padding: const EdgeInsets.all(14),
        child: Container(
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Row(children: [
              Expanded(child: _metaCell('PAPER', _selected.paper, border: const Border(right: BorderSide(color: AppColors.border), bottom: BorderSide(color: AppColors.border)))),
              Expanded(child: _metaCell('QUESTIONS', '${_selected.questions} MCQ', border: const Border(bottom: BorderSide(color: AppColors.border)))),
            ]),
            Row(children: [
              Expanded(child: _metaCell('TIME LIMIT', '${_selected.minutes} minutes', border: const Border(right: BorderSide(color: AppColors.border)))),
              Expanded(child: _metaCell('YOUR BEST', _selected.best ?? 'Not yet', valueColor: _selected.best != null ? AppColors.success : AppColors.textDisabled)),
            ]),
          ]),
        ),
      ),

      // Settings
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SETTINGS', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.6)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              _toggleRow('Show timer', 'Count down during the test', _togTimer, () => setState(() => _togTimer = !_togTimer)),
              Container(height: 1, color: AppColors.border),
              _toggleRow('Show answer feedback', 'Highlight correct after submit', _togAns, () => setState(() => _togAns = !_togAns)),
              Container(height: 1, color: AppColors.border),
              _toggleRow('Sound effects', 'Audio cues on answer', _togSound, () => setState(() => _togSound = !_togSound)),
            ]),
          ),
        ]),
      ),

      // Warning
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.warningSurface, border: Border.all(color: AppColors.warning.withOpacity(0.4)), borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Icon(Icons.info_outline_rounded, size: 14, color: AppColors.warning),
            const SizedBox(width: 8),
            Expanded(child: Text('This is a timed test under exam conditions. Hints and explanations are hidden until you finish.', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.warning, height: 1.5))),
          ]),
        ),
      ),

      // Start button
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
        child: GestureDetector(
          onTap: () => _go(_PracticeTab.exam),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text('Start test', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ])),
          ),
        ),
      ),
    ]))),
  ]);

  Widget _metaCell(String label, String value, {Border? border, Color? valueColor}) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(border: border),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary, letterSpacing: 0.5)),
      const SizedBox(height: 3),
      Text(value, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: valueColor ?? AppColors.textPrimary)),
    ]),
  );

  Widget _toggleRow(String title, String sub, bool val, VoidCallback onTap) => GestureDetector(
    onTap: () { HapticFeedback.selectionClick(); onTap(); },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary)),
          Text(sub, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
        ])),
        Container(
          width: 40, height: 22,
          decoration: BoxDecoration(color: val ? AppColors.accent : AppColors.surfaceVariant, borderRadius: BorderRadius.circular(11)),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: val ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(margin: const EdgeInsets.all(2), width: 18, height: 18, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        ),
      ]),
    ),
  );

  // ══════════════════════════════════════════
  // EXAM
  // ══════════════════════════════════════════
  Widget _exam() {
    final q = _questions[_qi];
    final answered = _answers[_qi] != null;
    return Column(children: [
      // Progress bar
      Container(height: 3, color: AppColors.surfaceVariant,
        child: FractionallySizedBox(widthFactor: (_qi + 1) / _questions.length, alignment: Alignment.centerLeft,
          child: Container(color: AppColors.accent))),

      // Header
      Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(children: [
          GestureDetector(onTap: () => _go(_PracticeTab.browse), child: const Icon(Icons.close_rounded, size: 20, color: AppColors.textTertiary)),
          const SizedBox(width: 10),
          Expanded(child: Text('Question ${_qi + 1} of ${_questions.length}', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary))),
          Text('+50 XP', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accentLight)),
          const SizedBox(width: 10),
          _timerPill(),
        ]),
      ),

      // Question nav boxes
      Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: List.generate(_questions.length, (i) {
            String cls;
            if (i == _qi) cls = 'curr';
            else if (_flagged[i]) cls = 'flag';
            else if (_answers[i] != null) cls = 'done';
            else cls = 'todo';
            return GestureDetector(
              onTap: () { HapticFeedback.selectionClick(); setState(() => _qi = i); },
              child: Container(
                width: 26, height: 26, margin: const EdgeInsets.only(right: 3),
                decoration: BoxDecoration(
                  color: cls == 'curr' ? AppColors.accentSurface : cls == 'done' ? AppColors.surfaceVariant : cls == 'flag' ? const Color(0xFF2D1E00) : AppColors.surfaceVariant,
                  border: Border.all(color: cls == 'curr' ? AppColors.accent : cls == 'flag' ? const Color(0xFFC47D0E) : AppColors.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(child: Text('${i + 1}', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500,
                  color: cls == 'curr' ? AppColors.accentLight : cls == 'flag' ? const Color(0xFFE8960F) : AppColors.textTertiary))),
              ),
            );
          })),
        ),
      ),

      // Question
      Expanded(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('${q.topic} · ${q.diff}', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textDisabled)),
              const Spacer(),
              GestureDetector(
                onTap: () { HapticFeedback.selectionClick(); setState(() => _flagged[_qi] = !_flagged[_qi]); },
                child: Icon(Icons.flag_rounded, size: 16, color: _flagged[_qi] ? const Color(0xFFE8960F) : AppColors.textDisabled),
              ),
            ]),
            const SizedBox(height: 8),
            Text(q.q, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.65)),
          ]),
        ),
        Container(margin: const EdgeInsets.only(top: 14), height: 1, color: AppColors.border),

        // Answer options
        ...List.generate(q.opts.length, (i) {
          final selected = _answers[_qi] == i;
          return GestureDetector(
            onTap: answered ? null : () { HapticFeedback.selectionClick(); setState(() => _answers[_qi] = i); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: selected ? AppColors.accentSurface : Colors.transparent,
                border: const Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(children: [
                Container(width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.accent : Colors.transparent,
                    border: Border.all(color: selected ? AppColors.accent : AppColors.border, width: 1.5),
                  ),
                  child: Center(child: Text(String.fromCharCode(65 + i), style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: selected ? Colors.white : AppColors.textTertiary)))),
                const SizedBox(width: 12),
                Expanded(child: Text(q.opts[i], style: GoogleFonts.dmSans(fontSize: 13, color: selected ? AppColors.accentLight : AppColors.textSecondary, height: 1.5))),
              ]),
            ),
          );
        }),

        // Skip / Next
        Padding(
          padding: const EdgeInsets.all(14),
          child: answered
            ? GestureDetector(
                onTap: () { HapticFeedback.lightImpact(); setState(() { if (_qi < _questions.length - 1) _qi++; else _go(_PracticeTab.results); }); },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text(_qi >= _questions.length - 1 ? 'Submit test →' : 'Next →', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)))),
              )
            : GestureDetector(
                onTap: () { HapticFeedback.selectionClick(); setState(() { _flagged[_qi] = true; if (_qi < _questions.length - 1) _qi++; else _go(_PracticeTab.results); }); },
                child: Center(child: Text('Skip question →', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textTertiary))),
              ),
        ),
      ]))),
    ]);
  }

  Widget _timerPill() {
    final m = _timerSecs ~/ 60;
    final s = _timerSecs % 60;
    final warn = _timerSecs <= 300;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: warn ? AppColors.errorSurface : AppColors.surfaceVariant,
        border: Border.all(color: warn ? AppColors.error : AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.timer_outlined, size: 12, color: warn ? AppColors.error : AppColors.textTertiary),
        const SizedBox(width: 4),
        Text('${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
            style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: warn ? AppColors.error : AppColors.textSecondary)),
      ]),
    );
  }

  // ══════════════════════════════════════════
  // RESULTS
  // ══════════════════════════════════════════
  Widget _results() {
    final mm = _elapsed ~/ 60;
    final ss = _elapsed % 60;
    final title = _pct >= 80 ? 'Excellent work 🎉' : _pct >= 60 ? 'Good effort 💪' : 'Keep practising 📚';
    return Column(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(children: [
          Expanded(child: Text('Results', style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.accentSurface, borderRadius: BorderRadius.circular(8)),
            child: Text('+${_correct * 20} XP', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accentLight)),
          ),
        ]),
      ),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        // Score ring
        SizedBox(height: 140, child: Stack(alignment: Alignment.center, children: [
          AnimatedBuilder(animation: _ringAnim, builder: (_, __) => CustomPaint(
            size: const Size(130, 130),
            painter: _RingPainter(_ringAnim.value * _pct / 100),
          )),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$_pct%', style: GoogleFonts.dmSans(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Text(title, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
          ]),
        ])),
        const SizedBox(height: 16),

        // Stats row
        Container(
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Expanded(child: _statCell('$_correct', 'Correct', AppColors.success, border: const Border(right: BorderSide(color: AppColors.border)))),
            Expanded(child: _statCell('$_wrong', 'Wrong', AppColors.error, border: const Border(right: BorderSide(color: AppColors.border)))),
            Expanded(child: _statCell('$_skipped', 'Skipped', AppColors.warning, border: const Border(right: BorderSide(color: AppColors.border)))),
            Expanded(child: _statCell('${mm.toString().padLeft(2, '0')}m ${ss.toString().padLeft(2, '0')}s', 'Time', AppColors.textSecondary)),
          ]),
        ),
        const SizedBox(height: 14),

        // Topic breakdown
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('BY TOPIC', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.6)),
            const SizedBox(height: 10),
            _topicBar('Trigonometry', 0.9, AppColors.success),
            _topicBar('Algebra', 0.8, AppColors.success),
            _topicBar('Statistics', 0.6, AppColors.warning),
            _topicBar('Circle geo.', 0.4, AppColors.error),
          ]),
        ),
        const SizedBox(height: 14),

        // Gemini insight
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 5), decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Gemini insight', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accentLight)),
              const SizedBox(height: 4),
              Text('Circle geometry is your weakest area. Chord-tangent relationships cover 3 questions on this paper — a focused 20-minute session could recover 7+ marks.',
                  style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textSecondary, height: 1.65)),
            ])),
          ]),
        ),
        const SizedBox(height: 14),

        // CTAs
        GestureDetector(
          onTap: () => _go(_PracticeTab.review),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.visibility_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text('Review all answers', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            ])),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _go(_PracticeTab.setup),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text('Retry this test', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary))),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _go(_PracticeTab.browse),
          child: Center(child: Text('Browse more tests', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textTertiary))),
        ),
        const SizedBox(height: 16),
      ]))),
    ]);
  }

  Widget _statCell(String val, String label, Color color, {Border? border}) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(border: border),
    child: Column(children: [
      Text(val, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
      Text(label, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
    ]),
  );

  Widget _topicBar(String label, double pct, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      SizedBox(width: 90, child: Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary))),
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(value: pct, minHeight: 4, backgroundColor: AppColors.border, valueColor: AlwaysStoppedAnimation(color)))),
      const SizedBox(width: 8),
      SizedBox(width: 32, child: Text('${(pct * 100).round()}%', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: color), textAlign: TextAlign.right)),
    ]),
  );

  // ══════════════════════════════════════════
  // REVIEW
  // ══════════════════════════════════════════
  Widget _review() => Column(children: [
    Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        GestureDetector(onTap: () => _go(_PracticeTab.results), child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Answer review', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text(_selected.title, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: AppColors.successSurface, borderRadius: BorderRadius.circular(4)), child: Text('$_correct correct', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.success))),
        const SizedBox(width: 5),
        Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: AppColors.errorSurface, borderRadius: BorderRadius.circular(4)), child: Text('$_wrong wrong', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.error))),
      ]),
    ),
    Expanded(child: ListView.builder(
      itemCount: _questions.length,
      itemBuilder: (ctx, i) {
        final q = _questions[i];
        final chosen = _answers[i];
        final ok = chosen == q.ans;
        final skipped = chosen == null;
        return Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: skipped ? const Color(0xFF1C1800) : ok ? const Color(0xFF042018) : const Color(0xFF1A0707),
            border: const Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 24, height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: skipped ? const Color(0xFF2D1E00) : ok ? AppColors.successSurface : AppColors.errorSurface,
                  border: Border.all(color: skipped ? AppColors.warning : ok ? AppColors.success : AppColors.error),
                ),
                child: Center(child: Text(skipped ? '−' : ok ? '✓' : '✗',
                    style: TextStyle(fontSize: 11, color: skipped ? AppColors.warning : ok ? AppColors.success : AppColors.error)))),
              const SizedBox(width: 9),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Q${i + 1} · ${q.topic} · ${q.diff}', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textDisabled)),
                const SizedBox(height: 3),
                Text(q.q, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.5)),
              ])),
            ]),
            const SizedBox(height: 8),
            ...List.generate(q.opts.length, (j) {
              final isCorrect = j == q.ans;
              final isChosen = j == chosen;
              Color bg = Colors.transparent;
              Color tc = AppColors.textTertiary;
              Color lbg = AppColors.surfaceVariant;
              Color ltc = AppColors.textDisabled;
              if (isCorrect && isChosen) { bg = const Color(0xFF042018); tc = const Color(0xFF6EE7B7); lbg = AppColors.success; ltc = Colors.white; }
              else if (isChosen && !isCorrect) { bg = const Color(0xFF1A0707); tc = const Color(0xFFFCA5A5); lbg = AppColors.error; ltc = Colors.white; }
              else if (isCorrect) { bg = const Color(0xFF042018); tc = const Color(0xFF6EE7B7); lbg = AppColors.success; ltc = Colors.white; }
              return Container(
                margin: const EdgeInsets.only(bottom: 3),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
                child: Row(children: [
                  Container(width: 22, height: 22, decoration: BoxDecoration(shape: BoxShape.circle, color: lbg),
                    child: Center(child: Text(String.fromCharCode(65 + j), style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500, color: ltc)))),
                  const SizedBox(width: 8),
                  Expanded(child: Text(q.opts[j], style: GoogleFonts.dmSans(fontSize: 11, color: tc))),
                  if (isChosen && isCorrect) Text('Your answer ✓', style: GoogleFonts.dmSans(fontSize: 9, color: const Color(0xFF6EE7B7))),
                  if (isChosen && !isCorrect) Text('Your answer', style: GoogleFonts.dmSans(fontSize: 9, color: const Color(0xFFFCA5A5))),
                  if (!isChosen && isCorrect) Text('Correct', style: GoogleFonts.dmSans(fontSize: 9, color: const Color(0xFF6EE7B7))),
                ]),
              );
            }),
            if (!ok && !skipped) ...[
              const SizedBox(height: 4),
              Text('The correct answer is ${q.opts[q.ans]}', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
            ],
          ]),
        );
      },
    )),
  ]);
}

// ── Score ring painter ──
class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2 - 8;
    final bg = Paint()..color = const Color(0xFF1E1E24)..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round;
    final fg = Paint()..color = const Color(0xFF7C3AED)..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), r, bg);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), -1.5708, progress * 6.2832, false, fg);
  }
  @override bool shouldRepaint(_RingPainter old) => old.progress != progress;
}