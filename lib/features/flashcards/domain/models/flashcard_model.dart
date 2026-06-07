class FlashcardModel {
  final String id;
  final String front;
  final String back;
  final String topic;
  FlashcardRating rating;
  int reviewCount;

  FlashcardModel({
    required this.id,
    required this.front,
    required this.back,
    required this.topic,
    this.rating = FlashcardRating.unseen,
    this.reviewCount = 0,
  });
}

enum FlashcardRating { unseen, again, hard, good, easy }

class FlashcardDeck {
  final String id;
  final String name;
  final String subtitle;
  final String emoji;
  final int totalCards;
  final int dueCount;
  final double progress;
  final DeckColor color;

  const FlashcardDeck({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.emoji,
    required this.totalCards,
    required this.dueCount,
    required this.progress,
    required this.color,
  });

  bool get allDone => dueCount == 0;
}

enum DeckColor { violet, teal, amber, pink }

class FlashcardSession {
  final int easyCount;
  final int againCount;
  final int bestStreak;
  final int xpEarned;
  final int totalReviewed;

  const FlashcardSession({
    required this.easyCount,
    required this.againCount,
    required this.bestStreak,
    required this.xpEarned,
    required this.totalReviewed,
  });

  int get accuracyPercent =>
      totalReviewed > 0 ? (easyCount / totalReviewed * 100).round() : 0;
}