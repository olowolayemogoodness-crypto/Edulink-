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
              builder: (_, _) => CustomPaint(size: const Size(110, 110),
                  painter: _RingsPainter(r1: _anim.value * 0.85, r2: _anim.value * 0.80, r3: _anim.value * 0.82))),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${_pct.round()}%', style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1)),
            Text('today', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
          ]),
        ])),
        const SizedBox(width: 16),
        Expanded(child: AnimatedBuilder(animation: _anim, builder: (_, _) => Column(children: [
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
    if (p > 0) { c.drawArc(Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, 2 * math.pi * p, false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round..color = fill); }
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
