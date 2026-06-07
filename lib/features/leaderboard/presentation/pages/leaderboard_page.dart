import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

enum _CompeteTab { compete, squadDetail, joinCreate }

class _Squad {
  final String key, name, meta, emoji;
  final Color iconBg, iconColor, borderColor;
  final List<_PodiumEntry> podium;
  final String yourRank, yourXP, gap;
  const _Squad({required this.key, required this.name, required this.meta, required this.emoji, required this.iconBg, required this.iconColor, required this.borderColor, required this.podium, required this.yourRank, required this.yourXP, required this.gap});
}

class _PodiumEntry {
  final String initials, name, xp;
  final Color bg, tc, borderColor;
  final int pos;
  const _PodiumEntry({required this.initials, required this.name, required this.xp, required this.bg, required this.tc, required this.borderColor, required this.pos});
}

class _LbRow {
  final String rank, initials, name, sub, xp, change;
  final Color bg, tc, changeColor;
  final bool isYou;
  const _LbRow({required this.rank, required this.initials, required this.name, required this.sub, required this.xp, required this.change, required this.bg, required this.tc, required this.changeColor, this.isYou = false});
}

const _squads = [
  _Squad(key: 'global', name: 'Global leaderboard', meta: '4,820 students · updated live', emoji: '🌍', iconBg: AppColors.accentSurface, iconColor: AppColors.accentLight, borderColor: AppColors.accent,
    podium: [
      _PodiumEntry(initials: 'ZN', name: 'Zara N.', xp: '3,960', bg: Color(0xFF0C1A3D), tc: Color(0xFF60A5FA), borderColor: Color(0xFF60A5FA), pos: 2),
      _PodiumEntry(initials: 'OK', name: 'Olumide K.', xp: '4,820', bg: Color(0xFF2D1E00), tc: Color(0xFFE8960F), borderColor: Color(0xFFC47D0E), pos: 1),
      _PodiumEntry(initials: 'EA', name: 'Emeka A.', xp: '3,640', bg: Color(0xFF2D1200), tc: Color(0xFFEA580C), borderColor: Color(0xFFEA580C), pos: 3),
    ], yourRank: '#38', yourXP: '2,840', gap: '50 XP from #37 ↑'),
  _Squad(key: 'waec', name: 'WAEC Crew', meta: '24 members · WAEC prep squad', emoji: '📐', iconBg: Color(0xFF2D1E00), iconColor: Color(0xFFE8960F), borderColor: Color(0xFFC47D0E),
    podium: [
      _PodiumEntry(initials: 'KO', name: 'Kemi O.', xp: '3,850', bg: AppColors.successSurface, tc: AppColors.success, borderColor: AppColors.success, pos: 2),
      _PodiumEntry(initials: 'TF', name: 'Tunde F.', xp: '4,200', bg: Color(0xFF2D1E00), tc: Color(0xFFE8960F), borderColor: Color(0xFFC47D0E), pos: 1),
      _PodiumEntry(initials: 'DA', name: 'Dami A.', xp: '3,100', bg: Color(0xFF0C1A3D), tc: Color(0xFF60A5FA), borderColor: Color(0xFF60A5FA), pos: 3),
    ], yourRank: '#4', yourXP: '2,750', gap: '350 XP from #3 ↑'),
  _Squad(key: 'uni', name: 'FUTA 2026', meta: '18 members · university class squad', emoji: '🎓', iconBg: AppColors.successSurface, iconColor: AppColors.success, borderColor: AppColors.success,
    podium: [
      _PodiumEntry(initials: 'AO', name: 'You', xp: '2,840', bg: AppColors.accentSurface, tc: AppColors.accentLight, borderColor: AppColors.accent, pos: 2),
      _PodiumEntry(initials: 'BA', name: 'Bola A.', xp: '5,100', bg: AppColors.accentSurface, tc: AppColors.accentLight, borderColor: AppColors.accent, pos: 1),
      _PodiumEntry(initials: 'CN', name: 'Chidi N.', xp: '2,600', bg: Color(0xFF2D0A1E), tc: Color(0xFFEC4899), borderColor: Color(0xFFEC4899), pos: 3),
    ], yourRank: '#2', yourXP: '2,840', gap: '2,260 XP behind #1'),
  _Squad(key: 'ielts', name: 'IELTS Squad', meta: '11 members · Band 7 chasers', emoji: '🌐', iconBg: Color(0xFF0C1A3D), iconColor: Color(0xFF60A5FA), borderColor: Color(0xFF185FA5),
    podium: [
      _PodiumEntry(initials: 'MA', name: 'Mimi A.', xp: '3,200', bg: Color(0xFF2D1E00), tc: Color(0xFFE8960F), borderColor: Color(0xFFC47D0E), pos: 2),
      _PodiumEntry(initials: 'ZN', name: 'Zara N.', xp: '3,960', bg: Color(0xFF0C1A3D), tc: Color(0xFF60A5FA), borderColor: Color(0xFF60A5FA), pos: 1),
      _PodiumEntry(initials: 'AO', name: 'You', xp: '2,840', bg: AppColors.accentSurface, tc: AppColors.accentLight, borderColor: AppColors.accent, pos: 3),
    ], yourRank: '#3', yourXP: '2,840', gap: '360 XP from #2 ↑'),
];

const _globalRows = [
  _LbRow(rank: '1', initials: 'OK', name: 'Olumide K.', sub: '🇳🇬 · 22-day streak', xp: '4,820', change: '↑ +320', bg: Color(0xFF2D1E00), tc: Color(0xFFE8960F), changeColor: AppColors.success),
  _LbRow(rank: '2', initials: 'ZN', name: 'Zara N.', sub: '🇬🇭 · 18-day streak', xp: '3,960', change: '↑ +180', bg: Color(0xFF0C1A3D), tc: Color(0xFF60A5FA), changeColor: AppColors.success),
  _LbRow(rank: '3', initials: 'EA', name: 'Emeka A.', sub: '🇳🇬 · 11-day streak', xp: '3,640', change: '↓ −40', bg: Color(0xFF2D1200), tc: Color(0xFFEA580C), changeColor: AppColors.error),
  _LbRow(rank: '37', initials: 'AB', name: 'Amaka B.', sub: '🇳🇬 · 9-day streak', xp: '2,890', change: '↑ +30', bg: AppColors.surfaceVariant, tc: AppColors.textSecondary, changeColor: AppColors.success),
  _LbRow(rank: '#38', initials: 'AO', name: 'You · Adaeze O.', sub: '50 XP from #37 ↑', xp: '2,840', change: '↑ +115', bg: AppColors.accentSurface, tc: AppColors.accentLight, changeColor: AppColors.success, isYou: true),
  _LbRow(rank: '39', initials: 'TF', name: 'Tunde F.', sub: 'Gaining fast 🔥', xp: '2,790', change: '↑ +200', bg: AppColors.successSurface, tc: AppColors.success, changeColor: AppColors.success),
];

const _squadDetailRows = [
  _LbRow(rank: '1', initials: 'TF', name: 'Tunde F.', sub: '14-day streak · 3 duels', xp: '4,200', change: '↑ +620', bg: Color(0xFF2D1E00), tc: Color(0xFFE8960F), changeColor: AppColors.success),
  _LbRow(rank: '2', initials: 'KO', name: 'Kemi O.', sub: '9-day streak · 2 duels', xp: '3,850', change: '↑ +280', bg: AppColors.successSurface, tc: AppColors.success, changeColor: AppColors.success),
  _LbRow(rank: '3', initials: 'DA', name: 'Dami A.', sub: '7-day streak', xp: '3,100', change: '↑ +190', bg: Color(0xFF0C1A3D), tc: Color(0xFF60A5FA), changeColor: AppColors.success),
  _LbRow(rank: '#4', initials: 'AO', name: 'You', sub: '350 XP from #3 ↑', xp: '2,750', change: '↑ +115', bg: AppColors.accentSurface, tc: AppColors.accentLight, changeColor: AppColors.success, isYou: true),
  _LbRow(rank: '5', initials: 'BA', name: 'Bola A.', sub: 'Closing fast 🔥', xp: '2,600', change: '↑ +310', bg: Color(0xFF2D0A1E), tc: Color(0xFFEC4899), changeColor: AppColors.success),
];

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});
  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  _CompeteTab _tab = _CompeteTab.compete;
  int _squadIdx = 0;
  String _period = 'week';
  bool _squadOpen = true;

  void _go(_CompeteTab tab) {
    HapticFeedback.selectionClick();
    setState(() => _tab = tab);
  }

  _Squad get _squad => _squads[_squadIdx];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    switch (_tab) {
      case _CompeteTab.compete:    return _compete();
      case _CompeteTab.squadDetail: return _squadDetail();
      case _CompeteTab.joinCreate:  return _joinCreate();
    }
  }

  // ══════════════════════════════════════════
  // COMPETE
  // ══════════════════════════════════════════
  Widget _compete() => Column(children: [
    // Header
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Compete', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          Text('Your squad leaderboards', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
        ])),
        GestureDetector(onTap: () => _go(_CompeteTab.joinCreate), child: _iBtn(Icons.add_rounded)),
        const SizedBox(width: 7),
        _iBtn(Icons.share_rounded),
      ]),
    ),

    // Squad tabs
    Container(
      height: 86,
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        children: [
          ..._squads.asMap().entries.map((e) {
            final on = _squadIdx == e.key;
            return GestureDetector(
              onTap: () { HapticFeedback.selectionClick(); setState(() => _squadIdx = e.key); },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                child: Column(children: [
                  Container(width: 46, height: 46, decoration: BoxDecoration(color: e.value.iconBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: on ? e.value.borderColor : Colors.transparent, width: 2)),
                    child: Center(child: Text(e.value.emoji, style: const TextStyle(fontSize: 20)))),
                  const SizedBox(height: 3),
                  Text(e.value.name.split(' ').first, style: GoogleFonts.dmSans(fontSize: 9, color: on ? e.value.iconColor : AppColors.textTertiary)),
                ]),
              ),
            );
          }),
          GestureDetector(
            onTap: () => _go(_CompeteTab.joinCreate),
            child: Column(children: [
              Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border, style: BorderStyle.solid)),
                child: const Icon(Icons.add_rounded, size: 20, color: AppColors.textTertiary)),
              const SizedBox(height: 3),
              Text('Join squad', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textDisabled)),
            ]),
          ),
        ],
      ),
    ),

    // Period tabs
    Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
        child: Row(children: ['week', 'month', 'all'].map((p) {
          final labels = {'week': 'This week', 'month': 'This month', 'all': 'All time'};
          final on = _period == p;
          return Expanded(child: GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); setState(() => _period = p); },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(color: on ? AppColors.accentSurface : Colors.transparent, border: on ? Border.all(color: const Color(0xFF2D1B6B), width: 0.5) : null, borderRadius: BorderRadius.circular(9)),
              child: Center(child: Text(labels[p]!, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: on ? AppColors.accentLight : AppColors.textTertiary))),
            ),
          ));
        }).toList()),
      ),
    ),

    // Squad info strip
    Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(color: AppColors.accentSurface, border: Border.all(color: const Color(0xFF2D1B6B)), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Text(_squad.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_squad.name, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            Text(_squad.meta, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
          ])),
          GestureDetector(onTap: () => _go(_CompeteTab.squadDetail), child: Text('Details →', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.accentLight, fontWeight: FontWeight.w500))),
        ]),
      ),
    ),

    Expanded(child: SingleChildScrollView(child: Column(children: [
      // Podium
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          _podiumItem(_squad.podium[0]),
          const SizedBox(width: 8),
          _podiumItem(_squad.podium[1]),
          const SizedBox(width: 8),
          _podiumItem(_squad.podium[2]),
        ]),
      ),

      // Ranked list
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(children: [
          ..._globalRows.map((r) => Column(children: [
            _lbRow(r),
            if (r != _globalRows.last) Container(height: 0.5, color: AppColors.surfaceVariant, margin: const EdgeInsets.symmetric(horizontal: 4)),
            if (r.rank == '3') Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Center(child: Text('· · ·', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textDisabled)))),
          ])),
        ]),
      ),

      // Quick action CTA
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.accentSurface, border: Border.all(color: const Color(0xFF2D1B6B)), borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF2D1B6B), borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.bolt_rounded, size: 18, color: AppColors.accentLight)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Do a quick quiz now', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.accentLight)),
              Text('+50 XP puts you at #37', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
            ])),
            Text('Go →', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.accentLight)),
          ]),
        ),
      ),
    ]))),
  ]);

  Widget _podiumItem(_PodiumEntry e) {
    final h = e.pos == 1 ? 58.0 : e.pos == 2 ? 42.0 : 28.0;
    final av = e.pos == 1 ? 56.0 : 46.0;
    return Column(children: [
      if (e.pos == 1) const Text('👑', style: TextStyle(fontSize: 18)),
      if (e.pos != 1) const SizedBox(height: 18),
      Container(width: av, height: av, decoration: BoxDecoration(color: e.bg, shape: BoxShape.circle, border: Border.all(color: e.borderColor, width: e.pos == 1 ? 2.5 : 2)),
        child: Center(child: Text(e.initials, style: GoogleFonts.dmSans(fontSize: e.pos == 1 ? 14 : 13, fontWeight: FontWeight.w500, color: e.tc)))),
      const SizedBox(height: 3),
      Text(e.name, style: GoogleFonts.dmSans(fontSize: 9, color: e.tc)),
      Text(e.xp, style: GoogleFonts.dmSans(fontSize: e.pos == 1 ? 10 : 9, fontWeight: FontWeight.w500, color: e.tc)),
      Container(
        width: e.pos == 1 ? 82 : 72, height: h,
        decoration: BoxDecoration(color: e.bg, border: Border.all(color: e.borderColor, width: 0.5), borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        child: Center(child: Text('${e.pos}', style: GoogleFonts.dmSans(fontSize: e.pos == 1 ? 22 : 18, fontWeight: FontWeight.w500, color: e.tc))),
      ),
    ]);
  }

  Widget _lbRow(_LbRow r) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
    decoration: BoxDecoration(color: r.isYou ? AppColors.accentSurface : Colors.transparent, border: r.isYou ? Border.all(color: const Color(0xFF2D1B6B), width: 0.5) : null, borderRadius: r.isYou ? BorderRadius.circular(13) : null),
    child: Row(children: [
      SizedBox(width: 26, child: Center(child: Text(r.rank, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: r.isYou ? FontWeight.w500 : FontWeight.normal, color: r.isYou ? AppColors.accentLight : AppColors.textTertiary)))),
      const SizedBox(width: 5),
      Container(width: 32, height: 32, decoration: BoxDecoration(color: r.bg, shape: BoxShape.circle), child: Center(child: Text(r.initials, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: r.tc)))),
      const SizedBox(width: 9),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(r.name, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        Text(r.sub, style: GoogleFonts.dmSans(fontSize: 9, color: r.isYou ? AppColors.accentLight : AppColors.textTertiary)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(r.xp, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: r.isYou ? AppColors.accentLight : AppColors.textSecondary)),
        Text(r.change, style: GoogleFonts.dmSans(fontSize: 9, color: r.changeColor)),
      ]),
    ]),
  );

  // ══════════════════════════════════════════
  // SQUAD DETAIL
  // ══════════════════════════════════════════
  Widget _squadDetail() => Column(children: [
    Container(
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        GestureDetector(onTap: () => _go(_CompeteTab.compete), child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
        const SizedBox(width: 9),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_squad.name, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          Text(_squad.meta, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
        ])),
        _iBtn(Icons.settings_rounded),
      ]),
    ),
    Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(14), child: Column(children: [

      // Stats grid
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.2,
        children: [
          _statCard('Your rank', _squad.yourRank, '↑ +2 this week', AppColors.accentLight, AppColors.success),
          _statCard('Squad XP', '62k', 'combined this week', const Color(0xFFE8960F), AppColors.textTertiary),
          _statCard('Top subject', '📐 Maths', 'most studied topic', AppColors.textPrimary, AppColors.textTertiary),
          _statCard('Duels won', '14', 'vs other squads', AppColors.success, AppColors.textTertiary),
        ],
      ),
      const SizedBox(height: 14),

      // Squad rankings
      Align(alignment: Alignment.centerLeft, child: Text('SQUAD RANKINGS', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5))),
      const SizedBox(height: 9),
      Container(
        decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
        child: Column(children: _squadDetailRows.asMap().entries.map((e) {
          final r = e.value;
          return Column(children: [
            _lbRow(r),
            if (e.key < _squadDetailRows.length - 1) Container(height: 0.5, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 8)),
          ]);
        }).toList()),
      ),
      const SizedBox(height: 14),

      // Challenge squad CTA
      Container(
        padding: const EdgeInsets.all(13),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: AppColors.errorSurface, border: Border.all(color: AppColors.error), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          const Icon(Icons.sports_kabaddi_rounded, size: 18, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Challenge another squad', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.error)),
            Text('Pick a rival squad and compete for the week', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.error),
        ]),
      ),

      // Leave squad
      Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('Leave squad', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textDisabled)))),
    ]))),
  ]);

  Widget _statCard(String label, String val, String sub, Color valColor, Color subColor) => Container(
    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
    decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
      const SizedBox(height: 3),
      Text(val, style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w500, color: valColor)),
      Text(sub, style: GoogleFonts.dmSans(fontSize: 9, color: subColor)),
    ]),
  );

  // ══════════════════════════════════════════
  // JOIN / CREATE
  // ══════════════════════════════════════════
  Widget _joinCreate() => Column(children: [
    Container(
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        GestureDetector(onTap: () => _go(_CompeteTab.compete), child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
        const SizedBox(width: 9),
        Text('Join or create a squad', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      ]),
    ),
    Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(14), child: Column(children: [

      // Search
      Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.search_rounded, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(child: TextField(
            style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textPrimary),
            decoration: InputDecoration(hintText: 'Search squads by name or code…', hintStyle: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textTertiary), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
          )),
        ]),
      ),

      // Suggested squads
      Align(alignment: Alignment.centerLeft, child: Text('SUGGESTED FOR YOU', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5))),
      const SizedBox(height: 9),
      ...[
        ['🎓', 'UNILAG Science 2026', '48 members · open to join', AppColors.accentSurface, AppColors.accentLight, const Color(0xFF2D1B6B), 'Join', AppColors.accentSurface, AppColors.accentLight],
        ['🌍', 'IELTS Band 7 Chasers', '31 members · open to join', AppColors.successSurface, AppColors.success, AppColors.success, 'Join', AppColors.successSurface, AppColors.success],
        ['📐', 'WAEC Maths Warriors', '62 members · invite only', const Color(0xFF2D1E00), const Color(0xFFE8960F), const Color(0xFFC47D0E), 'Request', AppColors.surfaceVariant, AppColors.textTertiary],
      ].map((s) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: s[3] as Color, borderRadius: BorderRadius.circular(11), border: Border.all(color: s[5] as Color)),
            child: Center(child: Text(s[0] as String, style: const TextStyle(fontSize: 18)))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s[1] as String, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            Text(s[2] as String, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(color: s[7] as Color, border: Border.all(color: (s[8] as Color).withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(20)),
            child: Text(s[6] as String, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: s[8] as Color))),
        ]),
      )),

      // Divider
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(children: [
          Expanded(child: Container(height: 0.5, color: AppColors.border)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('or', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textDisabled))),
          Expanded(child: Container(height: 0.5, color: AppColors.border)),
        ]),
      ),

      // Create squad
      Align(alignment: Alignment.centerLeft, child: Text('CREATE A NEW SQUAD', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5))),
      const SizedBox(height: 9),
      Container(
        padding: const EdgeInsets.all(13),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          TextField(
            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Squad name e.g. FUTA Maths Gang',
              hintStyle: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textTertiary),
              filled: true, fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accentDark)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 9),
          Row(children: [
            GestureDetector(
              onTap: () { HapticFeedback.selectionClick(); setState(() => _squadOpen = true); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: _squadOpen ? AppColors.accentSurface : AppColors.surfaceVariant, border: Border.all(color: _squadOpen ? AppColors.accent : AppColors.border, width: _squadOpen ? 1.5 : 0.5), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.language_rounded, size: 11, color: _squadOpen ? AppColors.accentLight : AppColors.textTertiary),
                  const SizedBox(width: 3),
                  Text('Open', style: GoogleFonts.dmSans(fontSize: 11, color: _squadOpen ? AppColors.accentLight : AppColors.textTertiary)),
                ]),
              ),
            ),
            const SizedBox(width: 7),
            GestureDetector(
              onTap: () { HapticFeedback.selectionClick(); setState(() => _squadOpen = false); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: !_squadOpen ? AppColors.accentSurface : AppColors.surfaceVariant, border: Border.all(color: !_squadOpen ? AppColors.accent : AppColors.border, width: !_squadOpen ? 1.5 : 0.5), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.lock_outline_rounded, size: 11, color: !_squadOpen ? AppColors.accentLight : AppColors.textTertiary),
                  const SizedBox(width: 3),
                  Text('Invite only', style: GoogleFonts.dmSans(fontSize: 11, color: !_squadOpen ? AppColors.accentLight : AppColors.textTertiary)),
                ]),
              ),
            ),
          ]),
        ]),
      ),

      GestureDetector(
        onTap: () => _go(_CompeteTab.compete),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(14)),
          child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.group_add_rounded, color: Colors.white, size: 17),
            const SizedBox(width: 7),
            Text('Create squad', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
          ])),
        ),
      ),
      const SizedBox(height: 16),
    ]))),
  ]);

  Widget _iBtn(IconData icon) => Container(
    width: 30, height: 30,
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(9)),
    child: Icon(icon, size: 15, color: AppColors.textTertiary),
  );
}