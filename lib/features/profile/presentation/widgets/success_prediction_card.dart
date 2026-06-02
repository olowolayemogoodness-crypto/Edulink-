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
        AnimatedBuilder(animation: _anim, builder: (_, _) => Column(children: [
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
