import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileStatsRow extends StatefulWidget {
  const ProfileStatsRow({super.key});
  @override
  State<ProfileStatsRow> createState() => _State();
}

class _State extends State<ProfileStatsRow> {
  double _streak = 0, _friends = 0, _tasks = 0;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), _animate);
  }
  void _animate() {
    if (!mounted) return;
    const dur = 900;
    final start = DateTime.now();
    void tick() {
      if (!mounted) return;
      final t = DateTime.now().difference(start).inMilliseconds / dur;
      final p = t >= 1.0 ? 1.0 : 1 - _cube(1 - t);
      setState(() { _streak = 14 * p; _friends = 247 * p; _tasks = 183 * p; });
      if (t < 1.0) Future.delayed(const Duration(milliseconds: 16), tick);
    }
    tick();
  }
  double _cube(double x) => x * x * x;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: const BoxDecoration(border: Border(
          top: BorderSide(color: Color(0xFF222222), width: 0.5),
          bottom: BorderSide(color: Color(0xFF222222), width: 0.5))),
      child: Row(children: [
        _Cell(value: _streak.round().toString(), label: 'Day streak', valueColor: const Color(0xFFD85A30)),
        _Cell(value: _friends.round().toString(), label: 'Friends'),
        _Cell(value: _tasks.round().toString(), label: 'Tasks done', valueColor: const Color(0xFF1D9E75), isLast: true),
      ]),
    );
  }
}

class _Cell extends StatelessWidget {
  final String value, label;
  final Color? valueColor;
  final bool isLast;
  const _Cell({required this.value, required this.label, this.valueColor, this.isLast = false});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            border: !isLast ? const Border(right: BorderSide(color: Color(0xFF222222), width: 0.5)) : null),
        child: Column(children: [
          Text(value, style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary, height: 1.1)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textTertiary)),
        ]),
      ),
    );
  }
}
