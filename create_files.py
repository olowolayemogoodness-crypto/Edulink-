import os

def w(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, 'w').write(content)
    print('OK:', path)

w('lib/features/home/presentation/widgets/activity_grid.dart', """import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class ActivityGrid extends StatelessWidget {
  const ActivityGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _ACard('AI Tutor','Ask anything',Icons.auto_awesome_rounded,const Color(0xFF1E1D3A),AppColors.accentLight,const Color(0xFF3C3489),const Color(0xFF1A1A30),'Gemini',const Color(0xFF2D1B69),AppColors.accentLight,0.0,AppColors.accent),
      _ACard('Quiz','12 ready',Icons.quiz_rounded,const Color(0xFF0D2219),const Color(0xFF1D9E75),const Color(0xFF0F6E56),const Color(0xFF0D1F14),'+50 XP',const Color(0xFF0F2A1A),const Color(0xFF1D9E75),0.6,const Color(0xFF1D9E75)),
      _ACard('Flashcards','24 due',Icons.style_rounded,const Color(0xFF2A1F00),const Color(0xFFEF9F27),const Color(0xFF854F0B),const Color(0xFF1F1800),'Review',const Color(0xFF2A1F00),const Color(0xFFEF9F27),0.4,const Color(0xFFEF9F27)),
      _ACard('Exam prep','WAEC · JAMB',Icons.school_rounded,const Color(0xFF2E1A0F),const Color(0xFFD85A30),const Color(0xFF993C1D),const Color(0xFF201108),'Hot',const Color(0xFF2E1A0F),const Color(0xFFD85A30),0.25,const Color(0xFFD85A30)),
      _ACard('Camera scan','Snap a question',Icons.camera_alt_rounded,const Color(0xFF0C1E32),const Color(0xFF85B7EB),const Color(0xFF185FA5),const Color(0xFF091625),'AI',const Color(0xFF0C1E32),const Color(0xFF60A5FA),0.0,const Color(0xFF378ADD)),
      _ACard('Practice test','Full mock exam',Icons.assignment_rounded,const Color(0xFF2A1020),const Color(0xFFED93B1),const Color(0xFF993556),const Color(0xFF1E0A16),'New',const Color(0xFF2A1020),const Color(0xFFED93B1),0.0,const Color(0xFFD4537E)),
    ];

    final w2 = (MediaQuery.of(context).size.width - 48) / 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Row(children: [
            _CardWidget(card: cards[0], cardWidth: w2),
            const SizedBox(width: 10),
            _CardWidget(card: cards[1], cardWidth: w2),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _CardWidget(card: cards[2], cardWidth: w2),
            const SizedBox(width: 10),
            _CardWidget(card: cards[3], cardWidth: w2),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _CardWidget(card: cards[4], cardWidth: w2),
            const SizedBox(width: 10),
            _CardWidget(card: cards[5], cardWidth: w2),
          ]),
        ],
      ),
    );
  }
}

class _CardWidget extends StatefulWidget {
  final _ACard card;
  final double cardWidth;
  const _CardWidget({required this.card, required this.cardWidth});
  @override State<_CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<_CardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _prog;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _prog = Tween<double>(begin: 0, end: widget.card.progress).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(const Duration(milliseconds: 600), () { if (mounted) _ctrl.forward(); });
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = widget.card;
    return SizedBox(
      width: widget.cardWidth,
      height: widget.cardWidth * 0.95,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.bg,
            border: Border.all(color: c.borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 36, height: 36,
                decoration: BoxDecoration(color: c.iconBg, borderRadius: BorderRadius.circular(11)),
                child: Icon(c.icon, color: c.iconColor, size: 18)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: c.badgeBg, borderRadius: BorderRadius.circular(20)),
                child: Text(c.badge, style: AppTextStyles.caption.copyWith(color: c.badgeColor, fontSize: 9))),
            ]),
            const Spacer(),
            Text(c.name, style: AppTextStyles.titleSmall),
            Text(c.sub, style: AppTextStyles.caption.copyWith(fontSize: 10)),
            if (c.progress > 0) ...[
              const SizedBox(height: 6),
              AnimatedBuilder(animation: _prog, builder: (_, __) =>
                  ClipRRect(borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(value: _prog.value, minHeight: 3,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(c.progressColor)))),
            ],
          ]),
        ),
      ),
    );
  }
}

class _ACard {
  final String name, sub, badge;
  final IconData icon;
  final Color iconBg, iconColor, borderColor, bg, badgeBg, badgeColor, progressColor;
  final double progress;
  const _ACard(this.name, this.sub, this.icon, this.iconBg, this.iconColor, this.borderColor,
      this.bg, this.badge, this.badgeBg, this.badgeColor, this.progress, this.progressColor);
}""")

# ── STEP 4: Profile screen ────────────────────────────────────────────────────

w('lib/features/profile/presentation/pages/profile_page.dart', """
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/activity_rings_card.dart';
import '../widgets/this_week_grid.dart';
import '../widgets/streak_card_widget.dart';
import '../widgets/course_progress_widget.dart';
import '../widgets/strengths_widget.dart';
import '../widgets/learning_style_card.dart';
import '../widgets/success_prediction_card.dart';
import '../widgets/badges_scroll_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Profile', style: GoogleFonts.dmSans(
                              fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(onPressed: () {},
                                icon: const Icon(Icons.settings_outlined, color: AppColors.textTertiary, size: 22),
                                padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                            const SizedBox(width: 16),
                            _NotifIcon(),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(padding: EdgeInsets.fromLTRB(20, 12, 20, 0), child: ProfileHeaderWidget()),
                ),
                const SliverToBoxAdapter(child: ProfileStatsRow()),
                SliverToBoxAdapter(child: _Section(title: 'Study activity', linkLabel: 'See history', onLink: () {}, child: const ActivityRingsCard())),
                SliverToBoxAdapter(child: _Section(title: 'This week', child: const ThisWeekGrid())),
                SliverToBoxAdapter(child: _Section(title: 'Streak', child: const StreakCardWidget())),
                SliverToBoxAdapter(child: _Section(title: 'Course progress', linkLabel: 'All courses', onLink: () {}, child: const CourseProgressWidget())),
                SliverToBoxAdapter(child: _Section(title: 'Strengths & focus areas', child: const StrengthsWidget())),
                SliverToBoxAdapter(child: _Section(title: 'Your learning style', child: const LearningStyleCard())),
                SliverToBoxAdapter(child: _Section(
                  title: 'Success prediction',
                  trailing: Text('AI-powered', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
                  child: const SuccessPredictionCard(),
                )),
                SliverToBoxAdapter(child: _Section(title: 'Badges', linkLabel: 'See all', onLink: () {}, child: const BadgesScrollWidget())),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String? linkLabel;
  final VoidCallback? onLink;
  final Widget? trailing;
  final Widget child;
  const _Section({required this.title, this.linkLabel, this.onLink, this.trailing, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title.toUpperCase(), style: GoogleFonts.dmSans(
              fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textTertiary, letterSpacing: 0.5)),
          if (linkLabel != null)
            GestureDetector(onTap: onLink,
                child: Text(linkLabel!, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.accent))),
          if (trailing != null) trailing!,
        ]),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }
}

class _NotifIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      const Icon(Icons.notifications_outlined, color: AppColors.textTertiary, size: 22),
      Positioned(top: -1, right: -1,
          child: Container(width: 7, height: 7,
              decoration: BoxDecoration(color: const Color(0xFFE24B4A), shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 1.5)))),
    ]);
  }
}
""".lstrip())

w('lib/features/profile/presentation/widgets/profile_header_widget.dart', """
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileHeaderWidget extends StatefulWidget {
  const ProfileHeaderWidget({super.key});
  @override
  State<ProfileHeaderWidget> createState() => _State();
}

class _State extends State<ProfileHeaderWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 300), () { if (mounted) _ctrl.forward(); });
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(width: 74, height: 74, child: Stack(alignment: Alignment.center, children: [
        AnimatedBuilder(animation: _anim,
            builder: (_, __) => CustomPaint(size: const Size(74, 74),
                painter: _ArcPainter(progress: _anim.value * 0.65))),
        Container(width: 58, height: 58,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1E1D3A)),
            child: Center(child: Text('AO', style: GoogleFonts.dmSans(
                fontSize: 18, fontWeight: FontWeight.w500, color: const Color(0xFFAFA9EC), letterSpacing: 1)))),
        Positioned(bottom: 0, right: 0, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: const Color(0xFF2A1F00), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBA7517), width: 1.5)),
          child: Text('Lvl 12', style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w500, color: const Color(0xFFEF9F27))),
        )),
      ])),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Adaeze Okonkwo', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text('University · Computer Science', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFF1E1D3A), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF534AB7), width: 0.5)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.workspace_premium_outlined, size: 11, color: Color(0xFFAFA9EC)),
            const SizedBox(width: 5),
            Text('Rising Scholar', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFFAFA9EC))),
          ]),
        ),
      ])),
    ]);
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  _ArcPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, 34, Paint()..style = PaintingStyle.stroke..strokeWidth = 4..color = const Color(0xFF222222));
    if (progress <= 0) return;
    canvas.drawArc(Rect.fromCircle(center: c, radius: 34), -math.pi / 2, 2 * math.pi * progress, false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round..color = const Color(0xFF534AB7));
  }
  @override
  bool shouldRepaint(_ArcPainter o) => o.progress != progress;
}
""".lstrip())

w('lib/features/profile/presentation/widgets/profile_stats_row.dart', """
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileStatsRow extends StatefulWidget {
  const ProfileStatsRow({super.key});
  @override
  State<ProfileStatsRow> createState() => _State();
}

class _State extends State<ProfileStatsRow> {
  double _streak = 0, _friends = 0, _tasks = 0;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), _animate);
  }
  void _animate() {
    if (!mounted) return;
    const dur = 900;
    final start = DateTime.now();
    void tick() {
      if (!mounted) return;
      final t = DateTime.now().difference(start).inMilliseconds / dur;
      final p = t >= 1.0 ? 1.0 : 1 - _cube(1 - t);
      setState(() { _streak = 14 * p; _friends = 247 * p; _tasks = 183 * p; });
      if (t < 1.0) Future.delayed(const Duration(milliseconds: 16), tick);
    }
    tick();
  }
  double _cube(double x) => x * x * x;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: const BoxDecoration(border: Border(
          top: BorderSide(color: Color(0xFF222222), width: 0.5),
          bottom: BorderSide(color: Color(0xFF222222), width: 0.5))),
      child: Row(children: [
        _Cell(value: _streak.round().toString(), label: 'Day streak', valueColor: const Color(0xFFD85A30)),
        _Cell(value: _friends.round().toString(), label: 'Friends'),
        _Cell(value: _tasks.round().toString(), label: 'Tasks done', valueColor: const Color(0xFF1D9E75), isLast: true),
      ]),
    );
  }
}

class _Cell extends StatelessWidget {
  final String value, label;
  final Color? valueColor;
  final bool isLast;
  const _Cell({required this.value, required this.label, this.valueColor, this.isLast = false});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            border: !isLast ? const Border(right: BorderSide(color: Color(0xFF222222), width: 0.5)) : null),
        child: Column(children: [
          Text(value, style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary, height: 1.1)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
        ]),
      ),
    );
  }
}
""".lstrip())

w('lib/features/profile/presentation/widgets/activity_rings_card.dart', """
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class ActivityRingsCard extends StatefulWidget {
  const ActivityRingsCard({super.key});
  @override
  State<ActivityRingsCard> createState() => _State();
}

class _State extends State<ActivityRingsCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  double _pct = 0;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _anim.addListener(() { setState(() { _pct = _anim.value * 78; }); });
    Future.delayed(const Duration(milliseconds: 400), () { if (mounted) _ctrl.forward(); });
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1A18), borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        SizedBox(width: 110, height: 110, child: Stack(alignment: Alignment.center, children: [
          AnimatedBuilder(animation: _anim,
              builder: (_, __) => CustomPaint(size: const Size(110, 110),
                  painter: _RingsPainter(r1: _anim.value * 0.85, r2: _anim.value * 0.80, r3: _anim.value * 0.82))),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${_pct.round()}%', style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1)),
            Text('today', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
          ]),
        ])),
        const SizedBox(width: 16),
        Expanded(child: AnimatedBuilder(animation: _anim, builder: (_, __) => Column(children: [
          _LegRow(color: const Color(0xFF534AB7), name: 'Study time', value: '3.4 / 4h goal', p: _anim.value * 0.85),
          const SizedBox(height: 8),
          _LegRow(color: const Color(0xFF1D9E75), name: 'Tasks done', value: '8 / 10 today', p: _anim.value * 0.80),
          const SizedBox(height: 8),
          _LegRow(color: const Color(0xFFBA7517), name: 'Quiz accuracy', value: '82% · top 15%', p: _anim.value * 0.82),
        ]))),
      ]),
    );
  }
}

class _LegRow extends StatelessWidget {
  final Color color; final String name, value; final double p;
  const _LegRow({required this.color, required this.name, required this.value, required this.p});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFFCCCCCC))),
        Text(value, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
        const SizedBox(height: 3),
        ClipRRect(borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(value: p, minHeight: 3,
                backgroundColor: const Color(0xFF222222), valueColor: AlwaysStoppedAnimation(color))),
      ])),
    ]);
  }
}

class _RingsPainter extends CustomPainter {
  final double r1, r2, r3;
  _RingsPainter({required this.r1, required this.r2, required this.r3});
  void _ring(Canvas c, Size s, double radius, double sw, Color track, Color fill, double p) {
    final center = Offset(s.width / 2, s.height / 2);
    c.drawCircle(center, radius, Paint()..style = PaintingStyle.stroke..strokeWidth = sw..color = track);
    if (p > 0) c.drawArc(Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, 2 * math.pi * p, false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round..color = fill);
  }
  @override
  void paint(Canvas c, Size s) {
    _ring(c, s, 46, 9, const Color(0xFF1F1E1E), const Color(0xFF534AB7), r1);
    _ring(c, s, 34, 7, const Color(0xFF1F1E1E), const Color(0xFF1D9E75), r2);
    _ring(c, s, 23, 6, const Color(0xFF1F1E1E), const Color(0xFFBA7517), r3);
  }
  @override
  bool shouldRepaint(_RingsPainter o) => o.r1 != r1 || o.r2 != r2 || o.r3 != r3;
}
""".lstrip())

w('lib/features/profile/presentation/widgets/this_week_grid.dart', """
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class ThisWeekGrid extends StatefulWidget {
  const ThisWeekGrid({super.key});
  @override
  State<ThisWeekGrid> createState() => _State();
}

class _State extends State<ThisWeekGrid> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _ctrl.forward(); });
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _anim, builder: (_, __) {
      return Column(children: [
        Row(children: [
          Expanded(child: _Card(label: 'Efficiency', labelIcon: Icons.trending_up,
              labelIconColor: const Color(0xFF1D9E75),
              value: '${(_anim.value * 78).round()}%', valueColor: const Color(0xFF534AB7),
              sub: 'up 8% vs last week',
              bars: const [55, 62, 70, 65, 74, 78, 71], barColor: const Color(0xFF534AB7), barP: _anim.value)),
          const SizedBox(width: 8),
          Expanded(child: _Card(label: 'Global rank', labelIcon: Icons.public,
              labelIconColor: const Color(0xFFBA7517),
              value: '#38', valueColor: const Color(0xFFBA7517),
              sub: 'Top 0.4% worldwide',
              bars: const [90, 80, 72, 68, 60, 55, 48], barColor: const Color(0xFFBA7517), barP: _anim.value)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _Card(label: 'Points earned',
              value: '${(_anim.value * 2840).round()}', valueColor: AppColors.textPrimary,
              sub: '+420 this week')),
          const SizedBox(width: 8),
          Expanded(child: _Card(label: 'Peak focus',
              value: '8-11am', valueColor: const Color(0xFF1D9E75),
              valueFontSize: 16, sub: 'Best retention window')),
        ]),
      ]);
    });
  }
}

class _Card extends StatelessWidget {
  final String label, value, sub;
  final IconData? labelIcon;
  final Color? labelIconColor;
  final Color valueColor;
  final double valueFontSize;
  final List<int>? bars;
  final Color? barColor;
  final double barP;
  const _Card({required this.label, required this.value, required this.valueColor, required this.sub,
      this.labelIcon, this.labelIconColor, this.valueFontSize = 24, this.bars, this.barColor, this.barP = 1});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: const Color(0xFF1A1A18), borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
          if (labelIcon != null) Icon(labelIcon, size: 11, color: labelIconColor),
        ]),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.dmSans(fontSize: valueFontSize, fontWeight: FontWeight.w500, color: valueColor, height: 1.1)),
        Text(sub, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
        if (bars != null) ...[
          const SizedBox(height: 8),
          _MiniBars(values: bars!, color: barColor!, progress: barP),
        ],
      ]),
    );
  }
}

class _MiniBars extends StatelessWidget {
  final List<int> values; final Color color; final double progress;
  const _MiniBars({required this.values, required this.color, required this.progress});
  @override
  Widget build(BuildContext context) {
    final mx = values.reduce((a, b) => a > b ? a : b);
    return SizedBox(height: 28, child: Row(crossAxisAlignment: CrossAxisAlignment.end,
        children: values.map((v) {
          final h = (v / mx) * 28 * progress;
          return Expanded(child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            height: h < 3 ? 3 : h,
            decoration: BoxDecoration(color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
          ));
        }).toList()));
  }
}
""".lstrip())

w('lib/features/profile/presentation/widgets/streak_card_widget.dart', """
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class StreakCardWidget extends StatefulWidget {
  const StreakCardWidget({super.key});
  @override
  State<StreakCardWidget> createState() => _State();
}

class _State extends State<StreakCardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _rotate;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.14).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _rotate = Tween<double>(begin: -0.07, end: 0.07).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: const Color(0xFF1A1A18), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        AnimatedBuilder(animation: _ctrl,
            builder: (_, child) => Transform.rotate(angle: _rotate.value,
                child: Transform.scale(scale: _scale.value, child: child)),
            child: const Text('🔥', style: TextStyle(fontSize: 32))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('14-day streak!', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w500, color: const Color(0xFFD85A30))),
          Text("You're in the top 5% for consistency", style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
          const SizedBox(height: 6),
          Row(children: [
            _Dot('M', _S.done), const SizedBox(width: 5),
            _Dot('T', _S.done), const SizedBox(width: 5),
            _Dot('W', _S.done), const SizedBox(width: 5),
            _Dot('T', _S.done), const SizedBox(width: 5),
            _Dot('F', _S.done), const SizedBox(width: 5),
            _Dot('S', _S.today), const SizedBox(width: 5),
            _Dot('S', _S.next),
          ]),
        ])),
        Column(children: [
          Text('+50 pts', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFFEF9F27))),
          Text('daily bonus', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
        ]),
      ]),
    );
  }
}

enum _S { done, today, next }

class _Dot extends StatelessWidget {
  final String label; final _S state;
  const _Dot(this.label, this.state);
  @override
  Widget build(BuildContext context) {
    Color bg, tc, bc; double bw;
    switch (state) {
      case _S.done:  bg = const Color(0xFF1F2E1A); tc = const Color(0xFF3B6D11); bc = const Color(0xFF3B6D11); bw = 1; break;
      case _S.today: bg = const Color(0xFF2E1A0F); tc = const Color(0xFFD85A30); bc = const Color(0xFFD85A30); bw = 1.5; break;
      case _S.next:  bg = const Color(0xFF1C1C1A); tc = const Color(0xFF444444); bc = Colors.transparent; bw = 0; break;
    }
    return Container(width: 22, height: 22,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: Border.all(color: bc, width: bw)),
        child: Center(child: Text(label, style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w500, color: tc))));
  }
}
""".lstrip())

w('lib/features/profile/presentation/widgets/course_progress_widget.dart', """
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class CourseProgressWidget extends StatefulWidget {
  const CourseProgressWidget({super.key});
  @override
  State<CourseProgressWidget> createState() => _State();
}

class _State extends State<CourseProgressWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _ctrl.forward(); });
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _anim, builder: (_, __) => Column(children: [
      _CourseCard(emoji: '💻', emojiBg: const Color(0xFF1E1D3A),
          title: 'Data Structures & Algorithms', sub: '12 of 18 modules · Exam in 21 days',
          progress: _anim.value * 0.67, pColor: const Color(0xFF534AB7), pLabel: '67%',
          sLabel: 'On track', sBg: const Color(0xFF1E2E1A), sColor: const Color(0xFF3B6D11),
          nLabel: 'Next: Binary Trees'),
      const SizedBox(height: 8),
      _CourseCard(emoji: '🌍', emojiBg: const Color(0xFF0D2219),
          title: 'IELTS Preparation', sub: 'Reading · Writing · Listening · Speaking',
          progress: _anim.value * 0.48, pColor: const Color(0xFF1D9E75), pLabel: '48%',
          sLabel: 'Needs focus', sBg: const Color(0xFF2E1A0F), sColor: const Color(0xFFD85A30),
          nLabel: 'Next: Writing Task 2'),
    ]));
  }
}

class _CourseCard extends StatelessWidget {
  final String emoji, title, sub, pLabel, sLabel, nLabel;
  final Color emojiBg, pColor, sBg, sColor;
  final double progress;
  const _CourseCard({required this.emoji, required this.emojiBg, required this.title,
      required this.sub, required this.progress, required this.pColor, required this.pLabel,
      required this.sLabel, required this.sBg, required this.sColor, required this.nLabel});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1A1A18), borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Row(children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(color: emojiBg, borderRadius: BorderRadius.circular(9)),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 15)))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            Text(sub, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
          ])),
          Text(pLabel, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: pColor)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(value: progress, minHeight: 4,
                backgroundColor: const Color(0xFF222222), valueColor: AlwaysStoppedAnimation(pColor))),
        const SizedBox(height: 7),
        Row(children: [
          _Tag(label: sLabel, bg: sBg, color: sColor),
          const SizedBox(width: 5),
          _Tag(label: nLabel, bg: const Color(0xFF1E1D3A), color: const Color(0xFFAFA9EC)),
        ]),
      ]),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label; final Color bg, color;
  const _Tag({required this.label, required this.bg, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500, color: color)));
  }
}
""".lstrip())

w('lib/features/profile/presentation/widgets/strengths_widget.dart', """
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class StrengthsWidget extends StatelessWidget {
  const StrengthsWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: _Card(titleLabel: 'Strengths', titleIcon: Icons.trending_up,
          titleColor: const Color(0xFF1D9E75), items: const [
            _Item('Problem solving', Color(0xFF0D2219), Icons.check, Color(0xFF1D9E75)),
            _Item('Reading speed',   Color(0xFF0D2219), Icons.check, Color(0xFF1D9E75)),
            _Item('Memory recall',   Color(0xFF0D2219), Icons.check, Color(0xFF1D9E75)),
          ])),
      const SizedBox(width: 8),
      Expanded(child: _Card(titleLabel: 'Work on these', titleIcon: Icons.warning_amber_rounded,
          titleColor: const Color(0xFFD85A30), items: const [
            _Item('Essay writing',   Color(0xFF2E1A0F), Icons.arrow_upward, Color(0xFFD85A30)),
            _Item('Time management', Color(0xFF2E1A0F), Icons.arrow_upward, Color(0xFFD85A30)),
            _Item('Speaking drills', Color(0xFF2A1F00), Icons.remove,       Color(0xFFEF9F27)),
          ])),
    ]);
  }
}

class _Item {
  final String label; final Color bg, iconColor; final IconData icon;
  const _Item(this.label, this.bg, this.icon, this.iconColor);
}

class _Card extends StatelessWidget {
  final String titleLabel; final IconData titleIcon; final Color titleColor; final List<_Item> items;
  const _Card({required this.titleLabel, required this.titleIcon, required this.titleColor, required this.items});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF1A1A18), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(titleIcon, size: 12, color: titleColor), const SizedBox(width: 5),
            Text(titleLabel, style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500, color: titleColor)),
          ]),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 4),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(color: item.bg, borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Icon(item.icon, size: 11, color: item.iconColor), const SizedBox(width: 5),
                    Expanded(child: Text(item.label,
                        style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFFCCCCCC)),
                        overflow: TextOverflow.ellipsis)),
                  ])))),
        ]));
  }
}
""".lstrip())

w('lib/features/profile/presentation/widgets/learning_style_card.dart', """
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class LearningStyleCard extends StatelessWidget {
  const LearningStyleCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: const Color(0xFF1A1A18), borderRadius: BorderRadius.circular(16)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFF1E1D3A), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.lightbulb_outline, size: 18, color: Color(0xFF7F77DD))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Visual + spaced repetition learner',
              style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('You retain 40% more with diagrams and concept maps. Study in focused 45-min blocks with 15-min breaks. Review on days 1, 3 and 7 after learning for best retention.',
              style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary, height: 1.6)),
        ])),
      ]),
    );
  }
}
""".lstrip())

w('lib/features/profile/presentation/widgets/success_prediction_card.dart', """
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class SuccessPredictionCard extends StatefulWidget {
  const SuccessPredictionCard({super.key});
  @override
  State<SuccessPredictionCard> createState() => _State();
}

class _State extends State<SuccessPredictionCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  double _score = 0;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _anim.addListener(() { setState(() { _score = _anim.value * 7.2; }); });
    Future.delayed(const Duration(milliseconds: 600), () { if (mounted) _ctrl.forward(); });
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF1A1A18), borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('IELTS Academic', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            Text('Target: Aug 15, 2026', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('High confidence', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500, color: const Color(0xFF1D9E75))),
            Text('Based on 42 sessions', style: GoogleFonts.dmSans(fontSize: 8, color: AppColors.textTertiary)),
          ]),
        ]),
        const SizedBox(height: 10),
        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          Text(_score.toStringAsFixed(1), style: GoogleFonts.dmSans(fontSize: 40, fontWeight: FontWeight.w500, color: const Color(0xFF534AB7), height: 1)),
          Text('/9.0', style: GoogleFonts.dmSans(fontSize: 18, color: AppColors.textTertiary)),
        ]),
        const SizedBox(height: 4),
        Text('up +0.5 band since last month', style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFF1D9E75))),
        const SizedBox(height: 12),
        AnimatedBuilder(animation: _anim, builder: (_, __) => Column(children: [
          _Bar(label: 'Reading',   value: '8.0', progress: _anim.value * 0.88, color: const Color(0xFF1D9E75)),
          const SizedBox(height: 6),
          _Bar(label: 'Listening', value: '7.5', progress: _anim.value * 0.82, color: const Color(0xFF534AB7), vc: const Color(0xFF7F77DD)),
          const SizedBox(height: 6),
          _Bar(label: 'Writing',   value: '6.0', progress: _anim.value * 0.66, color: const Color(0xFFBA7517), vc: const Color(0xFFEF9F27)),
          const SizedBox(height: 6),
          _Bar(label: 'Speaking',  value: '6.5', progress: _anim.value * 0.72, color: const Color(0xFFD85A30)),
        ])),
        const SizedBox(height: 10),
        Container(padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF222222), width: 0.5))),
            child: Row(children: [
              const Icon(Icons.auto_awesome, size: 11, color: Color(0xFF7F77DD)),
              const SizedBox(width: 4),
              Expanded(child: RichText(text: TextSpan(
                  style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary, height: 1.6),
                  children: const [
                    TextSpan(text: 'Adding 20 min/day on Writing could lift your band to '),
                    TextSpan(text: '7.5', style: TextStyle(color: Color(0xFF534AB7), fontWeight: FontWeight.w500)),
                    TextSpan(text: ' by exam day.'),
                  ]))),
            ])),
      ]),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label, value; final double progress; final Color color; final Color? vc;
  const _Bar({required this.label, required this.value, required this.progress, required this.color, this.vc});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 68, child: Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary))),
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(value: progress, minHeight: 4,
              backgroundColor: const Color(0xFF2A2A28), valueColor: AlwaysStoppedAnimation(color)))),
      const SizedBox(width: 8),
      SizedBox(width: 28, child: Text(value, textAlign: TextAlign.right,
          style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500, color: vc ?? color))),
    ]);
  }
}
""".lstrip())

w('lib/features/profile/presentation/widgets/badges_scroll_widget.dart', """
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class BadgesScrollWidget extends StatelessWidget {
  const BadgesScrollWidget({super.key});
  static const _badges = [
    _B('🏆', 'Top 50 Global', Color(0xFF2A1F00), true),
    _B('🔥', '14-Day Streak', Color(0xFF2E1A0F), true),
    _B('⚡', 'Speed Solver',  Color(0xFF1E1D3A), true),
    _B('🎯', 'Accuracy King', Color(0xFF0D2219), true),
    _B('🌟', 'Scholar Elite', Color(0xFF1C1C1A), false),
    _B('💎', 'Diamond Rank',  Color(0xFF1C1C1A), false),
  ];
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 80, child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _badges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _Tile(badge: _badges[i])));
  }
}

class _B {
  final String emoji, label; final Color bg; final bool earned;
  const _B(this.emoji, this.label, this.bg, this.earned);
}

class _Tile extends StatefulWidget {
  final _B badge;
  const _Tile({required this.badge});
  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.badge.earned) return;
        HapticFeedback.lightImpact();
        _ctrl.forward().then((_) => _ctrl.reverse());
      },
      child: ScaleTransition(scale: _scale, child: SizedBox(width: 52, child: Column(children: [
        Container(width: 50, height: 50,
            decoration: BoxDecoration(color: widget.badge.bg, borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: widget.badge.earned ? const Color(0xFFBA7517) : Colors.transparent, width: 1.5)),
            child: Center(child: Opacity(opacity: widget.badge.earned ? 1.0 : 0.3,
                child: Text(widget.badge.emoji, style: const TextStyle(fontSize: 22))))),
        const SizedBox(height: 5),
        Text(widget.badge.label, textAlign: TextAlign.center, maxLines: 2,
            style: GoogleFonts.dmSans(fontSize: 8, color: AppColors.textTertiary, height: 1.3)),
      ]))),
    );
  }
}
""".lstrip())
w('lib/features/home/presentation/pages/home_page.dart', """
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/activity_grid.dart';
import '../widgets/live_rooms_strip.dart';
import '../widgets/leaderboard_strip.dart';
import '../widgets/continue_button.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _activeIndex,
              children: const [
                _HomeContent(),
                _PlaceholderPage(label: 'Study'),
                _PlaceholderPage(label: 'Compete'),
                _PlaceholderPage(label: 'Discover'),
                ProfilePage(),
              ],
            ),
          ),
          _BottomNav(
            activeIndex: _activeIndex,
            onTap: (i) => setState(() => _activeIndex = i),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeTopBar(streakCount: 14, xpCount: 2840),
            const _GreetingBlock(name: 'Adaeze'),
            const DailyGoalCard(percent: 0.68, xpToday: 120, xpTotal: 2840),
            const SizedBox(height: AppSpacing.lg),
            _SectionHeader(title: 'Continue learning', linkText: 'See all', onTap: () {}),
            const SizedBox(height: AppSpacing.md),
            const ActivityGrid(),
            const SizedBox(height: AppSpacing.lg),
            _SectionHeader(title: 'Live study rooms', linkText: 'Browse', onTap: () {}),
            const SizedBox(height: AppSpacing.md),
            const LiveRoomsStrip(),
            const SizedBox(height: AppSpacing.lg),
            _SectionHeader(title: 'Leaderboard', linkText: 'Full board', onTap: () {}),
            const SizedBox(height: AppSpacing.md),
            const LeaderboardStrip(),
            const SizedBox(height: AppSpacing.xxl),
            const ContinueButton(),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String label;
  const _PlaceholderPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: Text(label,
            style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textTertiary)),
      ),
    );
  }
}

class _GreetingBlock extends StatelessWidget {
  final String name;
  const _GreetingBlock({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 2, AppSpacing.lg, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Good morning,',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary)),
          Text(name, style: AppTextStyles.headlineLarge),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title, linkText;
  final VoidCallback onTap;
  const _SectionHeader({required this.title, required this.linkText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.titleLarge),
          GestureDetector(onTap: onTap,
              child: Text(linkText,
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.accentLight))),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.activeIndex, required this.onTap});

  static const _icons = [
    Icons.home_rounded,
    Icons.groups_rounded,
    Icons.emoji_events_rounded,
    Icons.explore_rounded,
    Icons.person_rounded,
  ];

  static const _labels = ['Home', 'Study', 'Compete', 'Discover', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      padding: EdgeInsets.only(top: 10, bottom: MediaQuery.of(context).padding.bottom + 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(5, (i) {
          final active = i == activeIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(_icons[i], size: 22,
                  color: active ? AppColors.accentLight : AppColors.textTertiary),
              const SizedBox(height: 3),
              Text(_labels[i], style: AppTextStyles.labelSmall.copyWith(
                  color: active ? AppColors.accentLight : AppColors.textTertiary)),
              if (active)
                Container(margin: const EdgeInsets.only(top: 2),
                    width: 4, height: 4,
                    decoration: const BoxDecoration(
                        color: AppColors.accentLight, shape: BoxShape.circle)),
            ]),
          );
        }),
      ),
    );
  }
}
""".lstrip())
print('\nDone! All files written.')
print('Now run: flutter run')