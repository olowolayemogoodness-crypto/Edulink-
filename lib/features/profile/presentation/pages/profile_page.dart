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
import 'package:go_router/go_router.dart';
import '../../../../core/services/user_service.dart';

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
    return StreamBuilder<Map<String, dynamic>?>(
      stream: UserService.profileStream(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
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
                            IconButton(onPressed: () => context.push('/settings'),
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
                SliverToBoxAdapter(child: ProfileStatsRow(
                  streak: (profile?['streak'] as int?) ?? 0,
                  friends: (profile?['friends'] as int?) ?? 0,
                  tasksDone: (profile?['tasksDone'] as int?) ?? 0,
                )),
                SliverToBoxAdapter(child: _Section(title: 'Study activity', linkLabel: 'See history', onLink: () {}, child: const ActivityRingsCard())),
                SliverToBoxAdapter(child: _Section(title: 'This week', child: ThisWeekGrid(
                  xp: (profile?['xp'] as int?) ?? 0,
                  rank: (profile?['rank'] as int?) ?? 0,
                ))),
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
      },
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
