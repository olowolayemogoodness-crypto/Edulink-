
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
