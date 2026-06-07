enum ExamMode { objective, theory, combo }
enum ExamSubjectGroup { waec, jamb, international }

class ExamSubject {
  final String id;
  final String name;
  final String hint;
  final String emoji;
  final String iconBg;
  final ExamSubjectGroup group;

  const ExamSubject({
    required this.id,
    required this.name,
    required this.hint,
    required this.emoji,
    required this.iconBg,
    required this.group,
  });
}

class ExamConfig {
  final ExamSubject subject;
  final ExamMode mode;
  final int questionCount;
  final int secondsPerQuestion;

  const ExamConfig({
    required this.subject,
    required this.mode,
    required this.questionCount,
    required this.secondsPerQuestion,
  });
}

class ObjectiveQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const ObjectiveQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class TheoryQuestion {
  final String question;
  final int marks;
  final String modelAnswer;
  final List<MarkingPoint> markingPoints;

  const TheoryQuestion({
    required this.question,
    required this.marks,
    required this.modelAnswer,
    required this.markingPoints,
  });
}

class MarkingPoint {
  final String label;
  final int marks;
  final MarkingStatus status;
  final String feedback;

  const MarkingPoint({
    required this.label,
    required this.marks,
    required this.status,
    required this.feedback,
  });
}

enum MarkingStatus { correct, partial, wrong }

class ObjectiveAnswer {
  final int questionIndex;
  final int? chosenIndex;
  final bool correct;

  const ObjectiveAnswer({
    required this.questionIndex,
    required this.chosenIndex,
    required this.correct,
  });
}

class TheoryAnswer {
  final int questionIndex;
  final String writtenAnswer;
  final int scoreAwarded;
  final int totalMarks;

  const TheoryAnswer({
    required this.questionIndex,
    required this.writtenAnswer,
    required this.scoreAwarded,
    required this.totalMarks,
  });
}

class ExamResult {
  final ExamConfig config;
  final List<ObjectiveAnswer> objectiveAnswers;
  final List<TheoryAnswer> theoryAnswers;
  final int xpEarned;

  const ExamResult({
    required this.config,
    required this.objectiveAnswers,
    required this.theoryAnswers,
    required this.xpEarned,
  });

  int get objectiveCorrect => objectiveAnswers.where((a) => a.correct).length;
  int get objectiveTotal => objectiveAnswers.length;
  int get theoryScore => theoryAnswers.fold(0, (s, a) => s + a.scoreAwarded);
  int get theoryTotal => theoryAnswers.fold(0, (s, a) => s + a.totalMarks);

  int get overallPercent {
    final total = objectiveTotal + (theoryTotal > 0 ? 1 : 0);
    if (total == 0) return 0;
    final objPct = objectiveTotal > 0 ? objectiveCorrect / objectiveTotal * 100 : 0;
    final thPct = theoryTotal > 0 ? theoryScore / theoryTotal * 100 : 0;
    if (objectiveTotal > 0 && theoryTotal > 0) return ((objPct + thPct) / 2).round();
    if (objectiveTotal > 0) return objPct.round();
    return thPct.round();
  }

  String get grade {
    final p = overallPercent;
    if (p >= 75) return 'A1';
    if (p >= 70) return 'B2';
    if (p >= 65) return 'B3';
    if (p >= 60) return 'C4';
    if (p >= 55) return 'C5';
    if (p >= 50) return 'C6';
    if (p >= 45) return 'D7';
    if (p >= 40) return 'E8';
    return 'F9';
  }
}