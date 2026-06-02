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
        separatorBuilder: (_, _) => const SizedBox(width: 10),
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
