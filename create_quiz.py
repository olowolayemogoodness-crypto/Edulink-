import os

def w(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)
    print(f"✅ {path}")

w("lib/features/quiz/domain/models/quiz_question.dart", """
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String? formula;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.formula,
  });
}

class QuizResult {
  final int correct;
  final int wrong;
  final int bestStreak;
  final double avgTimeSeconds;
  final List<QuizAnswerRecord> answers;
  final int xpEarned;

  const QuizResult({
    required this.correct,
    required this.wrong,
    required this.bestStreak,
    required this.avgTimeSeconds,
    required this.answers,
    required this.xpEarned,
  });

  int get total => correct + wrong;
  int get accuracyPercent => total > 0 ? (correct / total * 100).round() : 0;
}

class QuizAnswerRecord {
  final String question;
  final bool correct;
  final int secondsTaken;

  const QuizAnswerRecord({
    required this.question,
    required this.correct,
    required this.secondsTaken,
  });
}

enum QuizDifficulty { easy, medium, hard }
enum QuizMode { timed, free, battle }
""")

w("lib/features/quiz/data/mock_questions.dart", """
import '../domain/models/quiz_question.dart';

class MockQuestions {
  static const List<QuizQuestion> dataStructures = [
    QuizQuestion(
      question: "In a Binary Search Tree (BST), where is the smallest element always located?",
      options: ["At the root node", "At the rightmost node", "At the leftmost node", "At the leaf node closest to root"],
      correctIndex: 2,
      explanation: "In a BST, all left child values are smaller than their parent. So the smallest element is always at the leftmost node.",
    ),
    QuizQuestion(
      question: "What is the time complexity of searching in a balanced BST?",
      options: ["O(n)", "O(log n)", "O(1)", "O(n^2)"],
      correctIndex: 1,
      explanation: "A balanced BST halves the search space at each step, giving O(log n).",
    ),
    QuizQuestion(
      question: "Which traversal visits nodes in ascending order in a BST?",
      options: ["Pre-order", "Post-order", "In-order", "Level-order"],
      correctIndex: 2,
      explanation: "In-order traversal (Left, Root, Right) visits BST nodes in ascending sorted order.",
    ),
    QuizQuestion(
      question: "What data structure uses LIFO order?",
      options: ["Queue", "Stack", "Linked list", "Heap"],
      correctIndex: 1,
      explanation: "A Stack uses LIFO — the last element pushed is the first to be popped.",
    ),
    QuizQuestion(
      question: "What is the height of a complete binary tree with 7 nodes?",
      options: ["2", "3", "4", "1"],
      correctIndex: 0,
      explanation: "A complete binary tree with 7 nodes has height 2 (0-indexed).",
    ),
    QuizQuestion(
      question: "Which data structure is best for implementing a priority queue?",
      options: ["Array", "Linked list", "Heap", "Stack"],
      correctIndex: 2,
      explanation: "A Heap supports O(log n) insert and O(1) peek at the highest-priority element.",
    ),
    QuizQuestion(
      question: "What is the space complexity of DFS on a graph with V vertices?",
      options: ["O(V)", "O(E)", "O(V + E)", "O(1)"],
      correctIndex: 0,
      explanation: "DFS uses a stack proportional to the depth, which is at most O(V).",
    ),
    QuizQuestion(
      question: "In a hash table, what is a collision?",
      options: ["When two keys map to the same index", "When the table is full", "When a key is deleted", "When search returns null"],
      correctIndex: 0,
      explanation: "A collision occurs when two different keys produce the same hash index.",
    ),
    QuizQuestion(
      question: "Which sorting algorithm has the best average-case time complexity?",
      options: ["Bubble sort", "Insertion sort", "Merge sort", "Selection sort"],
      correctIndex: 2,
      explanation: "Merge sort runs in O(n log n) in all cases using divide and conquer.",
    ),
    QuizQuestion(
      question: "What does BFS use internally to track nodes to visit?",
      options: ["Stack", "Queue", "Heap", "Array"],
      correctIndex: 1,
      explanation: "BFS uses a Queue (FIFO) to explore nodes level by level.",
    ),
  ];

  static List<QuizQuestion> getQuestions({
    required String topic,
    required QuizDifficulty difficulty,
    int count = 10,
  }) {
    // TODO: Replace with Gemini API call
    final questions = List<QuizQuestion>.from(dataStructures);
    questions.shuffle();
    return questions.take(count).toList();
  }
}
""")

w("lib/features/quiz/presentation/bloc/quiz_bloc.dart", """
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/quiz_question.dart';
import '../../data/mock_questions.dart';

// ── Events ──
abstract class QuizEvent {}
class QuizStarted extends QuizEvent {
  final String topic;
  final QuizDifficulty difficulty;
  final QuizMode mode;
  QuizStarted({required this.topic, required this.difficulty, required this.mode});
}
class QuizAnswerSelected extends QuizEvent {
  final int selectedIndex;
  final int secondsTaken;
  QuizAnswerSelected({required this.selectedIndex, required this.secondsTaken});
}
class QuizNextQuestion extends QuizEvent {}
class QuizTimedOut extends QuizEvent {}
class QuizReset extends QuizEvent {}

// ── States ──
abstract class QuizState {}
class QuizInitial extends QuizState {}

class QuizInProgress extends QuizState {
  final List<QuizQuestion> questions;
  final int currentIndex;
  final int lives;
  final int streak;
  final int bestStreak;
  final int correct;
  final int wrong;
  final int? selectedIndex;
  final bool answered;
  final QuizMode mode;
  final QuizDifficulty difficulty;

  QuizInProgress({
    required this.questions,
    required this.currentIndex,
    required this.lives,
    required this.streak,
    required this.bestStreak,
    required this.correct,
    required this.wrong,
    required this.mode,
    required this.difficulty,
    this.selectedIndex,
    this.answered = false,
  });

  QuizQuestion get currentQuestion => questions[currentIndex];
  double get progress => (currentIndex + 1) / questions.length;
  bool get isLastQuestion => currentIndex >= questions.length - 1;

  QuizInProgress copyWith({
    int? currentIndex, int? lives, int? streak, int? bestStreak,
    int? correct, int? wrong, int? selectedIndex, bool? answered,
  }) {
    return QuizInProgress(
      questions: questions, mode: mode, difficulty: difficulty,
      currentIndex: currentIndex ?? this.currentIndex,
      lives: lives ?? this.lives,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      correct: correct ?? this.correct,
      wrong: wrong ?? this.wrong,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      answered: answered ?? this.answered,
    );
  }
}

class QuizFinished extends QuizState {
  final QuizResult result;
  QuizFinished({required this.result});
}

// ── BLoC ──
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final List<QuizAnswerRecord> _answers = [];
  final List<int> _times = [];

  QuizBloc() : super(QuizInitial()) {
    on<QuizStarted>(_onStarted);
    on<QuizAnswerSelected>(_onAnswerSelected);
    on<QuizNextQuestion>(_onNextQuestion);
    on<QuizTimedOut>(_onTimedOut);
    on<QuizReset>(_onReset);
  }

  void _onStarted(QuizStarted event, Emitter<QuizState> emit) {
    _answers.clear(); _times.clear();
    final questions = MockQuestions.getQuestions(
      topic: event.topic, difficulty: event.difficulty,
    );
    emit(QuizInProgress(
      questions: questions, currentIndex: 0, lives: 3,
      streak: 0, bestStreak: 0, correct: 0, wrong: 0,
      mode: event.mode, difficulty: event.difficulty,
    ));
  }

  void _onAnswerSelected(QuizAnswerSelected event, Emitter<QuizState> emit) {
    final s = state as QuizInProgress;
    if (s.answered) return;
    final isCorrect = event.selectedIndex == s.currentQuestion.correctIndex;
    final newStreak = isCorrect ? s.streak + 1 : 0;
    final newBest = newStreak > s.bestStreak ? newStreak : s.bestStreak;
    _answers.add(QuizAnswerRecord(
      question: s.currentQuestion.question,
      correct: isCorrect,
      secondsTaken: event.secondsTaken,
    ));
    _times.add(event.secondsTaken);
    emit(s.copyWith(
      selectedIndex: event.selectedIndex,
      answered: true,
      correct: isCorrect ? s.correct + 1 : s.correct,
      wrong: isCorrect ? s.wrong : s.wrong + 1,
      streak: newStreak,
      bestStreak: newBest,
      lives: isCorrect ? s.lives : s.lives - 1,
    ));
  }

  void _onNextQuestion(QuizNextQuestion event, Emitter<QuizState> emit) {
    final s = state as QuizInProgress;
    if (s.isLastQuestion) {
      _finish(s, emit);
    } else {
      emit(s.copyWith(currentIndex: s.currentIndex + 1, selectedIndex: -1, answered: false));
    }
  }

  void _onTimedOut(QuizTimedOut event, Emitter<QuizState> emit) {
    final s = state as QuizInProgress;
    if (s.answered) return;
    _answers.add(QuizAnswerRecord(question: s.currentQuestion.question, correct: false, secondsTaken: 30));
    _times.add(30);
    emit(s.copyWith(answered: true, selectedIndex: -1, wrong: s.wrong + 1, streak: 0, lives: s.lives - 1));
  }

  void _onReset(QuizReset event, Emitter<QuizState> emit) {
    _answers.clear(); _times.clear();
    emit(QuizInitial());
  }

  void _finish(QuizInProgress s, Emitter<QuizState> emit) {
    final avg = _times.isNotEmpty ? _times.reduce((a, b) => a + b) / _times.length : 0.0;
    emit(QuizFinished(result: QuizResult(
      correct: s.correct, wrong: s.wrong, bestStreak: s.bestStreak,
      avgTimeSeconds: avg, answers: List.from(_answers),
      xpEarned: 50 + s.bestStreak * 5,
    )));
  }
}
""")

w("lib/features/quiz/presentation/pages/quiz_setup_page.dart", """
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
""")

w("lib/features/quiz/presentation/pages/quiz_question_page.dart", """
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
                    Text('Question \${s.currentIndex + 1} of \${s.questions.length}',
                      style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
                    Text('+\${50 + s.bestStreak * 5} XP',
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
                Text(' \${s.lives} lives', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFF2D1E00), borderRadius: BorderRadius.circular(20)),
                  child: Text('🔥 \${s.streak}', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFFE8960F))),
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
        Text('0:\${secs.toString().padLeft(2, '0')}',
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
""")

w("lib/features/quiz/presentation/pages/quiz_results_page.dart", """
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
                    Text('\$pct%', style: GoogleFonts.dmSans(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
                Text('+\$_displayXp', style: GoogleFonts.dmSans(fontSize: 36, fontWeight: FontWeight.w600, color: const Color(0xFFE8960F))),
                Text('Base 50 · streak bonus +\${r.bestStreak * 5}', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
              ]),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.2,
              children: [
                _StatTile(label: 'Correct', value: '\${r.correct}', color: const Color(0xFF059669)),
                _StatTile(label: 'Incorrect', value: '\${r.wrong}', color: const Color(0xFFEA580C)),
                _StatTile(label: 'Best streak', value: '\${r.bestStreak}', color: AppColors.accentLight),
                _StatTile(label: 'Avg / question', value: '\${r.avgTimeSeconds.round()}s', color: const Color(0xFFE8960F)),
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
                        a.question.length > 48 ? '\${a.question.substring(0, 48)}…' : a.question,
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
""")

w("lib/features/quiz/presentation/pages/quiz_page.dart", """
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/quiz_bloc.dart';
import 'quiz_setup_page.dart';
import 'quiz_question_page.dart';
import 'quiz_results_page.dart';

class QuizPage extends StatelessWidget {
  final String topic;
  const QuizPage({super.key, this.topic = 'Data Structures'});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizBloc(),
      child: BlocBuilder<QuizBloc, QuizState>(
        builder: (context, state) {
          if (state is QuizInProgress) return const QuizQuestionPage();
          if (state is QuizFinished) return const QuizResultsPage();
          return QuizSetupPage(topic: topic);
        },
      ),
    );
  }
}
""")

print()
print("🎉 All quiz files created successfully!")
print()
print("Next: wire up navigation from the Quiz card on the home screen.")