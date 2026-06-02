import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class ActivityGrid extends StatelessWidget {
  const ActivityGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _ACard('AI Tutor','Ask anything',Icons.auto_awesome_rounded,const Color(0xFF1E1D3A),AppColors.accentLight,const Color(0xFF3C3489),const Color(0xFF1A1A30),'Gemini',const Color(0xFF2D1B69),AppColors.accentLight,0.0,AppColors.accent),
      _ACard('Quiz','12 ready',Icons.quiz_rounded,const Color(0xFF0D2219),const Color(0xFF1D9E75),const Color(0xFF0F6E56),const Color(0xFF0D1F14),'+50 XP',const Color(0xFF0F2A1A),const Color(0xFF1D9E75),0.6,const Color(0xFF1D9E75)),
      _ACard('Flashcards','24 due',Icons.style_rounded,const Color(0xFF2A1F00),const Color(0xFFEF9F27),const Color(0xFF854F0B),const Color(0xFF1F1800),'Review',const Color(0xFF2A1F00),const Color(0xFFEF9F27),0.4,const Color(0xFFEF9F27)),
      _ACard('Exam prep','WAEC · JAMB',Icons.school_rounded,const Color(0xFF2E1A0F),const Color(0xFFD85A30),const Color(0xFF993C1D),const Color(0xFF201108),'Hot',const Color(0xFF2E1A0F),const Color(0xFFD85A30),0.25,const Color(0xFFD85A30)),
      _ACard('Camera scan','Snap a question',Icons.camera_alt_rounded,const Color(0xFF0C1E32),const Color(0xFF85B7EB),const Color(0xFF185FA5),const Color(0xFF091625),'AI',const Color(0xFF0C1E32),const Color(0xFF60A5FA),0.0,const Color(0xFF378ADD)),
      _ACard('Practice test','Full mock exam',Icons.assignment_rounded,const Color(0xFF2A1020),const Color(0xFFED93B1),const Color(0xFF993556),const Color(0xFF1E0A16),'New',const Color(0xFF2A1020),const Color(0xFFED93B1),0.0,const Color(0xFFD4537E)),
    ];

    final w2 = (MediaQuery.of(context).size.width - 48) / 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Row(children: [
            _CardWidget(card: cards[0], cardWidth: w2),
            const SizedBox(width: 10),
            _CardWidget(card: cards[1], cardWidth: w2, onTap: () => context.push("/quiz")),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _CardWidget(card: cards[2], cardWidth: w2),
            const SizedBox(width: 10),
            _CardWidget(card: cards[3], cardWidth: w2),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _CardWidget(card: cards[4], cardWidth: w2),
            const SizedBox(width: 10),
            _CardWidget(card: cards[5], cardWidth: w2),
          ]),
        ],
      ),
    );
  }
}

class _CardWidget extends StatefulWidget {
  final _ACard card;
  final double cardWidth;
  final VoidCallback? onTap;
  const _CardWidget({required this.card, required this.cardWidth, this.onTap});
  @override State<_CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<_CardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _prog;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _prog = Tween<double>(begin: 0, end: widget.card.progress).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(const Duration(milliseconds: 600), () { if (mounted) _ctrl.forward(); });
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = widget.card;
    return SizedBox(
      width: widget.cardWidth,
      height: widget.cardWidth * 0.95,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.bg,
            border: Border.all(color: c.borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 36, height: 36,
                decoration: BoxDecoration(color: c.iconBg, borderRadius: BorderRadius.circular(11)),
                child: Icon(c.icon, color: c.iconColor, size: 18)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: c.badgeBg, borderRadius: BorderRadius.circular(20)),
                child: Text(c.badge, style: AppTextStyles.caption.copyWith(color: c.badgeColor, fontSize: 9))),
            ]),
            const Spacer(),
            Text(c.name, style: AppTextStyles.titleSmall),
            Text(c.sub, style: AppTextStyles.caption.copyWith(fontSize: 10)),
            if (c.progress > 0) ...[
              const SizedBox(height: 6),
              AnimatedBuilder(animation: _prog, builder: (_, _) =>
                  ClipRRect(borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(value: _prog.value, minHeight: 3,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(c.progressColor)))),
            ],
          ]),
        ),
      ),
    );
  }
}

class _ACard {
  final String name, sub, badge;
  final IconData icon;
  final Color iconBg, iconColor, borderColor, bg, badgeBg, badgeColor, progressColor;
  final double progress;
  const _ACard(this.name, this.sub, this.icon, this.iconBg, this.iconColor, this.borderColor,
      this.bg, this.badge, this.badgeBg, this.badgeColor, this.progress, this.progressColor);
}