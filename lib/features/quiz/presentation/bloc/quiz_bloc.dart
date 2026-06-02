
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
