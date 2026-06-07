import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class ThisWeekGrid extends StatefulWidget {
  final int xp;
  final int rank;
  const ThisWeekGrid({super.key, this.xp = 0, this.rank = 0});
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
    final xp = widget.xp;
    final rank = widget.rank;
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
              value: rank > 0 ? '#$rank' : '—', valueColor: const Color(0xFFBA7517),
              sub: 'Top 0.4% worldwide',
              bars: const [90, 80, 72, 68, 60, 55, 48], barColor: const Color(0xFFBA7517), barP: _anim.value)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _Card(label: 'Points earned',
              value: '${(_anim.value * xp).round()}', valueColor: AppColors.textPrimary,
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