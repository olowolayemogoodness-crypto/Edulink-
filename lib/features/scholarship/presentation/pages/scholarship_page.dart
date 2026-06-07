import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

enum _ScholarshipTab { overview, rank, registration, registered, winners }

const _goldColor = Color(0xFFEF9F27);
const _goldBg = Color(0xFF2D1E00);
const _goldBorder = Color(0xFFBA7517);

class ScholarshipPage extends StatefulWidget {
  const ScholarshipPage({super.key});
  @override
  State<ScholarshipPage> createState() => _ScholarshipPageState();
}

class _ScholarshipPageState extends State<ScholarshipPage> with TickerProviderStateMixin {
  _ScholarshipTab _tab = _ScholarshipTab.overview;
  String _payMethod = 'card';
  Timer? _cdTimer;
  int _cdDays = 4, _cdHours = 11, _cdMins = 23, _cdSecs = 7;

  @override
  void initState() {
    super.initState();
    _cdTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_cdSecs > 0) { _cdSecs--; }
        else if (_cdMins > 0) { _cdMins--; _cdSecs = 59; }
        else if (_cdHours > 0) { _cdHours--; _cdMins = 59; _cdSecs = 59; }
        else if (_cdDays > 0) { _cdDays--; _cdHours = 23; _cdMins = 59; _cdSecs = 59; }
      });
    });
  }

  @override
  void dispose() {
    _cdTimer?.cancel();
    super.dispose();
  }

  void _go(_ScholarshipTab tab) {
    HapticFeedback.selectionClick();
    setState(() => _tab = tab);
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
      case _ScholarshipTab.overview:     return _overview();
      case _ScholarshipTab.rank:         return _rank();
      case _ScholarshipTab.registration: return _registration();
      case _ScholarshipTab.registered:   return _registered();
      case _ScholarshipTab.winners:      return _winners();
    }
  }

  // ══════════════════════════════════════════
  // OVERVIEW
  // ══════════════════════════════════════════
  Widget _overview() => Column(children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
      child: Row(children: [
        GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
        const SizedBox(width: 12),
        Expanded(child: Text('Scholarship', style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
        GestureDetector(
          onTap: () => _go(_ScholarshipTab.winners),
          child: Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.emoji_events_rounded, size: 16, color: _goldColor)),
        ),
        const SizedBox(width: 8),
        Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.share_rounded, size: 16, color: AppColors.textTertiary)),
      ]),
    ),
    Expanded(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // Prize hero
      Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF1E1600), border: Border.all(color: _goldBorder, width: 1.5), borderRadius: BorderRadius.circular(22)),
        child: Column(children: [
          const Text('🏆', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 8),
          Text('₦1,000,000', style: GoogleFonts.dmSans(fontSize: 34, fontWeight: FontWeight.w500, color: _goldColor, height: 1)),
          const SizedBox(height: 4),
          Text('Grand prize · EduLink Scholarship Season 3', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _cdCell(_cdDays.toString().padLeft(2, '0'), 'days'),
            const SizedBox(width: 8),
            _cdCell(_cdHours.toString().padLeft(2, '0'), 'hrs'),
            const SizedBox(width: 8),
            _cdCell(_cdMins.toString().padLeft(2, '0'), 'min'),
            const SizedBox(width: 8),
            _cdCell(_cdSecs.toString().padLeft(2, '0'), 'sec'),
          ]),
        ]),
      ),

      // Progress header
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
        child: Row(children: [
          Text('Your progress', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          const Spacer(),
          GestureDetector(onTap: () => _go(_ScholarshipTab.rank), child: Text('See stages →', style: GoogleFonts.dmSans(fontSize: 10, color: _goldColor))),
        ]),
      ),

      // Stage track
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(children: [
          _stageItem('Stage 1 — complete', 'Leaderboard threshold', 'Reach 3,600 points on the global leaderboard to unlock registration.', 'done', 'Passed ✓', '14,280 students qualified', onTap: () {}),
          _stageItem('Stage 2 — action required', 'Pay registration fee', 'Pay ₦2,500 to secure your spot in the qualifier exam. Fee is non-refundable.', 'active', 'Pay now →', 'Closes in 4 days', onTap: () => _go(_ScholarshipTab.registration)),
          _stageItem('Stage 3 — locked', 'Qualifier exam', '50 timed questions. Top 200 scorers advance to the final round.', 'locked', 'Unlocks after payment', '200 spots available'),
          _stageItem('Stage 4 — locked', 'Final round', 'Live 30-question battle. Top 10 students compete in real time for the grand prize.', 'locked', 'Top 200 only', '10 finalists advance'),
          _stageItem('Stage 5 — locked', 'Grand prize winner', 'The highest scorer wins ₦1,000,000 cash. Runners-up receive prizes too.', 'locked', '1 winner', '₦1,000,000 prize', last: true),
        ]),
      ),
    ]))),
  ]);

  Widget _cdCell(String num, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(color: _goldBg, borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Text(num, style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w500, color: _goldColor, height: 1)),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.dmSans(fontSize: 8, color: AppColors.textDisabled)),
    ]),
  );

  Widget _stageItem(String stageNum, String name, String desc, String status, String pill, String count, {VoidCallback? onTap, bool last = false}) {
    Color nodeColor, nodeBorder, stageBg, stageBorder, stageNumColor, pillBg, pillColor;
    Widget nodeChild;
    switch (status) {
      case 'done':
        nodeColor = const Color(0xFF0D2219); nodeBorder = AppColors.success;
        stageBg = const Color(0xFF0D1F14); stageBorder = const Color(0xFF0F6E56);
        stageNumColor = AppColors.success; pillBg = const Color(0xFF0D2219); pillColor = AppColors.success;
        nodeChild = const Icon(Icons.check_rounded, size: 18, color: AppColors.success);
        break;
      case 'active':
        nodeColor = _goldBg; nodeBorder = _goldBorder;
        stageBg = const Color(0xFF1E1600); stageBorder = _goldBorder;
        stageNumColor = _goldColor; pillBg = _goldBg; pillColor = _goldColor;
        nodeChild = Text('₦', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: _goldColor));
        break;
      default:
        nodeColor = AppColors.surface; nodeBorder = AppColors.border;
        stageBg = AppColors.surface; stageBorder = AppColors.border;
        stageNumColor = AppColors.textDisabled; pillBg = AppColors.surfaceVariant; pillColor = AppColors.textDisabled;
        nodeChild = const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textDisabled);
    }
    return GestureDetector(
      onTap: onTap,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: nodeColor, shape: BoxShape.circle, border: Border.all(color: nodeBorder, width: 2)), child: Center(child: nodeChild)),
          if (!last) Container(width: 2, height: 60, color: AppColors.surfaceVariant),
        ]),
        const SizedBox(width: 12),
        Expanded(child: Container(
          margin: EdgeInsets.only(bottom: last ? 0 : 10),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(color: stageBg, border: Border.all(color: stageBorder, width: status == 'done' || status == 'active' ? 1 : 0.5), borderRadius: BorderRadius.circular(14), backgroundBlendMode: status == 'locked' ? BlendMode.srcOver : null),
          child: Opacity(opacity: status == 'locked' ? 0.5 : 1.0, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(stageNum, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500, color: stageNumColor, letterSpacing: 0.5)),
            const SizedBox(height: 3),
            Text(name, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(desc, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary, height: 1.5)),
            const SizedBox(height: 6),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: pillBg, borderRadius: BorderRadius.circular(20)), child: Text(pill, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500, color: pillColor))),
              const Spacer(),
              Text(count, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textDisabled)),
            ]),
          ])),
        )),
      ]),
    );
  }

  // ══════════════════════════════════════════
  // RANK
  // ══════════════════════════════════════════
  Widget _rank() => Column(children: [
    Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        GestureDetector(onTap: () => _go(_ScholarshipTab.overview), child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
        const SizedBox(width: 12),
        Text('Your leaderboard rank', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      ]),
    ),
    Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      // Qualify card
      Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: AppColors.accentSurface, border: Border.all(color: const Color(0xFF534AB7), width: 1.5), borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          Row(children: [
            Text('Points to qualify', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFFAFA9EC))),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.background, border: Border.all(color: const Color(0xFF534AB7)), borderRadius: BorderRadius.circular(20)), child: Text('Stage 1', style: GoogleFonts.dmSans(fontSize: 9, color: const Color(0xFF7F77DD)))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Text('2,808 pts', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF7F77DD))),
            const Spacer(),
            Text('Goal: 3,600 pts', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
          ]),
          const SizedBox(height: 5),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: 0.78, minHeight: 8, backgroundColor: AppColors.background, valueColor: const AlwaysStoppedAnimation(Color(0xFF534AB7)))),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)), child: Column(children: [Text('✓', style: GoogleFonts.dmSans(fontSize: 16, color: AppColors.success)), Text('Qualified!', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textDisabled))]))),
            const SizedBox(width: 8),
            Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)), child: Column(children: [Text('#38', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500, color: _goldColor)), Text('Global rank', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textDisabled))]))),
            const SizedBox(width: 8),
            Text('Pts ahead of #39', textAlign: TextAlign.center, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textDisabled))
          ]),
        ]),
      ),

      // How to earn points
      Align(alignment: Alignment.centerLeft, child: Text('How to earn points', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
      const SizedBox(height: 8),
      ...[
        [Icons.quiz_rounded, AppColors.accentSurface, AppColors.accentLight, 'Complete a quiz', '10 questions', '+50 XP', AppColors.accentLight],
        [Icons.edit_note_rounded, _goldBg, _goldColor, 'Practice exam', 'Full paper', '+200 XP', _goldColor],
        [Icons.menu_book_rounded, const Color(0xFF0D2219), const Color(0xFF5DCAA5), 'Reading session', 'Per 30 min', '+75 XP', const Color(0xFF5DCAA5)],
        [Icons.groups_rounded, const Color(0xFF0C1E32), const Color(0xFF85B7EB), 'Study room session', 'Per hour', '+60 XP', const Color(0xFF85B7EB)],
        [Icons.sports_kabaddi_rounded, const Color(0xFF2A1020), const Color(0xFFED93B1), 'Win a duel', "Beat a friend's challenge", '+120 XP', const Color(0xFFED93B1)],
      ].map((r) => Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: r[0] == Icons.sports_kabaddi_rounded ? const Color(0xFF993556) : AppColors.border, width: r[0] == Icons.sports_kabaddi_rounded ? 0.5 : 1), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: r[1] as Color, borderRadius: BorderRadius.circular(9)), child: Icon(r[0] as IconData, size: 15, color: r[2] as Color)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r[3] as String, style: GoogleFonts.dmSans(fontSize: 11, color: r[0] == Icons.sports_kabaddi_rounded ? const Color(0xFFED93B1) : AppColors.textSecondary)),
            Text(r[4] as String, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textDisabled)),
          ])),
          Text(r[5] as String, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: r[6] as Color)),
        ]),
      )),
      const SizedBox(height: 14),
      GestureDetector(
        onTap: () => _go(_ScholarshipTab.registration),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(color: _goldBorder, borderRadius: BorderRadius.circular(14)),
          child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.credit_card_rounded, color: Colors.white, size: 17),
            const SizedBox(width: 8),
            Text('Pay registration · ₦2,500', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
          ])),
        ),
      ),
      const SizedBox(height: 16),
    ]))),
  ]);

  // ══════════════════════════════════════════
  // REGISTRATION
  // ══════════════════════════════════════════
  Widget _registration() => Column(children: [
    Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        GestureDetector(onTap: () => _go(_ScholarshipTab.overview), child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
        const SizedBox(width: 12),
        Text('Registration', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      ]),
    ),
    Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _goldBg, border: Border.all(color: _goldBorder, width: 1.5), borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF1E1600), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.emoji_events_rounded, size: 20, color: _goldColor)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('EduLink Scholarship S3', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: _goldColor)),
              Text('Secure your qualifier spot', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
            ]),
          ]),
          const SizedBox(height: 12),

          // Price breakdown
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Qualifier exam access', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)), Text('₦2,000', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textSecondary))]),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Platform fee', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)), Text('₦500', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textSecondary))]),
              const SizedBox(height: 8),
              Container(height: 0.5, color: AppColors.border),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)), Text('₦2,500', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: _goldColor))]),
            ]),
          ),
          const SizedBox(height: 12),

          // Perks
          ...[
            'Access to qualifier exam (50 questions · 60 min)',
            'Chance at ₦1,000,000 grand prize',
            'Certificate of participation',
            '+500 bonus XP on completion',
          ].map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              const Icon(Icons.check_rounded, size: 14, color: AppColors.success),
              const SizedBox(width: 8),
              Expanded(child: Text(p, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textSecondary))),
            ]),
          )),
          const SizedBox(height: 12),

          // Pay method
          Text('Pay with', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
          const SizedBox(height: 8),
          Row(children: [
            _payBtn('card', Icons.credit_card_rounded, 'Card'),
            const SizedBox(width: 7),
            _payBtn('transfer', Icons.account_balance_rounded, 'Transfer'),
            const SizedBox(width: 7),
            _payBtn('ussd', Icons.phone_android_rounded, 'USSD'),
          ]),
          const SizedBox(height: 14),

          GestureDetector(
            onTap: () => _go(_ScholarshipTab.registered),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(color: _goldBorder, borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text('Pay ₦2,500 & register', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white))),
            ),
          ),
          const SizedBox(height: 6),
          Center(child: Text('Secured by Paystack · Closes in 4 days', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textDisabled))),
        ]),
      ),
      const SizedBox(height: 16),
    ]))),
  ]);

  Widget _payBtn(String key, IconData icon, String label) {
    final on = _payMethod == key;
    return Expanded(child: GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); setState(() => _payMethod = key); },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: on ? _goldBg : AppColors.surface, border: Border.all(color: on ? _goldBorder : AppColors.border, width: on ? 1.5 : 0.5), borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Icon(icon, size: 13, color: on ? _goldColor : AppColors.textTertiary),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500, color: on ? _goldColor : AppColors.textTertiary)),
        ]),
      ),
    ));
  }

  // ══════════════════════════════════════════
  // REGISTERED
  // ══════════════════════════════════════════
  Widget _registered() => SingleChildScrollView(
    padding: const EdgeInsets.all(22),
    child: Column(children: [
      const SizedBox(height: 20),
      Container(width: 72, height: 72, decoration: BoxDecoration(color: const Color(0xFF0D2219), shape: BoxShape.circle, border: Border.all(color: AppColors.success, width: 2)), child: const Icon(Icons.check_rounded, size: 32, color: AppColors.success)),
      const SizedBox(height: 16),
      Text("You're registered!", style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      Text('EduLink Scholarship Season 3 · Qualifier', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textTertiary)),
      const SizedBox(height: 24),

      // Qualifier details
      Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('QUALIFIER DETAILS', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          ...[
            [Icons.calendar_today_rounded, _goldBg, _goldColor, 'Date', 'Saturday, June 7, 2026'],
            [Icons.timer_outlined, const Color(0xFF0D2219), AppColors.success, 'Duration', '60 minutes · 50 questions'],
            [Icons.groups_rounded, AppColors.accentSurface, AppColors.accentLight, 'Advancing', 'Top 200 scorers go to the final'],
            [Icons.emoji_events_rounded, _goldBg, _goldColor, 'Grand prize', '₦1,000,000'],
          ].map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(width: 30, height: 30, decoration: BoxDecoration(color: r[1] as Color, borderRadius: BorderRadius.circular(9)), child: Icon(r[0] as IconData, size: 14, color: r[2] as Color)),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r[3] as String, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
                Text(r[4] as String, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: r[0] == Icons.emoji_events_rounded ? _goldColor : AppColors.textPrimary)),
              ]),
            ]),
          )),
        ]),
      ),

      // Prep nudge
      Container(
        padding: const EdgeInsets.all(13),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(color: AppColors.accentSurface, border: Border.all(color: const Color(0xFF3D2580)), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Gemini prep plan', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accentLight)),
            const SizedBox(height: 3),
            Text('You have 3 days to prepare. Focus on circle geometry and logarithms — your two weakest topics based on recent practice.', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textSecondary, height: 1.6)),
          ])),
        ]),
      ),

      GestureDetector(
        onTap: () => _go(_ScholarshipTab.overview),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text('Back to overview', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
        ),
      ),
      GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text('Back to Discover', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary))),
        ),
      ),
      const SizedBox(height: 16),
    ]),
  );

  // ══════════════════════════════════════════
  // WINNERS
  // ══════════════════════════════════════════
  Widget _winners() => Column(children: [
    Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        GestureDetector(onTap: () => _go(_ScholarshipTab.overview), child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
        const SizedBox(width: 12),
        Text('Past winners', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      ]),
    ),
    Expanded(child: SingleChildScrollView(child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(children: [
          Text('Season 2 Winners', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w500, color: _goldColor)),
          const SizedBox(height: 4),
          Text('June 2025 · 18,420 participants', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
          const SizedBox(height: 16),

          // Podium
          Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
            _podiumItem('TF', AppColors.successSurface, AppColors.success, '2nd', '₦200k', 70, 2),
            const SizedBox(width: 8),
            _podiumItem('AO', _goldBg, _goldColor, '1st', '₦1M', 90, 1),
            const SizedBox(width: 8),
            _podiumItem('KM', const Color(0xFF2A1F00), const Color(0xFFCD7F32), '3rd', '₦100k', 55, 3),
          ]),
        ]),
      ),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ALL WINNERS', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          ...[
            ['AO', _goldBg, _goldColor, 'Adaeze O.', 'Lagos · 94% score', '₦1,000,000'],
            ['TF', AppColors.successSurface, AppColors.success, 'Tunde F.', 'Abuja · 91% score', '₦200,000'],
            ['KM', const Color(0xFF2A1F00), const Color(0xFFCD7F32), 'Kemi M.', 'Ibadan · 88% score', '₦100,000'],
            ['ZN', const Color(0xFF0C1A3D), const Color(0xFF60A5FA), 'Zara N.', 'Port Harcourt · 85% score', '₦50,000'],
            ['EM', AppColors.surfaceVariant, AppColors.textSecondary, 'Emeka A.', 'Enugu · 83% score', '₦50,000'],
          ].map((w) => Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
            child: Row(children: [
              Container(width: 30, height: 30, decoration: BoxDecoration(color: w[1] as Color, shape: BoxShape.circle), child: Center(child: Text(w[0] as String, style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500, color: w[2] as Color)))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(w[3] as String, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text(w[4] as String, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textDisabled)),
              ])),
              Text(w[5] as String, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: _goldColor)),
            ]),
          )),
        ]),
      ),
    ]))),
  ]);

  Widget _podiumItem(String initials, Color bg, Color tc, String place, String prize, double height, int pos) => Column(children: [
    Container(width: 48, height: 48, decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: Border.all(color: tc, width: pos == 1 ? 2.5 : 1.5)), child: Center(child: Text(initials, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: tc)))),
    const SizedBox(height: 4),
    Text(place, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: tc)),
    Container(
      width: pos == 1 ? 70 : 58, height: height,
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
      child: Center(child: Text(prize, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500, color: tc))),
    ),
  ]);
}