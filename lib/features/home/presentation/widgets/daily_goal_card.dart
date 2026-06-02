import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class DailyGoalCard extends StatefulWidget {
  final double percent; final int xpToday; final int xpTotal;
  const DailyGoalCard({super.key, required this.percent, required this.xpToday, required this.xpTotal});
  @override State<DailyGoalCard> createState() => _DailyGoalCardState();
}

class _DailyGoalCardState extends State<DailyGoalCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progAnim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _progAnim = Tween<double>(begin: 0, end: widget.percent).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(const Duration(milliseconds: 400), () { if (mounted) _ctrl.forward(); });
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Daily goal', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
          AnimatedBuilder(animation: _progAnim, builder: (_, _) =>
              Text('${(_progAnim.value * 100).round()}%',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentLight))),
        ]),
        const SizedBox(height: AppSpacing.sm),
        AnimatedBuilder(animation: _progAnim, builder: (_, _) =>
            ClipRRect(borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: _progAnim.value, minHeight: 10,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent)))),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          Expanded(child: _StatCell(value: widget.xpToday.toString(), label: 'XP today', color: AppColors.accentLight)),
          Container(width: 0.5, height: 36, color: AppColors.border),
          Expanded(child: _StatCell(value: widget.xpTotal.toString(), label: 'Total XP', color: AppColors.xp)),
          Container(width: 0.5, height: 36, color: AppColors.border),
          const Expanded(child: _StatCell(value: '#38', label: 'Rank', color: AppColors.gold)),
        ]),
      ]),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value; final String label; final Color color;
  const _StatCell({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: AppTextStyles.headlineSmall.copyWith(color: color)),
      const SizedBox(height: 2),
      Text(label, style: AppTextStyles.caption),
    ]);
  }
}