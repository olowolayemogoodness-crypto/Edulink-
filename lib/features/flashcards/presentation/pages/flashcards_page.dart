import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/flashcard_bloc.dart';
import '../../domain/models/flashcard_model.dart';
import '../../data/mock_flashcards.dart';

class FlashcardsPage extends StatelessWidget {
  const FlashcardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FlashcardBloc(),
      child: BlocBuilder<FlashcardBloc, FlashcardState>(
        builder: (context, state) {
          if (state is FlashcardStudying) return const _StudyScreen();
          if (state is FlashcardSessionComplete) return const _ResultsScreen();
          return const _DeckSelectScreen();
        },
      ),
    );
  }
}

// ════════════════════════════════════════
// SCREEN 1 — DECK SELECTION
// ════════════════════════════════════════
class _DeckSelectScreen extends StatelessWidget {
  const _DeckSelectScreen();

  @override
  Widget build(BuildContext context) {
    final due = MockFlashcards.decks.where((d) => d.dueCount > 0).toList();

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
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text('Flashcards',
                  style: GoogleFonts.dmSans(fontSize: 17,
                      fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border)),
                child: const Icon(Icons.add_rounded,
                    size: 18, color: AppColors.textSecondary),
              ),
            ]),
          ),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 4),
              _sectionLabel('Due today'),
              const SizedBox(height: 9),
              ...due.map((d) => _DeckCard(deck: d, highlighted: true)),
              const SizedBox(height: 14),
              _sectionLabel('All decks'),
              const SizedBox(height: 9),
              ...MockFlashcards.decks
                  .where((d) => d.dueCount == 0)
                  .map((d) => _DeckCard(deck: d, highlighted: false)),
              _AddDeckCard(),
              const SizedBox(height: 10),
              _StreakBanner(),
              const SizedBox(height: 20),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _sectionLabel(String t) => Text(t.toUpperCase(),
      style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500,
          color: AppColors.textTertiary, letterSpacing: 0.5));
}

class _DeckCard extends StatelessWidget {
  final FlashcardDeck deck;
  final bool highlighted;
  const _DeckCard({required this.deck, required this.highlighted});

  Color get _activeBg => switch (deck.color) {
    DeckColor.violet => const Color(0xFF1E1240),
    DeckColor.teal   => const Color(0xFF052E1E),
    DeckColor.amber  => const Color(0xFF2D1E00),
    DeckColor.pink   => const Color(0xFF2D0A1E),
  };

  Color get _activeBorder => switch (deck.color) {
    DeckColor.violet => const Color(0xFF2D1B6B),
    DeckColor.teal   => const Color(0xFF0EA472),
    DeckColor.amber  => const Color(0xFFC47D0E),
    DeckColor.pink   => const Color(0xFFEC4899),
  };

  Color get _iconBg => switch (deck.color) {
    DeckColor.violet => const Color(0xFF2D1B6B),
    DeckColor.teal   => const Color(0xFF052E1E),
    DeckColor.amber  => const Color(0xFF2D1E00),
    DeckColor.pink   => const Color(0xFF2D0A1E),
  };

  Color get _progressColor => switch (deck.color) {
    DeckColor.violet => const Color(0xFF7C3AED),
    DeckColor.teal   => const Color(0xFF0EA472),
    DeckColor.amber  => const Color(0xFFC47D0E),
    DeckColor.pink   => const Color(0xFFEC4899),
  };

  Color get _dueColor =>
      deck.allDone ? const Color(0xFF0EA472) : const Color(0xFFEA580C);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<FlashcardBloc>().add(FlashcardDeckSelected(deck)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: highlighted ? _activeBg : AppColors.surface,
          border: Border.all(
              color: highlighted ? _activeBorder : AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
                color: _iconBg, borderRadius: BorderRadius.circular(12)),
            child: Center(
                child: Text(deck.emoji,
                    style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(deck.name,
                style: GoogleFonts.dmSans(fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(deck.subtitle,
                style: GoogleFonts.dmSans(
                    fontSize: 10, color: AppColors.textTertiary)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: deck.progress,
                minHeight: 5,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(_progressColor),
              ),
            ),
          ])),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${deck.dueCount}',
                style: GoogleFonts.dmSans(fontSize: 16,
                    fontWeight: FontWeight.w600, color: _dueColor)),
            Text(deck.allDone ? 'all done!' : 'due now',
                style: GoogleFonts.dmSans(fontSize: 9,
                    color: deck.allDone
                        ? const Color(0xFF0EA472)
                        : AppColors.textTertiary)),
          ]),
        ]),
      ),
    );
  }
}

class _AddDeckCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.add_rounded, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Text('Create a new deck',
            style: GoogleFonts.dmSans(
                fontSize: 13, color: AppColors.textTertiary)),
      ]),
    );
  }
}

class _StreakBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1E00),
        border: Border.all(color: const Color(0xFFC47D0E)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        const Text('🔥', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Daily streak at risk!',
              style: GoogleFonts.dmSans(fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFE8960F))),
          const SizedBox(height: 1),
          Text('Review 24 cards to keep your 14-day streak alive',
              style: GoogleFonts.dmSans(
                  fontSize: 10, color: AppColors.textTertiary)),
        ])),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => context.read<FlashcardBloc>().add(
              FlashcardDeckSelected(MockFlashcards.decks[0])),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
                color: const Color(0xFFC47D0E),
                borderRadius: BorderRadius.circular(10)),
            child: Text('Review',
                style: GoogleFonts.dmSans(fontSize: 11,
                    fontWeight: FontWeight.w500, color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════
// SCREEN 2 — STUDY CARD
// ════════════════════════════════════════
class _StudyScreen extends StatelessWidget {
  const _StudyScreen();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlashcardBloc, FlashcardState>(
      builder: (context, state) {
        if (state is! FlashcardStudying) return const SizedBox();
        final s = state;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context
                      .read<FlashcardBloc>()
                      .add(FlashcardSessionReset()),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.textTertiary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    Text('${s.currentIndex + 1} / ${s.cards.length}',
                        style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppColors.textTertiary)),
                    Text('+5 XP per card',
                        style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppColors.accentLight)),
                  ]),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: s.progress,
                      minHeight: 5,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(
                          AppColors.accent),
                    ),
                  ),
                ])),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFF2D1E00),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('🔥 ${s.streak}',
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFE8960F))),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(children: [
                _legendChip('Again', const Color(0xFFEA580C),
                    const Color(0xFF2D1200), Icons.refresh_rounded),
                const SizedBox(width: 6),
                _legendChip('Hard', const Color(0xFFE8960F),
                    const Color(0xFF2D1E00), Icons.remove_rounded),
                const SizedBox(width: 6),
                _legendChip('Good', const Color(0xFF0EA472),
                    const Color(0xFF052E1E), Icons.check_rounded),
                const SizedBox(width: 6),
                _legendChip('Easy', AppColors.accentLight,
                    const Color(0xFF1E1240), Icons.star_rounded),
              ]),
            ),
            Expanded(child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                _FlashCard(
                    card: s.currentCard, isFlipped: s.isFlipped),
                const SizedBox(height: 14),
                if (s.isFlipped) _RatingButtons() else _SwipeHint(),
                const SizedBox(height: 24),
              ]),
            )),
          ])),
        );
      },
    );
  }

  Widget _legendChip(
      String label, Color color, Color bg, IconData icon) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.dmSans(fontSize: 9, color: color)),
      ]),
    );
  }
}

class _FlashCard extends StatelessWidget {
  final FlashcardModel card;
  final bool isFlipped;
  const _FlashCard({required this.card, required this.isFlipped});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.read<FlashcardBloc>().add(FlashcardFlipped()),
      child: SizedBox(
        height: 240,
        child: Stack(children: [
          Positioned(
            bottom: 0, left: 8, right: 8,
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A21),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
            ),
          ),
          Positioned(
            bottom: 3, left: 4, right: 4,
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isFlipped
                  ? const Color(0xFF052E1E)
                  : const Color(0xFF1E1240),
              border: Border.all(
                color: isFlipped
                    ? const Color(0xFF0EA472)
                    : const Color(0xFF2D1B6B),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                Row(children: [
                  Container(
                    width: 5, height: 5,
                    decoration: BoxDecoration(
                      color: isFlipped
                          ? const Color(0xFF0EA472)
                          : AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(card.topic,
                      style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: isFlipped
                              ? const Color(0xFF0EA472)
                              : AppColors.accentLight)),
                ]),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isFlipped
                        ? const Color(0xFF052E1E)
                        : const Color(0xFF2D1B6B),
                    border: isFlipped
                        ? Border.all(
                            color: const Color(0xFF0EA472),
                            width: 0.5)
                        : null,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(isFlipped ? 'Answer' : 'Front',
                      style: GoogleFonts.dmSans(
                          fontSize: 9,
                          color: isFlipped
                              ? const Color(0xFF0EA472)
                              : AppColors.accentLight)),
                ),
              ]),
              Expanded(
                child: Center(
                  child: Text(
                    isFlipped ? card.back : card.front,
                    style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Icon(
                  isFlipped
                      ? Icons.lightbulb_outline_rounded
                      : Icons.touch_app_rounded,
                  size: 14,
                  color: isFlipped
                      ? const Color(0xFF0EA472)
                      : AppColors.accentLight,
                ),
                const SizedBox(width: 6),
                Text(
                  isFlipped
                      ? 'Rate how well you knew this'
                      : 'Tap to reveal answer',
                  style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: isFlipped
                          ? const Color(0xFF0EA472)
                          : AppColors.accentLight),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _RatingButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('How well did you know this?',
          style: GoogleFonts.dmSans(
              fontSize: 10, color: AppColors.textTertiary)),
      const SizedBox(height: 8),
      Row(children: [
        _RatingBtn(
          label: 'Again', sub: '1 min',
          icon: Icons.refresh_rounded,
          color: const Color(0xFFEA580C),
          bg: const Color(0xFF2D1200),
          border: const Color(0xFFEA580C),
          rating: FlashcardRating.again,
        ),
        const SizedBox(width: 8),
        _RatingBtn(
          label: 'Hard', sub: '10 min',
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFFE8960F),
          bg: const Color(0xFF2D1E00),
          border: const Color(0xFFC47D0E),
          rating: FlashcardRating.hard,
        ),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        _RatingBtn(
          label: 'Good', sub: 'Tomorrow',
          icon: Icons.thumb_up_rounded,
          color: const Color(0xFF0EA472),
          bg: const Color(0xFF052E1E),
          border: const Color(0xFF0EA472),
          rating: FlashcardRating.good,
        ),
        const SizedBox(width: 8),
        _RatingBtn(
          label: 'Easy', sub: '4 days',
          icon: Icons.star_rounded,
          color: AppColors.accentLight,
          bg: const Color(0xFF1E1240),
          border: AppColors.accent,
          rating: FlashcardRating.easy,
        ),
      ]),
    ]);
  }
}

class _RatingBtn extends StatelessWidget {
  final String label, sub;
  final IconData icon;
  final Color color, bg, border;
  final FlashcardRating rating;
  const _RatingBtn({
    required this.label, required this.sub,
    required this.icon, required this.color,
    required this.bg, required this.border,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            context.read<FlashcardBloc>().add(FlashcardRated(rating)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color)),
            Text(sub,
                style: GoogleFonts.dmSans(
                    fontSize: 9,
                    color: AppColors.textTertiary)),
          ]),
        ),
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
      Row(children: [
        const Icon(Icons.arrow_back_rounded,
            size: 13, color: Color(0xFF2E2B3D)),
        const SizedBox(width: 5),
        Text('Again',
            style: GoogleFonts.dmSans(
                fontSize: 10, color: const Color(0xFF2E2B3D))),
      ]),
      Row(children: [
        Text('Easy',
            style: GoogleFonts.dmSans(
                fontSize: 10, color: const Color(0xFF2E2B3D))),
        const SizedBox(width: 5),
        const Icon(Icons.arrow_forward_rounded,
            size: 13, color: Color(0xFF2E2B3D)),
      ]),
    ]);
  }
}

// ════════════════════════════════════════
// SCREEN 3 — RESULTS
// ════════════════════════════════════════
class _ResultsScreen extends StatefulWidget {
  const _ResultsScreen();
  @override
  State<_ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<_ResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _xpCtrl;
  late Animation<double> _xpAnim;
  int _displayXp = 0;

  @override
  void initState() {
    super.initState();
    _xpCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200));
    final state = context.read<FlashcardBloc>().state;
    if (state is FlashcardSessionComplete) {
      _xpAnim = Tween<double>(
              begin: 0, end: state.session.xpEarned.toDouble())
          .animate(CurvedAnimation(
              parent: _xpCtrl, curve: Curves.easeOut));
      _xpAnim.addListener(
          () => setState(() => _displayXp = _xpAnim.value.round()));
      Future.delayed(const Duration(milliseconds: 300),
          () => _xpCtrl.forward());
    } else {
      _xpAnim = const AlwaysStoppedAnimation(0);
    }
  }

  @override
  void dispose() {
    _xpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlashcardBloc, FlashcardState>(
      builder: (context, state) {
        if (state is! FlashcardSessionComplete) return const SizedBox();
        final r = state.session;
        final pct = r.accuracyPercent;
        final note = pct >= 80
            ? 'Excellent! Your memory of this deck is strong.'
            : pct >= 60
                ? 'Good progress. Review the hard cards again soon.'
                : 'Keep reviewing — spaced repetition will lock these in.';

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                const SizedBox(height: 20),
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF052E1E),
                    border: Border.all(
                        color: const Color(0xFF0EA472), width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.style_rounded,
                      size: 32, color: Color(0xFF0EA472)),
                ),
                const SizedBox(height: 14),
                Text('Deck complete!',
                    style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(
                    '${state.deck.name} · ${r.totalReviewed} cards reviewed',
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.textTertiary)),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D1E00),
                    border: Border.all(
                        color: const Color(0xFFC47D0E), width: 1.5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(children: [
                    Text('XP earned',
                        style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppColors.textTertiary)),
                    const SizedBox(height: 6),
                    Text('+$_displayXp',
                        style: GoogleFonts.dmSans(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE8960F))),
                    Text(
                        '${r.easyCount} cards × 5 XP · streak bonus +${r.bestStreak * 3}',
                        style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: AppColors.textTertiary)),
                  ]),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.5,
                  children: [
                    _StatTile(label: 'Easy / Good', value: '${r.easyCount}', color: const Color(0xFF0EA472)),
                    _StatTile(label: 'Again / Hard', value: '${r.againCount}', color: const Color(0xFFEA580C)),
                    _StatTile(label: 'Best streak', value: '${r.bestStreak}', color: AppColors.accentLight),
                    _StatTile(label: 'Next review', value: 'Tomorrow', color: const Color(0xFFE8960F)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                      Text('Retention rate',
                          style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary)),
                      Text('$pct%',
                          style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0EA472))),
                    ]),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        minHeight: 5,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF0EA472)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(note,
                        style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: AppColors.textTertiary)),
                  ]),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1240),
                    border:
                        Border.all(color: const Color(0xFF2D1B6B)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Container(
                      width: 6, height: 6,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                        Text('Gemini insight',
                            style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.accentLight)),
                        const SizedBox(height: 3),
                        Text(
                            'You struggled most with graph traversal cards. Try reviewing those with a diagram — visual learners retain network structures 40% better.',
                            style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                height: 1.6)),
                      ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.read<FlashcardBloc>().add(
                      FlashcardDeckSelected(state.deck)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      const Icon(Icons.refresh_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text('Review hard cards',
                          style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ]),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => context
                      .read<FlashcardBloc>()
                      .add(FlashcardSessionReset()),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(
                          color: AppColors.border, width: 0.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text('Back to decks',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatTile(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value,
            style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: color)),
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 9, color: AppColors.textTertiary)),
      ]),
    );
  }
}