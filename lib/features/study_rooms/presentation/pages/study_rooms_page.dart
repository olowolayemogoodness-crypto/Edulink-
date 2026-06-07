import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/user_service.dart';

enum _StudyTab { hub, focusSetup, focusActive, focusDone, rooms, inRoom, createRoom }
class _Subject {
  final String id, emoji, name, sub;
  final Color iconBg;
  const _Subject({required this.id, required this.emoji, required this.name, required this.sub, required this.iconBg});
}

class _Room {
  final String emoji, title, sub, iconBg;
  final Color borderColor, bgColor, tagColor, tagBg;
  final int members;
  final bool joined;
  const _Room({required this.emoji, required this.title, required this.sub, required this.iconBg, required this.borderColor, required this.bgColor, required this.tagColor, required this.tagBg, required this.members, this.joined = false});
}

class _ChatMsg {
  final String avatar, name, text;
  final bool isMe, isAI;
  const _ChatMsg({required this.avatar, required this.name, required this.text, this.isMe = false, this.isAI = false});
}

const _subjects = [
  _Subject(id: 'math', emoji: '📐', name: 'WAEC Mathematics', sub: 'Algebra · Trig · Geometry', iconBg: AppColors.accentSurface),
  _Subject(id: 'eng', emoji: '📝', name: 'WAEC English', sub: 'Comprehension · Essay', iconBg: AppColors.surface),
  _Subject(id: 'ielts', emoji: '🌍', name: 'IELTS Academic', sub: 'Reading · Writing · Speaking', iconBg: AppColors.successSurface),
];

const _rooms = [
  _Room(emoji: '📐', title: 'WAEC Mathematics revision', sub: 'Algebra · Trig · Geometry', iconBg: '#073D27', borderColor: AppColors.success, bgColor: AppColors.successSurface, tagColor: AppColors.success, tagBg: AppColors.successSurface, members: 14, joined: true),
  _Room(emoji: '🎙️', title: 'IELTS Speaking drills', sub: 'Part 1 & 2 · voice recording', iconBg: '#0C1A3D', borderColor: AppColors.border, bgColor: AppColors.surface, tagColor: AppColors.success, tagBg: AppColors.successSurface, members: 7),
  _Room(emoji: '🧮', title: 'JAMB Mathematics 2022', sub: 'UTME paper · past questions', iconBg: '#1E1240', borderColor: AppColors.border, bgColor: AppColors.surface, tagColor: AppColors.success, tagBg: AppColors.successSurface, members: 5),
  _Room(emoji: '⚗️', title: 'WAEC Chemistry', sub: 'Organic · Inorganic · Physical', iconBg: '#141418', borderColor: AppColors.border, bgColor: AppColors.surface, tagColor: AppColors.success, tagBg: AppColors.successSurface, members: 9),
];

const _chatMsgs = [
  _ChatMsg(avatar: 'TF', name: 'Tunde', text: 'Can someone explain Q7 on the trig sheet?'),
  _ChatMsg(avatar: 'AO', name: 'Adaeze', text: 'Sure! sin θ = 3/5 means opposite=3, hypotenuse=5, so adjacent=4. cos θ = 4/5.', isMe: true),
  _ChatMsg(avatar: 'AI', name: 'Gemini', text: 'Great explanation Adaeze! Here\'s a quick tip: always draw the right triangle first to visualise SOHCAHTOA.', isAI: true),
  _ChatMsg(avatar: 'KM', name: 'Kemi', text: 'This is so helpful, thanks!'),
];

class StudyRoomsPage extends StatefulWidget {
  const StudyRoomsPage({super.key});
  @override
  State<StudyRoomsPage> createState() => _StudyRoomsPageState();
}

class _StudyRoomsPageState extends State<StudyRoomsPage> with TickerProviderStateMixin {
  _StudyTab _tab = _StudyTab.hub;
  String _selectedSubject = 'math';
  int _focusMins = 25;
  bool _customTimer = false;
  bool _togBreath = true, _togBlock = true, _togSound = false;
  int _timerSecs = 25 * 60;
  int _elapsed = 0;
  Timer? _focusTimer;
  late AnimationController _breathCtrl;
  late Animation<double> _breathAnim;
  late AnimationController _ringCtrl;
  late Animation<double> _ringAnim;
  final TextEditingController _chatCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _breathCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _breathAnim = Tween(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut));
    _ringCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _ringAnim = Tween(begin: 1.0, end: 1.18).animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _breathCtrl.dispose();
    _ringCtrl.dispose();
    _chatCtrl.dispose();
    super.dispose();
  }

  void _go(_StudyTab tab) {
    HapticFeedback.selectionClick();
    if (tab == _StudyTab.focusActive) {
      _timerSecs = _focusMins * 60;
      _elapsed = 0;
      _focusTimer?.cancel();
      _focusTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          if (_timerSecs > 0) { _timerSecs--; _elapsed++; }
          else { _focusTimer?.cancel(); _completeFocus(); }
        });
      });
    } else {
      _focusTimer?.cancel();
    }
    setState(() => _tab = tab);
  }

  void _completeFocus() {
    final hours = _focusMins / 60.0;
    final xp = (_focusMins ~/ 10) * 10;
    UserService.updateStreak();
    UserService.awardXP(xp, reason: 'focus_session');
    UserService.logStudyTime(hours);
    UserService.updateLeaderboard();
    setState(() => _tab = _StudyTab.focusDone);
  }

  String _fmt(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _ringProgress => _focusMins > 0 ? _timerSecs / (_focusMins * 60) : 0;
  int get _xpEarned => (_elapsed ~/ 60) * 6;
  _Subject get _subject => _subjects.firstWhere((s) => s.id == _selectedSubject);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    switch (_tab) {
      case _StudyTab.hub:         return _hub();
      case _StudyTab.focusSetup:  return _focusSetup();
      case _StudyTab.focusActive: return _focusActive();
      case _StudyTab.focusDone:   return _focusDone();
      case _StudyTab.rooms:       return _roomsBrowse();
      case _StudyTab.inRoom:      return _inRoom();
      case _StudyTab.createRoom:  return _createRoom();
    }
  }

  // ══════════════════════════════════════════
  // HUB
  // ══════════════════════════════════════════
  Widget _hub() => Column(children: [
    Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Study', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text('Choose how you want to study today', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
        ])),
      ]),
    ),
    Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(14), child: Column(children: [

      // Focus mode card
      GestureDetector(
        onTap: () => _go(_StudyTab.focusSetup),
        child: Container(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.accentSurface,
            border: Border.all(color: const Color(0xFF3D2580), width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFF3D2580), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.psychology_rounded, size: 26, color: AppColors.accentLight)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Focus mode', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('Study alone in deep focus. Set your subject and timer — no distractions, just you and the material.', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.accentLight, height: 1.6)),
                const SizedBox(height: 10),
                Wrap(spacing: 6, children: ['Breathing timer', 'Session streak', '+XP on complete'].map((t) =>
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFF3D2580), borderRadius: BorderRadius.circular(20)), child: Text(t, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.accentLight)))).toList()),
              ])),
            ]),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
              child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text('Start focus session', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              ])),
            ),
          ]),
        ),
      ),

      // Live study session card
      GestureDetector(
        onTap: () => _go(_StudyTab.rooms),
        child: Container(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.successSurface,
            border: Border.all(color: AppColors.success, width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Stack(children: [
                Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFF073D27), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.groups_rounded, size: 26, color: AppColors.success)),
                Positioned(top: 4, right: 4, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.error, shape: BoxShape.circle, border: Border.all(color: AppColors.successSurface, width: 1.5)))),
              ]),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('Live study session', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(width: 8),
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('3 live now', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.success)),
                ]),
                const SizedBox(height: 4),
                Text('Join a real-time study room. Chat with peers, solve Gemini quiz widgets together, challenge each other.', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.success, height: 1.6)),
                const SizedBox(height: 10),
                Wrap(spacing: 6, children: ['Live chat', 'Gemini quizzes', 'Peer challenges'].map((t) =>
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFF073D27), borderRadius: BorderRadius.circular(20)), child: Text(t, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.success)))).toList()),
              ])),
            ]),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(10)),
              child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.login_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text('Browse study rooms', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              ])),
            ),
          ]),
        ),
      ),

      // Last session nudge
      Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          const Icon(Icons.history_rounded, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Last session: 45 min · WAEC Maths', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            Text('Yesterday at 8:20 PM · +180 XP earned', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
          ])),
          const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.textDisabled),
        ]),
      ),
    ]))),
  ]);

  // ══════════════════════════════════════════
  // FOCUS SETUP
  // ══════════════════════════════════════════
  Widget _focusSetup() => Column(children: [
    Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        GestureDetector(onTap: () => _go(_StudyTab.hub), child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
        const SizedBox(width: 12),
        Text('Focus session setup', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ]),
    ),
    Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(14), child: Column(children: [

      // Subject picker
      Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('WHAT ARE YOU STUDYING?', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
          const SizedBox(height: 9),
          ..._subjects.map((s) {
            final on = _selectedSubject == s.id;
            return GestureDetector(
              onTap: () { HapticFeedback.selectionClick(); setState(() => _selectedSubject = s.id); },
              child: Container(
                margin: const EdgeInsets.only(bottom: 7),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: on ? AppColors.accentSurface : AppColors.surfaceVariant,
                  border: Border.all(color: on ? AppColors.accent : AppColors.border, width: on ? 1.5 : 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Container(width: 32, height: 32, decoration: BoxDecoration(color: on ? const Color(0xFF3D2580) : AppColors.surface, borderRadius: BorderRadius.circular(9)), child: Center(child: Text(s.emoji, style: const TextStyle(fontSize: 15)))),
                  const SizedBox(width: 9),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.name, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: on ? AppColors.accentLight : AppColors.textSecondary)),
                    Text(s.sub, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
                  ])),
                  Container(width: 18, height: 18, decoration: BoxDecoration(color: on ? AppColors.accent : AppColors.surfaceVariant, shape: BoxShape.circle), child: on ? const Icon(Icons.check_rounded, size: 11, color: Colors.white) : null),
                ]),
              ),
            );
          }),
        ]),
      ),

      // Duration picker
      Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SESSION LENGTH', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
          const SizedBox(height: 9),
          Row(children: [15, 25, 45, 60].map((m) {
            final on = !_customTimer && _focusMins == m;
            return Expanded(child: GestureDetector(
              onTap: () { HapticFeedback.selectionClick(); setState(() { _focusMins = m; _customTimer = false; }); },
              child: Container(
                margin: EdgeInsets.only(right: m == 60 ? 0 : 6),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: on ? AppColors.accentSurface : AppColors.surfaceVariant,
                  border: Border.all(color: on ? AppColors.accent : AppColors.border, width: on ? 1.5 : 0.5),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Column(children: [
                  Text('${m}m', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: on ? AppColors.accentLight : AppColors.textTertiary)),
                  Text(m == 15 ? 'Quick' : m == 25 ? 'Focus' : m == 45 ? 'Deep' : 'Full', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textDisabled)),
                ]),
              ),
            ));
          }).toList()),
          const SizedBox(height: 8),

          // Custom timer row
          GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); setState(() => _customTimer = true); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: BoxDecoration(
                color: _customTimer ? AppColors.accentSurface : AppColors.surfaceVariant,
                border: Border.all(color: _customTimer ? AppColors.accent : AppColors.border, width: _customTimer ? 1.5 : 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.tune_rounded, size: 16, color: AppColors.textTertiary),
                const SizedBox(width: 8),
                Expanded(child: Text('Custom', style: GoogleFonts.dmSans(fontSize: 12, color: _customTimer ? AppColors.accentLight : AppColors.textSecondary))),
                if (_customTimer) ...[
                  GestureDetector(
                    onTap: () { HapticFeedback.selectionClick(); if (_focusMins > 5) setState(() => _focusMins -= 5); },
                    child: Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(9)), child: const Icon(Icons.remove_rounded, size: 16, color: AppColors.textTertiary)),
                  ),
                  const SizedBox(width: 8),
                  Text('${_focusMins}m', style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () { HapticFeedback.selectionClick(); if (_focusMins < 120) setState(() => _focusMins += 5); },
                    child: Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(9)), child: const Icon(Icons.add_rounded, size: 16, color: AppColors.textTertiary)),
                  ),
                ],
              ]),
            ),
          ),
        ]),
      ),

      // Preferences
      Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PREFERENCES', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          _prefRow('Breathing animation', 'Pulsing logo guides focus', _togBreath, () => setState(() => _togBreath = !_togBreath), border: true),
          _prefRow('Block notifications', 'No interruptions during session', _togBlock, () => setState(() => _togBlock = !_togBlock), border: true),
          _prefRow('Ambient sounds', 'Lo-fi / rain / white noise', _togSound, () => setState(() => _togSound = !_togSound)),
        ]),
      ),

      // Begin button
      GestureDetector(
        onTap: () => _go(_StudyTab.focusActive),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(14)),
          child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.psychology_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Begin focus session', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          ])),
        ),
      ),
    ]))),
  ]);

  Widget _prefRow(String title, String sub, bool val, VoidCallback onTap, {bool border = false}) => GestureDetector(
    onTap: () { HapticFeedback.selectionClick(); onTap(); },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(border: Border(bottom: border ? const BorderSide(color: AppColors.border, width: 0.5) : BorderSide.none)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textPrimary)),
          Text(sub, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
        ])),
        Container(
          width: 40, height: 22,
          decoration: BoxDecoration(color: val ? AppColors.accent : AppColors.surfaceVariant, borderRadius: BorderRadius.circular(11)),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: val ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(margin: const EdgeInsets.all(2), width: 18, height: 18, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        ),
      ]),
    ),
  );

  // ══════════════════════════════════════════
  // FOCUS ACTIVE
  // ══════════════════════════════════════════
  Widget _focusActive() => Column(children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: Row(children: [
        GestureDetector(
          onTap: () => _go(_StudyTab.focusSetup),
          child: Container(width: 30, height: 30, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(9)), child: const Icon(Icons.close_rounded, size: 15, color: AppColors.textTertiary)),
        ),
        Expanded(child: Center(child: Text('${_subject.name} · ${_focusMins}m', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textTertiary)))),
        Container(width: 30, height: 30, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(9)), child: const Icon(Icons.more_horiz_rounded, size: 15, color: AppColors.textTertiary)),
      ]),
    ),
    Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      // Breathing ring + timer
      SizedBox(
        width: 200, height: 200,
        child: Stack(alignment: Alignment.center, children: [
          // Pulse ring
          AnimatedBuilder(animation: _ringAnim, builder: (_, __) => Transform.scale(
            scale: _ringAnim.value,
            child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.accent.withValues(alpha: 0.15), width: 1.5))),
          )),
          // SVG countdown ring
          CustomPaint(size: const Size(200, 200), painter: _RingPainter(_ringProgress)),
          // Breathing logo
          AnimatedBuilder(animation: _breathAnim, builder: (_, __) => Transform.scale(
            scale: _breathAnim.value,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accentSurface, border: Border.all(color: const Color(0xFF3D2580), width: 1.5)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('E', style: GoogleFonts.dmSans(fontSize: 28, fontWeight: FontWeight.w500, color: AppColors.accentLight)),
                Text('EDULINK', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.accentLight, letterSpacing: 2)),
              ]),
            ),
          )),
        ]),
      ),
      const SizedBox(height: 24),
      Text(_fmt(_timerSecs), style: GoogleFonts.dmSans(fontSize: 48, fontWeight: FontWeight.w500, color: AppColors.textPrimary, letterSpacing: -2)),
      const SizedBox(height: 6),
      Text('Breathe in…', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textTertiary)),
      const SizedBox(height: 4),
      Text('Stay focused · you\'re doing great', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textDisabled)),
      const SizedBox(height: 28),

      // Pause / End
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        GestureDetector(
          onTap: () { _focusTimer?.cancel(); },
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.pause_rounded, size: 15, color: AppColors.textSecondary), const SizedBox(width: 6), Text('Pause', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary))])),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _go(_StudyTab.focusDone),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.stop_rounded, size: 15, color: AppColors.error), const SizedBox(width: 6), Text('End session', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.error))])),
        ),
      ]),
      const SizedBox(height: 24),

      // Mini stats
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _statMini(_fmt(_elapsed), 'Elapsed', AppColors.accentLight),
          _divider(),
          _statMini('3', 'Streak', const Color(0xFFE8960F)),
          _divider(),
          _statMini('+$_xpEarned', 'XP so far', AppColors.success),
        ]),
      ),
    ])),
  ]);

  Widget _statMini(String val, String label, Color color) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Column(children: [
      Text(val, style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500, color: color)),
      Text(label, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
    ]),
  );

  Widget _divider() => Container(width: 1, height: 28, color: AppColors.border);

  // ══════════════════════════════════════════
  // FOCUS DONE
  // ══════════════════════════════════════════
  Widget _focusDone() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      const SizedBox(height: 20),
      Container(width: 72, height: 72, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accentSurface, border: Border.all(color: AppColors.accent, width: 2)), child: const Icon(Icons.psychology_rounded, size: 32, color: AppColors.accentLight)),
      const SizedBox(height: 14),
      Text('Session complete!', style: GoogleFonts.dmSans(fontSize: 21, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 3),
      Text('${_subject.name} · ${_focusMins} minutes', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
      const SizedBox(height: 18),

      // XP card
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF2D1E00), border: Border.all(color: const Color(0xFFC47D0E), width: 1.5), borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          Text('XP earned', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
          const SizedBox(height: 5),
          Text('+${_focusMins * 6}', style: GoogleFonts.dmSans(fontSize: 38, fontWeight: FontWeight.w500, color: const Color(0xFFE8960F))),
          Text('Base ${_focusMins * 5} · streak bonus +${_focusMins}', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
        ]),
      ),
      const SizedBox(height: 12),

      // Stats grid
      Row(children: [
        Expanded(child: _doneStatCard('Duration', '${_focusMins}m', 'Full session', AppColors.textPrimary)),
        const SizedBox(width: 8),
        Expanded(child: _doneStatCard('Focus streak', '4', 'Personal best!', const Color(0xFFE8960F))),
        const SizedBox(width: 8),
        Expanded(child: _doneStatCard('Total today', '70m', 'Studied today', AppColors.accentLight)),
        const SizedBox(width: 8),
        Expanded(child: _doneStatCard('Day streak', '14', 'days in a row', AppColors.error)),
      ]),
      const SizedBox(height: 12),

      // Profile updated nudge
      Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(color: AppColors.accentSurface, border: Border.all(color: const Color(0xFF3D2580)), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          const Icon(Icons.verified_user_rounded, size: 18, color: AppColors.accentLight),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Profile updated', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.accentLight)),
            Text('Activity rings, XP and streak updated on your profile', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
          ])),
        ]),
      ),
      const SizedBox(height: 12),

      GestureDetector(onTap: () => _go(_StudyTab.focusSetup), child: Container(padding: const EdgeInsets.symmetric(vertical: 13), decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(14)), child: Center(child: Text('Start another session', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))))),
      const SizedBox(height: 8),
      GestureDetector(onTap: () => _go(_StudyTab.hub), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)), child: Center(child: Text('Back to Study', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary))))),
    ]),
  );

  Widget _doneStatCard(String label, String val, String sub, Color valColor) => Container(
    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
    decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(label, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary), textAlign: TextAlign.center),
      const SizedBox(height: 3),
      Text(val, style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w500, color: valColor)),
      Text(sub, style: GoogleFonts.dmSans(fontSize: 8, color: AppColors.textTertiary), textAlign: TextAlign.center),
    ]),
  );

  // ══════════════════════════════════════════
  // ROOMS BROWSE
  // ══════════════════════════════════════════
  Widget _roomsBrowse() => Column(children: [
    Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        GestureDetector(onTap: () => _go(_StudyTab.hub), child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Study rooms', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text('3 sessions live right now', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
        ])),
        _iBtn(Icons.search_rounded, () {}),
        const SizedBox(width: 6),
        _iBtn(Icons.notifications_none_rounded, () {}),
      ]),
    ),
    Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // You're in a room banner
      GestureDetector(
        onTap: () => _go(_StudyTab.inRoom),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: AppColors.successSurface, border: Border.all(color: AppColors.success, width: 1.5), borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
            const SizedBox(width: 9),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("You're in a room · WAEC Maths", style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.success)),
              Text('14 students · 28 min elapsed', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
            ])),
            Text('Return →', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.success)),
          ]),
        ),
      ),

      Text('LIVE NOW', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
      const SizedBox(height: 8),
      ..._rooms.map((r) => _roomCard(r)),


      // Scheduled
      Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text('SCHEDULED TODAY', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
      ),
      Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 9),
        decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 38, height: 38, decoration: BoxDecoration(color: const Color(0xFF2D1E00), borderRadius: BorderRadius.circular(11)), child: const Center(child: Text('⚡', style: TextStyle(fontSize: 18)))),
            const SizedBox(width: 9),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Physics — Waves & Sound', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              Text('Starts in 40 min · Emeka A.', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF2D1E00), border: Border.all(color: const Color(0xFFC47D0E).withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(20)), child: Text('Soon', style: GoogleFonts.dmSans(fontSize: 9, color: const Color(0xFFE8960F)))),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.surfaceVariant, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(20)), child: Text('Remind me', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary))),
          ]),
        ]),
      ),

      // Create room
      GestureDetector(
        onTap: () => _go(_StudyTab.createRoom),
        child: Container(
          padding: const EdgeInsets.all(13),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.add_rounded, size: 17, color: AppColors.textTertiary),
            const SizedBox(width: 8),
            Text('Create a new study room', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textTertiary)),
          ]),
        ),
      ),
    ]))),
  ]);
  Widget _roomCard(_Room r) => GestureDetector(
    onTap: () => _go(_StudyTab.inRoom),
    child: Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(color: r.bgColor, border: Border.all(color: r.borderColor), borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(11)), child: Center(child: Text(r.emoji, style: const TextStyle(fontSize: 18)))),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.title, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            Text(r.sub, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: r.tagBg, border: Border.all(color: r.tagColor.withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(20)), child: Text('Live', style: GoogleFonts.dmSans(fontSize: 9, color: r.tagColor))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          // Avatars
          Row(children: [
            _avatar('AO', AppColors.accentSurface, AppColors.accentLight),
            _avatar('TF', AppColors.successSurface, AppColors.success, offset: true),
            Transform.translate(offset: const Offset(-4, 0), child: Container(width: 20, height: 20, decoration: BoxDecoration(color: const Color(0xFF2D1E00), shape: BoxShape.circle, border: Border.all(color: AppColors.background, width: 1)), child: Center(child: Text('+${r.members - 2}', style: GoogleFonts.dmSans(fontSize: 7, color: const Color(0xFFE8960F)))))),
          ]),
          const SizedBox(width: 5),
          Text('${r.members} students', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
          const Spacer(),
          r.joined
            ? Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.successSurface, borderRadius: BorderRadius.circular(20)), child: Text("You're in ✓", style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.success)))
            : Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.accentSurface, borderRadius: BorderRadius.circular(20)), child: Text('Join →', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.accentLight))),
        ]),
      ]),
    ),
  );

  Widget _avatar(String initials, Color bg, Color tc, {bool offset = false}) => Container(
    transform: Matrix4.translationValues(offset ? -4 : 0, 0, 0),
    width: 20, height: 20,
    decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: Border.all(color: AppColors.background, width: 1)),
    child: Center(child: Text(initials, style: GoogleFonts.dmSans(fontSize: 7, fontWeight: FontWeight.w500, color: tc))),
  );

  // ══════════════════════════════════════════
  // IN ROOM
  // ══════════════════════════════════════════
  Widget _inRoom() => Column(children: [
    Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        GestureDetector(onTap: () => _go(_StudyTab.rooms), child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
        const SizedBox(width: 8),
        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('WAEC Mathematics revision', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text('14 students · live', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
        ])),
        Row(children: [
          _avatar('AO', AppColors.accentSurface, AppColors.accentLight),
          _avatar('TF', AppColors.successSurface, AppColors.success, offset: true),
          _avatar('KM', const Color(0xFF2D1E00), const Color(0xFFE8960F), offset: true),
        ]),
        const SizedBox(width: 8),
        _iBtn(Icons.more_horiz_rounded, () {}),
      ]),
    ),
    Expanded(child: ListView(padding: const EdgeInsets.all(12), children: [
      ..._chatMsgs.map((m) => _chatBubble(m)),
      const SizedBox(height: 8),

      // Gemini quiz widget
      Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: const Color(0xFF3D2580)), borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text('Gemini quiz challenge', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accentLight)),
          ]),
          const SizedBox(height: 8),
          Text('If sin θ = 3/5 and θ is in Q1, what is cos θ?', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.5)),
          const SizedBox(height: 10),
          ...['A  3/4', 'B  4/5', 'C  5/3', 'D  2/5'].asMap().entries.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: e.key == 1 ? AppColors.successSurface : AppColors.surfaceVariant,
              border: Border.all(color: e.key == 1 ? AppColors.success : AppColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Container(width: 20, height: 20, decoration: BoxDecoration(color: e.key == 1 ? AppColors.success : AppColors.surface, borderRadius: BorderRadius.circular(6)), child: Center(child: Text(e.value[0], style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500, color: e.key == 1 ? Colors.white : AppColors.textTertiary)))),
              const SizedBox(width: 8),
              Text(e.value.substring(3), style: GoogleFonts.dmSans(fontSize: 12, color: e.key == 1 ? const Color(0xFF6EE7B7) : AppColors.textSecondary)),
            ]),
          )),
        ]),
      ),
    ])),

    // Chat input
    Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(children: [
        Expanded(child: TextField(
          controller: _chatCtrl,
          style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Message the room…',
            hintStyle: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textTertiary),
            filled: true, fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: AppColors.accentDark)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        )),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () { HapticFeedback.lightImpact(); _chatCtrl.clear(); },
          child: Container(width: 36, height: 36, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle), child: const Icon(Icons.send_rounded, size: 16, color: Colors.white)),
        ),
      ]),
    ),
  ]);

  Widget _chatBubble(_ChatMsg m) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: m.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: m.isMe ? [
        Container(constraints: const BoxConstraints(maxWidth: 220), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: AppColors.accentSurface, border: Border.all(color: const Color(0xFF3D2580)), borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14), bottomLeft: Radius.circular(14), bottomRight: Radius.circular(4))), child: Text(m.text, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.accentLight, height: 1.55))),
        const SizedBox(width: 6),
        Container(width: 24, height: 24, decoration: const BoxDecoration(color: AppColors.accentSurface, shape: BoxShape.circle), child: Center(child: Text(m.avatar, style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w600, color: AppColors.accentLight)))),
      ] : [
        Container(width: 24, height: 24, decoration: BoxDecoration(color: m.isAI ? AppColors.accentSurface : AppColors.surfaceVariant, shape: BoxShape.circle), child: m.isAI ? const Icon(Icons.smart_toy_rounded, size: 12, color: AppColors.accentLight) : Center(child: Text(m.avatar, style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w600, color: AppColors.textSecondary)))),
        const SizedBox(width: 7),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m.name, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textDisabled)),
          const SizedBox(height: 2),
          Container(constraints: const BoxConstraints(maxWidth: 220), padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8), decoration: BoxDecoration(color: m.isAI ? AppColors.surface : AppColors.surfaceVariant, border: m.isAI ? Border.all(color: const Color(0xFF3D2580)) : null, borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14), bottomLeft: Radius.circular(4), bottomRight: Radius.circular(14))), child: Text(m.text, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textSecondary, height: 1.55))),
        ]),
      ],
    ),
  );
  // ══════════════════════════════════════════
  // CREATE ROOM
  // ══════════════════════════════════════════
  Widget _createRoom() {
    String _roomSubject = 'math';
    bool _isOpen = true;
    bool _geminiQuiz = true;
    bool _voiceChat = false;

    return StatefulBuilder(builder: (context, setS) => Column(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(children: [
          GestureDetector(onTap: () => _go(_StudyTab.rooms), child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
          const SizedBox(width: 12),
          Text('Create a study room', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ]),
      ),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(14), child: Column(children: [

        // Room name
        Container(
          padding: const EdgeInsets.all(13),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ROOM NAME', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            TextField(
              style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. WAEC Maths revision group',
                hintStyle: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textTertiary),
                filled: true, fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accentDark)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ]),
        ),

        // Subject
        Container(
          padding: const EdgeInsets.all(13),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SUBJECT', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Wrap(spacing: 7, runSpacing: 7, children: [
              ['math', '📐', 'Maths'], ['eng', '📝', 'English'], ['sci', '🔬', 'Science'], ['ielts', '🌍', 'IELTS'], ['phys', '⚡', 'Physics'],
            ].map((s) {
              final on = _roomSubject == s[0];
              return GestureDetector(
                onTap: () { HapticFeedback.selectionClick(); setS(() => _roomSubject = s[0]); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: on ? AppColors.accentSurface : AppColors.surfaceVariant, border: Border.all(color: on ? AppColors.accent : AppColors.border, width: on ? 1.5 : 0.5), borderRadius: BorderRadius.circular(20)),
                  child: Text('${s[1]} ${s[2]}', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: on ? AppColors.accentLight : AppColors.textTertiary)),
                ),
              );
            }).toList()),
          ]),
        ),

        // Room type
        Container(
          padding: const EdgeInsets.all(13),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ROOM TYPE', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
            const SizedBox(height: 9),
            GestureDetector(
              onTap: () { HapticFeedback.selectionClick(); setS(() => _isOpen = true); },
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 7),
                decoration: BoxDecoration(color: _isOpen ? AppColors.successSurface : AppColors.surfaceVariant, border: Border.all(color: _isOpen ? AppColors.success : AppColors.border, width: _isOpen ? 1.5 : 0.5), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(Icons.language_rounded, size: 18, color: _isOpen ? AppColors.success : AppColors.textTertiary),
                  const SizedBox(width: 9),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Open', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: _isOpen ? AppColors.success : AppColors.textSecondary)),
                    Text('Anyone can join from the rooms list', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
                  ])),
                  Container(width: 16, height: 16, decoration: BoxDecoration(color: _isOpen ? AppColors.success : AppColors.surfaceVariant, shape: BoxShape.circle), child: _isOpen ? const Icon(Icons.check_rounded, size: 10, color: Colors.white) : null),
                ]),
              ),
            ),
            GestureDetector(
              onTap: () { HapticFeedback.selectionClick(); setS(() => _isOpen = false); },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: !_isOpen ? AppColors.accentSurface : AppColors.surfaceVariant, border: Border.all(color: !_isOpen ? AppColors.accent : AppColors.border, width: !_isOpen ? 1.5 : 0.5), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(Icons.lock_outline_rounded, size: 18, color: !_isOpen ? AppColors.accentLight : AppColors.textTertiary),
                  const SizedBox(width: 9),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Invite only', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: !_isOpen ? AppColors.accentLight : AppColors.textSecondary)),
                    Text('Share a link to invite friends', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
                  ])),
                  Container(width: 16, height: 16, decoration: BoxDecoration(color: !_isOpen ? AppColors.accent : AppColors.surfaceVariant, shape: BoxShape.circle), child: !_isOpen ? const Icon(Icons.check_rounded, size: 10, color: Colors.white) : null),
                ]),
              ),
            ),
          ]),
        ),

        // Settings toggles
        Container(
          padding: const EdgeInsets.all(13),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            _createToggle('Enable Gemini quiz drops', 'AI drops live questions for the group', _geminiQuiz, () => setS(() => _geminiQuiz = !_geminiQuiz), border: true),
            _createToggle('Voice chat', 'Allow members to speak', _voiceChat, () => setS(() => _voiceChat = !_voiceChat)),
          ]),
        ),

        // Create CTA
        GestureDetector(
          onTap: () => _go(_StudyTab.inRoom),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(14)),
            child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.meeting_room_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('Create & join room', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ])),
          ),
        ),
        const SizedBox(height: 16),
      ]))),
    ]));
  }

  Widget _createToggle(String title, String sub, bool val, VoidCallback onTap, {bool border = false}) => GestureDetector(
    onTap: () { HapticFeedback.selectionClick(); onTap(); },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(border: Border(bottom: border ? const BorderSide(color: AppColors.border, width: 0.5) : BorderSide.none)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textPrimary)),
          Text(sub, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
        ])),
        Container(
          width: 40, height: 22,
          decoration: BoxDecoration(color: val ? AppColors.accent : AppColors.surfaceVariant, borderRadius: BorderRadius.circular(11)),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: val ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(margin: const EdgeInsets.all(2), width: 18, height: 18, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        ),
      ]),
    ),
  );
  Widget _iBtn(IconData icon, VoidCallback fn) => GestureDetector(
    onTap: fn,
    child: Container(width: 30, height: 30, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(9)), child: Icon(icon, size: 15, color: AppColors.textTertiary)),
  );
}

// ── Ring painter ──
class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2 - 4;
    final bg = Paint()..color = const Color(0xFF1E1E24)..style = PaintingStyle.stroke..strokeWidth = 4;
    final fg = Paint()..color = const Color(0xFF7C3AED)..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), r, bg);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), -1.5708, progress * 6.2832, false, fg);
  }
  @override bool shouldRepaint(_RingPainter old) => old.progress != progress;
}