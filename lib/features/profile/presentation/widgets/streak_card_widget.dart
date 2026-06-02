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
