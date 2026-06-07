import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/flashcard_model.dart';
import '../../data/mock_flashcards.dart';

// ── Events ──
abstract class FlashcardEvent {}
class FlashcardDeckSelected extends FlashcardEvent {
  final FlashcardDeck deck;
  FlashcardDeckSelected(this.deck);
}
class FlashcardFlipped extends FlashcardEvent {}
class FlashcardRated extends FlashcardEvent {
  final FlashcardRating rating;
  FlashcardRated(this.rating);
}
class FlashcardSessionReset extends FlashcardEvent {}

// ── States ──
abstract class FlashcardState {}
class FlashcardInitial extends FlashcardState {}

class FlashcardStudying extends FlashcardState {
  final FlashcardDeck deck;
  final List<FlashcardModel> cards;
  final int currentIndex;
  final bool isFlipped;
  final int streak;
  final int bestStreak;
  final int easyCount;
  final int againCount;

  FlashcardStudying({
    required this.deck,
    required this.cards,
    required this.currentIndex,
    required this.isFlipped,
    required this.streak,
    required this.bestStreak,
    required this.easyCount,
    required this.againCount,
  });

  FlashcardModel get currentCard => cards[currentIndex];
  double get progress => (currentIndex + 1) / cards.length;
  bool get isLast => currentIndex >= cards.length - 1;

  FlashcardStudying copyWith({
    int? currentIndex,
    bool? isFlipped,
    int? streak,
    int? bestStreak,
    int? easyCount,
    int? againCount,
  }) {
    return FlashcardStudying(
      deck: deck,
      cards: cards,
      currentIndex: currentIndex ?? this.currentIndex,
      isFlipped: isFlipped ?? this.isFlipped,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      easyCount: easyCount ?? this.easyCount,
      againCount: againCount ?? this.againCount,
    );
  }
}

class FlashcardSessionComplete extends FlashcardState {
  final FlashcardDeck deck;
  final FlashcardSession session;
  FlashcardSessionComplete({required this.deck, required this.session});
}

// ── BLoC ──
class FlashcardBloc extends Bloc<FlashcardEvent, FlashcardState> {
  FlashcardBloc() : super(FlashcardInitial()) {
    on<FlashcardDeckSelected>(_onDeckSelected);
    on<FlashcardFlipped>(_onFlipped);
    on<FlashcardRated>(_onRated);
    on<FlashcardSessionReset>(_onReset);
  }

  void _onDeckSelected(FlashcardDeckSelected event, Emitter<FlashcardState> emit) {
    final cards = MockFlashcards.getCards(event.deck.id);
    emit(FlashcardStudying(
      deck: event.deck,
      cards: cards,
      currentIndex: 0,
      isFlipped: false,
      streak: 0,
      bestStreak: 0,
      easyCount: 0,
      againCount: 0,
    ));
  }

  void _onFlipped(FlashcardFlipped event, Emitter<FlashcardState> emit) {
    final s = state as FlashcardStudying;
    emit(s.copyWith(isFlipped: !s.isFlipped));
  }

  void _onRated(FlashcardRated event, Emitter<FlashcardState> emit) {
    final s = state as FlashcardStudying;
    final isGood = event.rating == FlashcardRating.good ||
        event.rating == FlashcardRating.easy;
    final newStreak = isGood ? s.streak + 1 : 0;
    final newBest = newStreak > s.bestStreak ? newStreak : s.bestStreak;
    final newEasy = isGood ? s.easyCount + 1 : s.easyCount;
    final newAgain = !isGood ? s.againCount + 1 : s.againCount;

    if (s.isLast) {
      final xp = (newEasy * 5) + (newBest * 3);
      emit(FlashcardSessionComplete(
        deck: s.deck,
        session: FlashcardSession(
          easyCount: newEasy,
          againCount: newAgain,
          bestStreak: newBest,
          xpEarned: xp,
          totalReviewed: s.cards.length,
        ),
      ));
    } else {
      emit(s.copyWith(
        currentIndex: s.currentIndex + 1,
        isFlipped: false,
        streak: newStreak,
        bestStreak: newBest,
        easyCount: newEasy,
        againCount: newAgain,
      ));
    }
  }

  void _onReset(FlashcardSessionReset event, Emitter<FlashcardState> emit) {
    emit(FlashcardInitial());
  }
}