import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class LeaderboardStrip extends StatefulWidget {
  const LeaderboardStrip({super.key});
  @override State<LeaderboardStrip> createState() => _LeaderboardStripState();
}

class _LeaderboardStripState extends State<LeaderboardStrip> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bar;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));
    _bar = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    Future.delayed(const Duration(milliseconds: 700), () { if (mounted) _ctrl.forward(); });
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        _Row('1','OK','Olumide K.',4820,1.0,const Color(0xFFEF9F27),isGold: true, bar: _bar),
        const SizedBox(height: AppSpacing.sm),
        _Row('#2','ZN','Zara N.',3960,0.82,AppColors.textSecondary, bar: _bar),
        const SizedBox(height: AppSpacing.sm),
        _Row('#38','AO','You · Adaeze',2840,0.58,AppColors.accentLight,isYou: true, bar: _bar),
        const SizedBox(height: AppSpacing.sm),
        _Row('#39','TF','Tunde F.',2790,0.56,AppColors.textSecondary, bar: _bar),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final String rank, initials, name;
  final int pts;
  final double barW;
  final Color rankColor;
  final bool isGold, isYou;
  final Animation<double> bar;
  const _Row(this.rank, this.initials, this.name, this.pts, this.barW, this.rankColor,
      {this.isGold=false, this.isYou=false, required this.bar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: isYou ? const EdgeInsets.symmetric(horizontal: 6, vertical: 4) : EdgeInsets.zero,
      decoration: isYou ? BoxDecoration(color: AppColors.accentSurface, borderRadius: BorderRadius.circular(10)) : null,
      child: Row(children: [
        SizedBox(width: 24, child: Text(rank, style: AppTextStyles.labelMedium.copyWith(color: rankColor), textAlign: TextAlign.center)),
        const SizedBox(width: AppSpacing.sm),
        Container(width: 28, height: 28,
          decoration: BoxDecoration(
            color: isGold ? const Color(0xFF2A1F00) : isYou ? AppColors.accentSurface : AppColors.surfaceVariant,
            shape: BoxShape.circle),
          child: Center(child: Text(initials, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: rankColor)))),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(name, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary, fontSize: 11))),
        AnimatedBuilder(animation: bar, builder: (_, _) =>
            SizedBox(width: 60, height: 4,
              child: ClipRRect(borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(value: bar.value * barW, backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(isGold ? const Color(0xFFEF9F27) : AppColors.accent))))),
        const SizedBox(width: AppSpacing.sm),
        Text(pts.toString(), style: AppTextStyles.labelMedium.copyWith(
            color: isYou ? AppColors.accentLight : AppColors.textSecondary)),
      ]),
    );
  }
}