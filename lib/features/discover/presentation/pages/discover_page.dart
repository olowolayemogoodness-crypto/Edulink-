import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

enum _DiscoverTab { feed, sendDuel, duelPending, duelActive, duelResult }
class _Scholarship {
  final String emoji, title, sub, deadline;
  final Color tagColor, tagBg, borderColor, bgColor;
  final String tag;
  const _Scholarship({required this.emoji, required this.title, required this.sub, required this.deadline, required this.tag, required this.tagColor, required this.tagBg, required this.borderColor, required this.bgColor});
}

class _Opponent {
  final String initials, name, rank, streak;
  final Color bg, tc;
  const _Opponent({required this.initials, required this.name, required this.rank, required this.streak, required this.bg, required this.tc});
}

class _DuelQuestion {
  final String q;
  final List<String> opts;
  final int ans;
  const _DuelQuestion({required this.q, required this.opts, required this.ans});
}

const _scholarships = [
  _Scholarship(emoji: '🇬🇧', title: 'Chevening Scholarship 2026', sub: 'UK government · fully funded Masters', deadline: 'Nov 5', tag: 'Closing', tagColor: AppColors.error, tagBg: AppColors.errorSurface, borderColor: AppColors.border, bgColor: AppColors.surface),
  _Scholarship(emoji: '🌍', title: 'MasterCard Foundation Scholars', sub: 'African students · global universities', deadline: 'Dec 1', tag: 'Open', tagColor: AppColors.success, tagBg: AppColors.successSurface, borderColor: AppColors.border, bgColor: AppColors.surface),
  _Scholarship(emoji: '🇺🇸', title: 'AAUW International Fellowship', sub: 'Women · graduate study in the US', deadline: 'Nov 15', tag: 'Open', tagColor: AppColors.success, tagBg: AppColors.successSurface, borderColor: AppColors.border, bgColor: AppColors.surface),
];

const _opponents = [
  _Opponent(initials: 'TF', name: 'Tunde F.', rank: 'Rank #39', streak: '14-day streak', bg: AppColors.successSurface, tc: AppColors.success),
  _Opponent(initials: 'KO', name: 'Kemi O.', rank: 'Rank #42', streak: '9-day streak', bg: Color(0xFF2D1E00), tc: Color(0xFFE8960F)),
  _Opponent(initials: 'ZN', name: 'Zara N.', rank: 'Rank #2', streak: '18-day streak', bg: Color(0xFF0C1A3D), tc: Color(0xFF60A5FA)),
];

const _duelQuestions = [
  _DuelQuestion(q: 'The equation of a circle with centre (3, −2) and radius 5 is:', opts: ['(x+3)²+(y−2)²=5', '(x−3)²+(y+2)²=25', '(x+3)²+(y+2)²=25', '(x−3)²+(y−2)²=5'], ans: 1),
  _DuelQuestion(q: 'Solve for x: 2x² − 5x + 3 = 0', opts: ['x = 1 or x = 1.5', 'x = 3 or x = −1', 'x = 2 or x = 0.5', 'x = −3 or x = 1'], ans: 0),
  _DuelQuestion(q: 'What is the gradient of the line 3y = 6x − 9?', opts: ['2', '3', '−3', '6'], ans: 0),
  _DuelQuestion(q: 'The value of sin 60° is:', opts: ['√2/2', '1/2', '√3/2', '√3'], ans: 2),
  _DuelQuestion(q: 'Simplify log₃27 + log₃9:', opts: ['3', '4', '5', '6'], ans: 2),
];

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});
  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> with TickerProviderStateMixin {
  _DiscoverTab _tab = _DiscoverTab.feed;
  String _feedFilter = 'all';
  String _duelSubject = 'math';
  int _duelQCount = 10;
  int _selectedOpp = 0;
  int _duelQIdx = 0;
  int? _duelAnswer;
  bool _duelAnswered = false;
  int _yourScore = 3;
  int _oppScore = 2;
  int _duelSecs = 30;
  Timer? _duelTimer;

  @override
  void dispose() {
    _duelTimer?.cancel();
    super.dispose();
  }

  void _go(_DiscoverTab tab) {
    HapticFeedback.selectionClick();
    _duelTimer?.cancel();
    if (tab == _DiscoverTab.duelActive) {
      _duelQIdx = 0;
      _duelAnswer = null;
      _duelAnswered = false;
      _yourScore = 3;
      _oppScore = 2;
      _startDuelTimer();
    }
    setState(() => _tab = tab);
  }

  void _startDuelTimer() {
    _duelTimer?.cancel();
    setState(() => _duelSecs = 30);
    _duelTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_duelSecs > 0) {
          _duelSecs--;
        } else {
          _duelTimer?.cancel();
          if (!_duelAnswered) _answerDuel(false);
        }
      });
    });
  }

  void _answerDuel(bool correct) {
  if (_duelAnswered) {
    return;
  }
  HapticFeedback.lightImpact();
  _duelTimer?.cancel();
  setState(() {
    _duelAnswered = true;
    if (correct) {
      _yourScore++;
    } else {
      _oppScore++;
    }
  });
}

  void _nextDuelQ() {
  HapticFeedback.selectionClick();
  if (_duelQIdx >= _duelQuestions.length - 1) { 
    _go(_DiscoverTab.duelResult); 
    return; 
  }
  setState(() {
    _duelQIdx++;
    _duelAnswer = null;
    _duelAnswered = false;
  });
  _startDuelTimer();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    switch (_tab) {
      case _DiscoverTab.feed:        return _feed();
      case _DiscoverTab.sendDuel:    return _sendDuel();
      case _DiscoverTab.duelPending: return _duelPending();
      case _DiscoverTab.duelActive:  return _duelActive();
      case _DiscoverTab.duelResult:  return _duelResult();
    }
  }

  // ══════════════════════════════════════════
  // DISCOVER FEED
  // ══════════════════════════════════════════
  Widget _feed() => Column(children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Discover', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text('Scholarships · duels · career', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
        ])),
        _iBtn(Icons.search_rounded, () {}),
        const SizedBox(width: 7),
        Stack(children: [
          _iBtn(Icons.notifications_none_rounded, () {}),
          Positioned(top: 5, right: 5, child: Container(width: 7, height: 7, decoration: BoxDecoration(color: AppColors.error, shape: BoxShape.circle, border: Border.all(color: AppColors.surface, width: 1.5)))),
        ]),
      ]),
    ),

    // Stories strip
    SizedBox(
      height: 82,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
        children: [
          _story(Icons.emoji_events_rounded, 'Scholarship', const Color(0xFFC47D0E), 1.0),
          _story(Icons.sports_kabaddi_rounded, 'Duel arena', AppColors.error, 0.8, onTap: () => _go(_DiscoverTab.sendDuel)),
          _story(Icons.language_rounded, 'IELTS event', AppColors.success, 0.65),
          _story(Icons.school_rounded, 'Chevening', AppColors.accent, 0.9),
          _story(Icons.work_outline_rounded, 'Google fair', const Color(0xFF60A5FA), 0.45),
        ],
      ),
    ),

    // Filter tabs
    Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(children: ['all', 'schol', 'duel', 'career'].map((k) {
        final labels = {'all': 'All', 'schol': 'Scholarships', 'duel': 'Duels', 'career': 'Career'};
        final on = _feedFilter == k;
        return Expanded(child: GestureDetector(
          onTap: () { HapticFeedback.selectionClick(); setState(() => _feedFilter = k); },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(color: on ? AppColors.accentSurface : Colors.transparent, border: on ? Border.all(color: const Color(0xFF3D2580), width: 0.5) : null, borderRadius: BorderRadius.circular(9)),
            child: Center(child: Text(labels[k]!, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: on ? AppColors.accentLight : AppColors.textTertiary))),
          ),
        ));
      }).toList()),
    ),

    Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(14, 0, 14, 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // Featured scholarship
      // Featured scholarship
      GestureDetector(
        onTap: () => context.push('/scholarship'),
        child: Container(
        padding: const EdgeInsets.all(13),
        margin: const EdgeInsets.only(bottom: 9),
        decoration: BoxDecoration(color: const Color(0xFF2D1E00), border: Border.all(color: const Color(0xFFC47D0E), width: 1.5), borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFF3D2900), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.emoji_events_rounded, size: 22, color: Color(0xFFE8960F))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('EduLink Scholarship S3', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                const SizedBox(width: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: AppColors.errorSurface, border: Border.all(color: AppColors.error.withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)), const SizedBox(width: 3), Text('4 days left', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.error))])),
              ]),
              const SizedBox(height: 2),
              Text("You're already qualified at #38 — register to compete", style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
            ])),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _pill('₦1,000,000 prize', const Color(0xFF3D2900), const Color(0xFFE8960F)),
            const SizedBox(width: 5),
            _pill('You qualify', AppColors.successSurface, AppColors.success),
            const Spacer(),
            Text('Register →', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFFE8960F))),
          ]),
        ]),
      ),
      ),

      // Duel arena section header
      Padding(
        padding: const EdgeInsets.only(bottom: 9, top: 4),
        child: Row(children: [
          const Icon(Icons.sports_kabaddi_rounded, size: 18, color: AppColors.error),
          const SizedBox(width: 7),
          Text('DUEL ARENA', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
          const Spacer(),
          GestureDetector(onTap: () => _go(_DiscoverTab.sendDuel), child: Text('Challenge someone →', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w500))),
        ]),
      ),

      // Incoming challenge
      GestureDetector(
        onTap: () => _go(_DiscoverTab.duelPending),
        child: Container(
          padding: const EdgeInsets.all(13),
          margin: const EdgeInsets.only(bottom: 9),
          decoration: BoxDecoration(color: AppColors.errorSurface, border: Border.all(color: AppColors.error, width: 1.5), borderRadius: BorderRadius.circular(18)),
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFF3D1200), shape: BoxShape.circle, border: Border.all(color: AppColors.error, width: 2)), child: const Icon(Icons.sports_kabaddi_rounded, size: 20, color: AppColors.error)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('Challenge incoming!', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.error)),
                  const SizedBox(width: 7),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF3D1200), border: Border.all(color: AppColors.error.withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(20)), child: Text('Waiting', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.error))),
                ]),
                const SizedBox(height: 3),
                RichText(text: TextSpan(style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textSecondary, height: 1.6), children: [
                  const TextSpan(text: 'Tunde F. challenged you to a '),
                  TextSpan(text: 'WAEC Maths duel', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                  const TextSpan(text: ' — 10 questions, 5 min. Accept before it expires!'),
                ])),
              ])),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Container(width: 24, height: 24, decoration: BoxDecoration(color: AppColors.successSurface, shape: BoxShape.circle), child: Center(child: Text('TF', style: GoogleFonts.dmSans(fontSize: 8, color: AppColors.success)))),
              const SizedBox(width: 6),
              Text('Tunde F. · Rank #39', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
              Text(' · expires in 23h', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textDisabled)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: GestureDetector(onTap: () => _go(_DiscoverTab.duelActive), child: Container(padding: const EdgeInsets.symmetric(vertical: 9), decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(10)), child: Center(child: Text('Accept duel', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)))))),
              const SizedBox(width: 8),
              Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 9), decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)), child: Center(child: Text('Decline', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary))))),
            ]),
          ]),
        ),
      ),

      // Challenge a friend
      GestureDetector(
        onTap: () => _go(_DiscoverTab.sendDuel),
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 9),
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.surfaceVariant, shape: BoxShape.circle, border: Border.all(color: AppColors.border, width: 1.5)), child: const Icon(Icons.sports_kabaddi_rounded, size: 20, color: AppColors.textTertiary)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Challenge a friend', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              Text('Pick a subject, set question count, send a duel invite', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
            ])),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textDisabled),
          ]),
        ),
      ),

      // Past duel result
      Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 9),
        decoration: BoxDecoration(color: AppColors.successSurface, border: Border.all(color: AppColors.success), borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFF073D27), shape: BoxShape.circle, border: Border.all(color: AppColors.success, width: 1.5)), child: const Icon(Icons.sports_kabaddi_rounded, size: 20, color: AppColors.success)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('You won! vs Kemi O.', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.success)),
              const SizedBox(width: 6),
              _pill('Victory', const Color(0xFF073D27), AppColors.success),
            ]),
            Text('WAEC Maths · 8/10 vs 6/10 · +60 XP earned', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
          ])),
          Text('2h ago', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textDisabled)),
        ]),
      ),

      // Scholarships section
      Padding(
        padding: const EdgeInsets.only(bottom: 9, top: 4),
        child: Text('EXTERNAL SCHOLARSHIPS', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
      ),
      ..._scholarships.map((s) => Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: s.bgColor, border: Border.all(color: s.borderColor), borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(11)), child: Center(child: Text(s.emoji, style: const TextStyle(fontSize: 18)))),
            const SizedBox(width: 9),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.title, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              Text(s.sub, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: s.tagBg, border: Border.all(color: s.tagColor.withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(20)), child: Text(s.tag, style: GoogleFonts.dmSans(fontSize: 9, color: s.tagColor))),
          ]),
          const SizedBox(height: 7),
          Row(children: [
            _pill('Fully funded', AppColors.successSurface, AppColors.success),
            const SizedBox(width: 5),
            _pill('All courses', AppColors.surfaceVariant, AppColors.textTertiary),
            const Spacer(),
            Text(s.deadline, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textDisabled)),
          ]),
        ]),
      )),

      // Career event
      Padding(
        padding: const EdgeInsets.only(bottom: 9, top: 4),
        child: Text('CAREER EVENTS', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
      ),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF0C1A3D), border: Border.all(color: const Color(0xFF185FA5)), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: const Color(0xFF0C1E32), borderRadius: BorderRadius.circular(11)), child: const Center(child: Text('🎓', style: TextStyle(fontSize: 18)))),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Google Student Dev Fair', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            Text('Lagos · Dec 14 · free tickets', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF0C1A3D), border: Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(20)), child: Text('Free', style: GoogleFonts.dmSans(fontSize: 9, color: const Color(0xFF60A5FA)))),
        ]),
      ),
    ]))),
  ]);

  Widget _story(IconData icon, String label, Color color, double progress, {VoidCallback? onTap}) => GestureDetector(
    onTap: onTap ?? () {},
    child: Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(children: [
        SizedBox(width: 58, height: 58, child: CustomPaint(
          painter: _StoryRingPainter(color, progress),
          child: Center(child: Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle), child: Icon(icon, size: 22, color: color))),
        )),
        const SizedBox(height: 4),
        SizedBox(width: 58, child: Text(label, style: GoogleFonts.dmSans(fontSize: 8, color: AppColors.textSecondary), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis)),
      ]),
    ),
  );

  Widget _pill(String label, Color bg, Color tc) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: GoogleFonts.dmSans(fontSize: 9, color: tc, fontWeight: FontWeight.w500)),
  );

  // ══════════════════════════════════════════
  // SEND DUEL
  // ══════════════════════════════════════════
  Widget _sendDuel() => Column(children: [
    Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        GestureDetector(onTap: () => _go(_DiscoverTab.feed), child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
        const SizedBox(width: 10),
        const Icon(Icons.sports_kabaddi_rounded, size: 18, color: AppColors.error),
        const SizedBox(width: 8),
        Text('Send a challenge', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ]),
    ),
    Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // Subject
      Text('CHOOSE SUBJECT', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
      const SizedBox(height: 8),
      Row(children: [
        _duelSubjectChip('math', '📐', 'WAEC Maths'),
        const SizedBox(width: 6),
        _duelSubjectChip('eng', '📝', 'English'),
        const SizedBox(width: 6),
        _duelSubjectChip('sci', '🔬', 'Science'),
        const SizedBox(width: 6),
        _duelSubjectChip('ielts', '🌍', 'IELTS'),
      ]),
      const SizedBox(height: 16),

      // Question count
      Text('QUESTION COUNT', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
      const SizedBox(height: 8),
      Row(children: [5, 10, 20].map((n) {
        final on = _duelQCount == n;
        return Expanded(child: GestureDetector(
          onTap: () { HapticFeedback.selectionClick(); setState(() => _duelQCount = n); },
          child: Container(
            margin: EdgeInsets.only(right: n == 20 ? 0 : 8),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: on ? AppColors.errorSurface : AppColors.surface, border: Border.all(color: on ? AppColors.error : AppColors.border, width: on ? 1.5 : 1), borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              Text('$n', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w500, color: on ? AppColors.error : AppColors.textTertiary)),
              Text(n == 5 ? 'Quick' : n == 10 ? 'Standard' : 'Extended', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textDisabled)),
            ]),
          ),
        ));
      }).toList()),
      const SizedBox(height: 16),

      // Opponents
      Text('CHALLENGE WHO?', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
      const SizedBox(height: 8),
      ..._opponents.asMap().entries.map((e) {
        final i = e.key;
        final o = e.value;
        final on = _selectedOpp == i;
        return GestureDetector(
          onTap: () { HapticFeedback.selectionClick(); setState(() => _selectedOpp = i); },
          child: Container(
            margin: const EdgeInsets.only(bottom: 7),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: on ? AppColors.error : AppColors.border, width: on ? 1.5 : 1), borderRadius: BorderRadius.circular(13)),
            child: Row(children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: o.bg, shape: BoxShape.circle), child: Center(child: Text(o.initials, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: o.tc)))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o.name, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text('${o.rank} · ${o.streak}', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
              ])),
              Container(width: 18, height: 18, decoration: BoxDecoration(color: on ? AppColors.error : AppColors.surfaceVariant, shape: BoxShape.circle), child: on ? const Icon(Icons.check_rounded, size: 11, color: Colors.white) : null),
            ]),
          ),
        );
      }),
      const SizedBox(height: 16),

      // Send CTA
      GestureDetector(
        onTap: () => _go(_DiscoverTab.duelPending),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(14)),
          child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.sports_kabaddi_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Send challenge to ${_opponents[_selectedOpp].name.split(' ')[0]}', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          ])),
        ),
      ),
    ]))),
  ]);

  Widget _duelSubjectChip(String key, String emoji, String label) {
    final on = _duelSubject == key;
    return Expanded(child: GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); setState(() => _duelSubject = key); },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: on ? AppColors.errorSurface : AppColors.surface, border: Border.all(color: on ? AppColors.error : AppColors.border, width: on ? 1.5 : 1), borderRadius: BorderRadius.circular(11)),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.dmSans(fontSize: 9, color: on ? AppColors.error : AppColors.textTertiary)),
        ]),
      ),
    ));
  }

  // ══════════════════════════════════════════
  // DUEL PENDING
  // ══════════════════════════════════════════
  Widget _duelPending() => Column(children: [
    Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        GestureDetector(onTap: () => _go(_DiscoverTab.feed), child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
        const SizedBox(width: 10),
        const Icon(Icons.sports_kabaddi_rounded, size: 18, color: AppColors.error),
        const SizedBox(width: 8),
        Text('Duel pending', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ]),
    ),
    Expanded(child: SingleChildScrollView(child: Column(children: [

      // VS card
      Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _vsAvatar('AO', AppColors.accentSurface, AppColors.accentLight, AppColors.accent, 'You', 'Rank #38'),
            const SizedBox(width: 16),
            Column(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.errorSurface, shape: BoxShape.circle, border: Border.all(color: AppColors.error, width: 2)), child: const Icon(Icons.sports_kabaddi_rounded, size: 22, color: AppColors.error)),
              const SizedBox(height: 4),
              Text('VS', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.error)),
            ]),
            const SizedBox(width: 16),
            _vsAvatar('TF', AppColors.successSurface, AppColors.success, AppColors.success, 'Tunde F.', 'Rank #39'),
          ]),
          const SizedBox(height: 16),

          // Duel details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Expanded(child: Column(children: [Text('10', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)), Text('Questions', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary))])),
              Container(width: 1, height: 32, color: AppColors.border),
              Expanded(child: Column(children: [Text('WAEC', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)), Text('Maths', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary))])),
              Container(width: 1, height: 32, color: AppColors.border),
              Expanded(child: Column(children: [Text('+100', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.accentLight)), Text('XP to win', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary))])),
            ]),
          ),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFE8960F), shape: BoxShape.circle)),
            const SizedBox(width: 7),
            Text('Waiting for Tunde to accept · expires in 23h', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textTertiary)),
          ]),
        ]),
      ),

      // Prep while you wait
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PREP WHILE YOU WAIT', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          _prepCard(Icons.psychology_rounded, AppColors.accentSurface, AppColors.accentLight, 'Quick WAEC Maths drill', '5 questions · sharpen up before the duel'),
          const SizedBox(height: 8),
          _prepCard(Icons.bar_chart_rounded, AppColors.surfaceVariant, AppColors.textTertiary, "View Tunde's stats", 'See their weak topics before you duel'),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _go(_DiscoverTab.duelActive),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(14)),
              child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.sports_kabaddi_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text('Tunde accepted — start now!', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              ])),
            ),
          ),
        ]),
      ),
    ]))),
  ]);

  Widget _vsAvatar(String initials, Color bg, Color tc, Color border, String name, String rank) => Column(children: [
    Container(width: 56, height: 56, decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: Border.all(color: border, width: 2)), child: Center(child: Text(initials, style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500, color: tc)))),
    const SizedBox(height: 5),
    Text(name, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
    Text(rank, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
  ]);

  Widget _prepCard(IconData icon, Color iconBg, Color iconColor, String title, String sub) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: iconColor)),
      const SizedBox(width: 9),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        Text(sub, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
      ])),
      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textDisabled),
    ]),
  );

  // ══════════════════════════════════════════
  // DUEL ACTIVE
  // ══════════════════════════════════════════
  Widget _duelActive() {
    final q = _duelQuestions[_duelQIdx];
    final warn = _duelSecs <= 10;
    return Column(children: [
      // Score header
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        color: AppColors.errorSurface,
        child: Row(children: [
          Container(width: 28, height: 28, decoration: const BoxDecoration(color: AppColors.accentSurface, shape: BoxShape.circle), child: Center(child: Text('AO', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.accentLight)))),
          Expanded(child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('You  $_yourScore', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.error)),
            const SizedBox(width: 7),
            Container(width: 30, height: 30, decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle, border: Border.all(color: AppColors.error, width: 1.5)), child: const Icon(Icons.sports_kabaddi_rounded, size: 14, color: AppColors.error)),
            const SizedBox(width: 7),
            Text('Tunde  $_oppScore', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          ]))),
          Container(width: 28, height: 28, decoration: const BoxDecoration(color: AppColors.successSurface, shape: BoxShape.circle), child: Center(child: Text('TF', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.success)))),
        ]),
      ),

      // Progress + timer
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(children: [
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: (_duelQIdx + 1) / _duelQuestions.length, minHeight: 5, backgroundColor: AppColors.surfaceVariant, valueColor: const AlwaysStoppedAnimation(AppColors.error)))),
          const SizedBox(width: 10),
          Text('Q ${_duelQIdx + 1}/${_duelQuestions.length}', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(color: AppColors.errorSurface, border: Border.all(color: warn ? AppColors.error : AppColors.error.withValues(alpha: 0.4)), borderRadius: BorderRadius.circular(20)),
            child: Text('0:${_duelSecs.toString().padLeft(2, '0')}', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.error)),
          ),
        ]),
      ),

      // Question
      Expanded(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.sports_kabaddi_rounded, size: 14, color: AppColors.error),
              const SizedBox(width: 6),
              Text('Duel · WAEC Mathematics', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.error)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: AppColors.accentSurface, borderRadius: BorderRadius.circular(20)), child: Text('Medium', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.accentLight))),
            ]),
            const SizedBox(height: 8),
            Text(q.q, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.65)),
          ]),
        ),
        Container(margin: const EdgeInsets.only(top: 12), height: 1, color: AppColors.border),

        // Options
        ...List.generate(q.opts.length, (i) {
          final selected = _duelAnswer == i;
          final isCorrect = i == q.ans;
          Color bg = AppColors.surface;
          Color tc = AppColors.textSecondary;
          if (_duelAnswered) {
            if (isCorrect) { 
              bg = AppColors.successSurface; 
              tc = const Color(0xFF6EE7B7); }
            else if (selected) { bg = AppColors.errorSurface; tc = const Color(0xFFFCA5A5); }
            else { bg = AppColors.surface; tc = AppColors.textDisabled; }
          } else if (selected) {
            bg = AppColors.errorSurface; tc = const Color(0xFFFCA5A5);
          }
          return GestureDetector(
            onTap: _duelAnswered ? null : () {
              HapticFeedback.selectionClick();
              setState(() { _duelAnswer = i; });
              _answerDuel(i == q.ans);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: bg, border: Border(bottom: BorderSide(color: AppColors.border))),
              child: Row(children: [
                Container(width: 22, height: 22, decoration: BoxDecoration(color: _duelAnswered && isCorrect ? AppColors.success : _duelAnswered && selected ? AppColors.error : AppColors.surfaceVariant, borderRadius: BorderRadius.circular(7)), child: Center(child: Text(String.fromCharCode(65 + i), style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500, color: _duelAnswered && (isCorrect || selected) ? Colors.white : AppColors.textTertiary)))),
                const SizedBox(width: 10),
                Expanded(child: Text(q.opts[i], style: GoogleFonts.dmSans(fontSize: 13, color: tc))),
              ]),
            ),
          );
        }),

        // Next button
        if (_duelAnswered)
          Padding(
            padding: const EdgeInsets.all(14),
            child: GestureDetector(
              onTap: _nextDuelQ,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(_duelQIdx >= _duelQuestions.length - 1 ? 'Finish duel →' : 'Next →', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
              ),
            ),
          ),
      ]))),
    ]);
  }
  // ══════════════════════════════════════════
  // DUEL RESULT
  // ══════════════════════════════════════════
  Widget _duelResult() {
    final won = _yourScore > _oppScore;
    final heroColor = won ? AppColors.success : AppColors.error;
    final heroBg = won ? AppColors.successSurface : AppColors.errorSurface;
    final heroBorder = won ? AppColors.success : AppColors.error;
    final xp = won ? 100 : 40;
    final rankChange = won ? '+1' : '−1';
    final rankNote = won ? '#38 → #37' : '#38 → #39';

    return SingleChildScrollView(child: Column(children: [
      // Hero band
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
        decoration: BoxDecoration(color: heroBg, border: Border(bottom: BorderSide(color: heroBorder, width: 1.5))),
        child: Column(children: [
          Container(
            width: 76, height: 76,
            decoration: BoxDecoration(color: heroBg, shape: BoxShape.circle, border: Border.all(color: heroBorder, width: 2.5)),
            child: Icon(won ? Icons.emoji_events_rounded : Icons.sports_kabaddi_rounded, size: 36, color: heroColor),
          ),
          const SizedBox(height: 12),
          Text(won ? 'Victory!' : 'Defeated', style: GoogleFonts.dmSans(fontSize: 26, fontWeight: FontWeight.w500, color: heroColor)),
          const SizedBox(height: 4),
          Text(won ? 'You defeated Tunde F. · WAEC Maths' : 'Tunde F. beat you · WAEC Maths',
              style: GoogleFonts.dmSans(fontSize: 11, color: won ? const Color(0xFF6EE7B7) : const Color(0xFFFCA5A5))),
        ]),
      ),

      Padding(padding: const EdgeInsets.all(14), child: Column(children: [
        // Score VS card
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 11),
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            Expanded(child: Column(children: [
              Container(width: 46, height: 46, decoration: BoxDecoration(color: heroBg, shape: BoxShape.circle, border: Border.all(color: heroBorder, width: 2)), child: Center(child: Text('AO', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: heroColor)))),
              const SizedBox(height: 5),
              Text('You', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              Text('$_yourScore', style: GoogleFonts.dmSans(fontSize: 32, fontWeight: FontWeight.w500, color: heroColor, height: 1.1)),
              Text('correct', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
            ])),
            Column(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: heroBg, shape: BoxShape.circle, border: Border.all(color: heroBorder, width: 1.5)), child: Icon(Icons.sports_kabaddi_rounded, size: 19, color: heroColor)),
              const SizedBox(height: 4),
              Text('VS', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500, color: heroColor)),
              Text('10 Qs', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textDisabled)),
            ]),
            Expanded(child: Column(children: [
              Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.successSurface, shape: BoxShape.circle, border: Border.all(color: AppColors.border, width: 2)), child: Center(child: Text('TF', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.success)))),
              const SizedBox(height: 5),
              Text('Tunde F.', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              Text('$_oppScore', style: GoogleFonts.dmSans(fontSize: 32, fontWeight: FontWeight.w500, color: AppColors.textDisabled, height: 1.1)),
              Text('correct', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
            ])),
          ]),
        ),

        // XP + Rank grid
        Row(children: [
          Expanded(child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(color: const Color(0xFF2D1E00), border: Border.all(color: const Color(0xFFC47D0E)), borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              Text('XP earned', style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFFE8960F))),
              const SizedBox(height: 3),
              Text('+$xp', style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w500, color: const Color(0xFFE8960F))),
              Text(won ? 'Victory bonus' : 'Participation', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
            ]),
          )),
          const SizedBox(width: 8),
          Expanded(child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(color: AppColors.accentSurface, border: Border.all(color: const Color(0xFF3D2580)), borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              Text('Rank change', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.accentLight)),
              const SizedBox(height: 3),
              Text(rankChange, style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.accentLight)),
              Text(rankNote, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
            ]),
          )),
        ]),
        const SizedBox(height: 11),

        // Question breakdown dots
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 11),
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('QUESTION BREAKDOWN', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Wrap(spacing: 5, runSpacing: 5, children: List.generate(_duelQuestions.length, (i) {
              final correct = i < _yourScore;
              return Container(width: 22, height: 22, decoration: BoxDecoration(color: correct ? AppColors.successSurface : AppColors.errorSurface, border: Border.all(color: correct ? AppColors.success : AppColors.error), borderRadius: BorderRadius.circular(6)), child: Center(child: Text('${i + 1}', style: GoogleFonts.dmSans(fontSize: 8, color: correct ? AppColors.success : AppColors.error))));
            })),
            const SizedBox(height: 8),
            Row(children: [
              Container(width: 9, height: 9, decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 4),
              Text('Correct', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
              const SizedBox(width: 12),
              Container(width: 9, height: 9, decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 4),
              Text('Wrong', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
            ]),
          ]),
        ),

        // Gemini insight
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 11),
          decoration: BoxDecoration(color: AppColors.accentSurface, border: Border.all(color: const Color(0xFF3D2580)), borderRadius: BorderRadius.circular(16)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 5), decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Gemini insight', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accentLight)),
              const SizedBox(height: 3),
              Text(won
                ? 'Solid win. You dominated algebra and arithmetic but dropped 2 marks on circle geometry — one focused session there before your next duel would be decisive.'
                : 'Close match. You lost ground on circle geometry and logarithms — topics Tunde clearly prepared. A focused 20-minute review on those two areas before your rematch would close the gap.',
                style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textSecondary, height: 1.65)),
            ])),
          ]),
        ),

        // CTAs
        GestureDetector(
          onTap: () => _go(_DiscoverTab.sendDuel),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: AppColors.errorSurface, border: Border.all(color: AppColors.error, width: 1.5), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.sports_kabaddi_rounded, size: 15, color: AppColors.error),
              const SizedBox(width: 8),
              Text('Rematch Tunde', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.error)),
            ])),
          ),
        ),
        GestureDetector(
          onTap: () => _go(_DiscoverTab.sendDuel),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text('Challenge someone else', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
          ),
        ),
        GestureDetector(
          onTap: () => _go(_DiscoverTab.feed),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text('Back to Discover', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary))),
          ),
        ),
        const SizedBox(height: 16),
      ])),
    ]));
  }
  Widget _iBtn(IconData icon, VoidCallback fn) => GestureDetector(
    onTap: fn,
    child: Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 15, color: AppColors.textTertiary)),
  );
}

// ── Story ring painter ──
class _StoryRingPainter extends CustomPainter {
  final Color color;
  final double progress;
  _StoryRingPainter(this.color, this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2 - 2;
    final bg = Paint()..color = const Color(0xFF1A1A21)..style = PaintingStyle.stroke..strokeWidth = 2.5;
    final fg = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), r, bg);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), -1.5708, progress * 6.2832, false, fg);
  }
  @override bool shouldRepaint(_StoryRingPainter old) => old.progress != progress || old.color != color;
}