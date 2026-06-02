import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class LiveRoomsStrip extends StatefulWidget {
  const LiveRoomsStrip({super.key});
  @override State<LiveRoomsStrip> createState() => _LiveRoomsStripState();
}

class _LiveRoomsStripState extends State<LiveRoomsStrip> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }
  @override void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Row(children: [
          AnimatedBuilder(animation: _pulse, builder: (_, _) =>
              Container(width: 7, height: 7,
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.4 + 0.6 * _pulse.value), shape: BoxShape.circle))),
          const SizedBox(width: 5),
          Text('Live now', style: AppTextStyles.labelMedium.copyWith(color: AppColors.error, fontSize: 11)),
          const Spacer(),
          Text('3 rooms active', style: AppTextStyles.caption),
        ]),
        const SizedBox(height: AppSpacing.md),
        _RoomRow(emoji: '📐', name: 'WAEC Mathematics revision', sub: '14 students · Algebra & Trig',
          avatarColors: [AppColors.accentSurface, const Color(0xFF0D2219), const Color(0xFF2A1F00)],
          avatarLabels: ['AO','TF','+11'], actionLabel: 'Return →', actionColor: AppColors.success),
        const SizedBox(height: AppSpacing.sm),
        Container(height: 0.5, color: AppColors.border),
        const SizedBox(height: AppSpacing.sm),
        _RoomRow(emoji: '🎙️', name: 'IELTS Speaking drills', sub: '7 students · recording on',
          avatarColors: [const Color(0xFF0C1E32), AppColors.accentSurface, const Color(0xFF2A1020)],
          avatarLabels: ['ZN','AF','+5'], actionLabel: 'Join →', actionColor: AppColors.accentLight),
      ]),
    );
  }
}

class _RoomRow extends StatelessWidget {
  final String emoji, name, sub, actionLabel;
  final List<Color> avatarColors;
  final List<String> avatarLabels;
  final Color actionColor;
  const _RoomRow({required this.emoji, required this.name, required this.sub,
    required this.avatarColors, required this.avatarLabels, required this.actionLabel, required this.actionColor});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 52, height: 22,
        child: Stack(children: List.generate(avatarColors.length, (i) =>
            Positioned(left: i * 14.0,
              child: Container(width: 22, height: 22,
                decoration: BoxDecoration(color: avatarColors[i], shape: BoxShape.circle,
                  border: Border.all(color: AppColors.card, width: 1.5)),
                child: Center(child: Text(avatarLabels[i],
                    style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w500, color: Colors.white)))))))),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary, fontSize: 11)),
        Text(sub, style: AppTextStyles.caption),
      ])),
      Text(actionLabel, style: AppTextStyles.labelMedium.copyWith(color: actionColor, fontSize: 11)),
    ]);
  }
}