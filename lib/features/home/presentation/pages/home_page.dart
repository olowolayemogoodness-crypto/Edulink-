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
