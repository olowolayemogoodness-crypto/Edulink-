class AppConstants {
  AppConstants._();

  static const String appName         = 'EduLink';
  static const String appTagline      = 'AI-powered learning for every student';

  static const String usersCol        = 'users';
  static const String coursesCol      = 'courses';
  static const String quizzesCol      = 'quizzes';
  static const String flashcardsCol   = 'flashcards';
  static const String leaderboardCol  = 'leaderboard';
  static const String competitionsCol = 'competitions';
  static const String submissionsCol  = 'submissions';
  static const String badgesCol       = 'badges';
  static const String streaksCol      = 'streaks';

  static const String studyRoomsPath  = 'study_rooms';
  static const String presencePath    = 'presence';

  static const int streakGraceHours    = 26;
  static const int xpPerCorrectAnswer  = 10;
  static const int xpPerStreak         = 5;
  static const int xpPerLesson         = 50;

  static const int    scholarshipFeeKobo = 250000;
  static const String scholarshipPrize   = '₦1,000,000';

  static const List<String> examTypes = ['WAEC', 'JAMB', 'IELTS', 'TOEFL', 'GRE', 'SAT'];

  static const int pageSize    = 20;
  static const String geminiModel = 'gemini-1.5-flash';
  static const int maxTokens   = 1024;
}