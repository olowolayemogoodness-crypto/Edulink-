import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/services/user_service.dart';

class ProfileHeaderWidget extends StatefulWidget {
  const ProfileHeaderWidget({super.key});
  @override
  State<ProfileHeaderWidget> createState() => _State();
}

class _State extends State<ProfileHeaderWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 300), () { if (mounted) _ctrl.forward(); });
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(width: 74, height: 74, child: Stack(alignment: Alignment.center, children: [
        AnimatedBuilder(animation: _anim,
            builder: (_, _) => CustomPaint(size: const Size(74, 74),
                painter: _ArcPainter(progress: _anim.value * 0.65))),
        Container(width: 58, height: 58,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1E1D3A)),
            child: Center(child: Builder(builder: (ctx) {
              final state = ctx.read<AuthBloc>().state;
              final name = state is AuthAuthenticated ? state.user.displayName : 'U';
              final initials = name.trim().split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0].toUpperCase()).join();
              return Text(initials, style: GoogleFonts.dmSans(
                fontSize: 18, fontWeight: FontWeight.w500, color: const Color(0xFFAFA9EC), letterSpacing: 1));
            }))),
        Positioned(bottom: 0, right: 0, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: const Color(0xFF2A1F00), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBA7517), width: 1.5)),
          child: Text('Lvl 12', style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w500, color: const Color(0xFFEF9F27))),
        )),
      ])),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Builder(builder: (ctx) {
          final state = ctx.read<AuthBloc>().state;
          final name = state is AuthAuthenticated ? state.user.displayName : 'User';
          return Text(name, style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary));
        }),
        const SizedBox(height: 2),
        StreamBuilder<Map<String, dynamic>?>(
          stream: UserService.profileStream(),
          builder: (context, snapshot) {
            final profile = snapshot.data;
            final studentType = profile?['studentType'] as String? ?? 'university';
            final course = profile?['course'] as String? ?? '';
            final typeLabel = studentType == 'secondary' ? 'Secondary School' : 'University';
            final subtitle = course.isNotEmpty ? '$typeLabel · $course' : typeLabel;
            return Text(subtitle, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary));
          },
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFF1E1D3A), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF534AB7), width: 0.5)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.workspace_premium_outlined, size: 11, color: Color(0xFFAFA9EC)),
            const SizedBox(width: 5),
            Text('Rising Scholar', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFFAFA9EC))),
          ]),
        ),
      ])),
    ]);
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  _ArcPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, 34, Paint()..style = PaintingStyle.stroke..strokeWidth = 4..color = const Color(0xFF222222));
    if (progress <= 0) return;
    canvas.drawArc(Rect.fromCircle(center: c, radius: 34), -math.pi / 2, 2 * math.pi * progress, false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round..color = const Color(0xFF534AB7));
  }
  @override
  bool shouldRepaint(_ArcPainter o) => o.progress != progress;
}
