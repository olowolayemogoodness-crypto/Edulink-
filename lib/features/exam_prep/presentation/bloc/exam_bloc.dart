import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/exam_model.dart';
import '../../data/mock_exam_data.dart';

// ── Events ──
abstract class ExamEvent {}

class ExamModeSelected extends ExamEvent {
  final ExamMode mode;
  ExamModeSelected(this.mode);
}

class ExamConfigured extends ExamEvent {
  final ExamConfig config;
  ExamConfigured(this.config);
}

class ExamObjectiveAnswered extends ExamEvent {
  final int questionIndex;
  final int chosenIndex;
  ExamObjectiveAnswered({required this.questionIndex, required this.chosenIndex});
}

class ExamObjectiveNext extends ExamEvent {}

class ExamTheorySubmitted extends ExamEvent {
  final int questionIndex;
  final String answer;
  ExamTheorySubmitted({required this.questionIndex, required this.answer});
}

class ExamTheoryNext extends ExamEvent {}

class ExamReset extends ExamEvent {}

class ExamTimedOut extends ExamEvent {}

// ── States ──
abstract class ExamState {}

class ExamInitial extends ExamState {}

class ExamModeChoosing extends ExamState {
  final ExamMode? selectedMode;
  ExamModeChoosing({this.selectedMode});
}

class ExamSetup extends ExamState {
  final ExamMode mode;
  ExamSetup({required this.mode});
}

class ExamObjectiveInProgress extends ExamState {
  final ExamConfig config;
  final List<ObjectiveQuestion> questions;
  final int currentIndex;
  final int? selectedIndex;
  final bool answered;
  final List<ObjectiveAnswer> answers;

  ExamObjectiveInProgress({
    required this.config,
    required this.questions,
    required this.currentIndex,
    required this.answers,
    this.selectedIndex,
    this.answered = false,
  });

  ObjectiveQuestion get currentQuestion => questions[currentIndex];
  double get progress => (currentIndex + 1) / questions.length;
  bool get isLast => currentIndex >= questions.length - 1;

  ExamObjectiveInProgress copyWith({
    int? currentIndex,
    int? selectedIndex,
    bool? answered,
    List<ObjectiveAnswer>? answers,
  }) {
    return ExamObjectiveInProgress(
      config: config,
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      answered: answered ?? this.answered,
      answers: answers ?? this.answers,
    );
  }
}

class ExamTheoryInProgress extends ExamState {
  final ExamConfig config;
  final List<TheoryQuestion> questions;
  final int currentIndex;
  final bool submitted;
  final int? scoreAwarded;
  final List<TheoryAnswer> answers;
  final List<ObjectiveAnswer> objectiveAnswers;

  ExamTheoryInProgress({
    required this.config,
    required this.questions,
    required this.currentIndex,
    required this.answers,
    required this.objectiveAnswers,
    this.submitted = false,
    this.scoreAwarded,
  });

  TheoryQuestion get currentQuestion => questions[currentIndex];
  double get progress => (currentIndex + 1) / questions.length;
  bool get isLast => currentIndex >= questions.length - 1;

  ExamTheoryInProgress copyWith({
    int? currentIndex,
    bool? submitted,
    int? scoreAwarded,
    List<TheoryAnswer>? answers,
  }) {
    return ExamTheoryInProgress(
      config: config,
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      objectiveAnswers: objectiveAnswers,
      submitted: submitted ?? this.submitted,
      scoreAwarded: scoreAwarded ?? this.scoreAwarded,
    );
  }
}

class ExamFinished extends ExamState {
  final ExamResult result;
  ExamFinished({required this.result});
}

// ── BLoC ──
class ExamBloc extends Bloc<ExamEvent, ExamState> {
  ExamBloc() : super(ExamInitial()) {
    on<ExamModeSelected>(_onModeSelected);
    on<ExamConfigured>(_onConfigured);
    on<ExamObjectiveAnswered>(_onObjectiveAnswered);
    on<ExamObjectiveNext>(_onObjectiveNext);
    on<ExamTheorySubmitted>(_onTheorySubmitted);
    on<ExamTheoryNext>(_onTheoryNext);
    on<ExamReset>(_onReset);
    on<ExamTimedOut>(_onTimedOut);
  }

  void _onModeSelected(ExamModeSelected event, Emitter<ExamState> emit) {
    emit(ExamSetup(mode: event.mode));
  }

  void _onConfigured(ExamConfigured event, Emitter<ExamState> emit) {
    final config = event.config;
    if (config.mode == ExamMode.theory) {
      final questions = MockExamData.getTheoryQuestions(config.subject.id, count: config.questionCount);
      emit(ExamTheoryInProgress(
        config: config,
        questions: questions,
        currentIndex: 0,
        answers: [],
        objectiveAnswers: [],
      ));
    } else {
      final questions = MockExamData.getObjectiveQuestions(config.subject.id, count: config.questionCount);
      emit(ExamObjectiveInProgress(
        config: config,
        questions: questions,
        currentIndex: 0,
        answers: [],
      ));
    }
  }

  void _onObjectiveAnswered(ExamObjectiveAnswered event, Emitter<ExamState> emit) {
    final s = state as ExamObjectiveInProgress;
    if (s.answered) return;
    final isCorrect = event.chosenIndex == s.currentQuestion.correctIndex;
    emit(s.copyWith(
      selectedIndex: event.chosenIndex,
      answered: true,
      answers: [...s.answers, ObjectiveAnswer(
        questionIndex: event.questionIndex,
        chosenIndex: event.chosenIndex,
        correct: isCorrect,
      )],
    ));
  }

  void _onObjectiveNext(ExamObjectiveNext event, Emitter<ExamState> emit) {
    final s = state as ExamObjectiveInProgress;
    if (s.isLast) {
      if (s.config.mode == ExamMode.combo) {
        final theoryQs = MockExamData.getTheoryQuestions(s.config.subject.id, count: s.config.questionCount);
        emit(ExamTheoryInProgress(
          config: s.config,
          questions: theoryQs,
          currentIndex: 0,
          answers: [],
          objectiveAnswers: s.answers,
        ));
      } else {
        _finishExam(s.config, s.answers, [], emit);
      }
    } else {
      emit(s.copyWith(
        currentIndex: s.currentIndex + 1,
        selectedIndex: -1,
        answered: false,
      ));
    }
  }

  void _onTheorySubmitted(ExamTheorySubmitted event, Emitter<ExamState> emit) {
    final s = state as ExamTheoryInProgress;
    final q = s.currentQuestion;
    final score = (q.marks * 0.75).round();
    emit(s.copyWith(submitted: true, scoreAwarded: score));
  }

  void _onTheoryNext(ExamTheoryNext event, Emitter<ExamState> emit) {
    final s = state as ExamTheoryInProgress;
    final q = s.currentQuestion;
    final score = s.scoreAwarded ?? (q.marks * 0.75).round();
    final newAnswers = [...s.answers, TheoryAnswer(
      questionIndex: s.currentIndex,
      writtenAnswer: '',
      scoreAwarded: score,
      totalMarks: q.marks,
    )];
    if (s.isLast) {
      _finishExam(s.config, s.objectiveAnswers, newAnswers, emit);
    } else {
      emit(s.copyWith(
        currentIndex: s.currentIndex + 1,
        submitted: false,
        scoreAwarded: null,
        answers: newAnswers,
      ));
    }
  }

  void _onTimedOut(ExamTimedOut event, Emitter<ExamState> emit) {
    if (state is ExamObjectiveInProgress) {
      final s = state as ExamObjectiveInProgress;
      if (s.answered) return;
      emit(s.copyWith(answered: true, selectedIndex: -1));
    }
  }

  void _onReset(ExamReset event, Emitter<ExamState> emit) {
    emit(ExamInitial());
  }

  void _finishExam(
    ExamConfig config,
    List<ObjectiveAnswer> objAnswers,
    List<TheoryAnswer> thAnswers,
    Emitter<ExamState> emit,
  ) {
    final xp = objAnswers.where((a) => a.correct).length * 10 +
        thAnswers.fold<int>(0, (s, a) => s + a.scoreAwarded);
    emit(ExamFinished(result: ExamResult(
      config: config,
      objectiveAnswers: objAnswers,
      theoryAnswers: thAnswers,
      xpEarned: xp,
    )));
  }
}