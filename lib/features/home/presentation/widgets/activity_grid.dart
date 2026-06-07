import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class ActivityGrid extends StatelessWidget {
  const ActivityGrid({super.key});

  static const _cards = [
    _ActivityCard(
      name: 'AI Tutor',
      sub: 'Ask anything',
      icon: Icons.auto_awesome_rounded,
      iconBg: Color(0xFF1E1D3A),
      iconColor: AppColors.accentLight,
      borderColor: Color(0xFF3C3489),
      bg: Color(0xFF1A1A30),
      badge: 'Gemini',
      badgeBg: Color(0xFF2D1B69),
      badgeColor: AppColors.accentLight,
      progress: 0.0,
      route: '/tutor',
      progressColor: AppColors.accent,
    ),
    _ActivityCard(
      name: 'Quiz',
      sub: '12 ready',
      icon: Icons.quiz_rounded,
      iconBg: Color(0xFF0D2219),
      iconColor: Color(0xFF1D9E75),
      borderColor: Color(0xFF0F6E56),
      bg: Color(0xFF0D1F14),
      badge: '+50 XP',
      badgeBg: Color(0xFF0F2A1A),
      badgeColor: Color(0xFF1D9E75),
      progress: 0.6,
      progressColor: Color(0xFF1D9E75),
      route: '/quiz',
    ),
    _ActivityCard(
      name: 'Flashcards',
      sub: '24 due',
      icon: Icons.style_rounded,
      iconBg: Color(0xFF2A1F00),
      iconColor: Color(0xFFEF9F27),
      borderColor: Color(0xFF854F0B),
      bg: Color(0xFF1F1800),
      badge: 'Review',
      badgeBg: Color(0xFF2A1F00),
      badgeColor: Color(0xFFEF9F27),
      progress: 0.4,
      progressColor: Color(0xFFEF9F27),
      route: '/flashcards',
    ),
    _ActivityCard(
      name: 'Exam prep',
      sub: 'WAEC · JAMB',
      icon: Icons.school_rounded,
      iconBg: Color(0xFF2E1A0F),
      iconColor: Color(0xFFD85A30),
      borderColor: Color(0xFF993C1D),
      bg: Color(0xFF201108),
      badge: 'Hot',
      badgeBg: Color(0xFF2E1A0F),
      badgeColor: Color(0xFFD85A30),
      progress: 0.25,
      progressColor: Color(0xFFD85A30),
      route: '/exam-prep',
    ),
    _ActivityCard(
      name: 'Camera scan',
      sub: 'Snap a question',
      icon: Icons.camera_alt_rounded,
      iconBg: Color(0xFF0C1E32),
      iconColor: Color(0xFF85B7EB),
      borderColor: Color(0xFF185FA5),
      bg: Color(0xFF091625),
      badge: 'AI',
      badgeBg: Color(0xFF0C1E32),
      badgeColor: Color(0xFF60A5FA),
      progress: 0.0,
      progressColor: Color(0xFF378ADD),
      route: '/camera-scan',
    ),
    _ActivityCard(
      name: 'Practice test',
      sub: 'Full mock exam',
      icon: Icons.assignment_rounded,
      iconBg: Color(0xFF2A1020),
      iconColor: Color(0xFFED93B1),
      borderColor: Color(0xFF993556),
      bg: Color(0xFF1E0A16),
      badge: 'New',
      badgeBg: Color(0xFF2A1020),
      badgeColor: Color(0xFFED93B1),
      progress: 0.0,
      progressColor: Color(0xFFD4537E),
      route: '/practice-test',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.1,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: _cards.map((c) => _ActivityCardWidget(card: c)).toList(),
      ),
    );
  }
}

class _ActivityCardWidget extends StatefulWidget {
  final _ActivityCard card;
  const _ActivityCardWidget({ required this.card});

  @override
  State<_ActivityCardWidget> createState() => _ActivityCardWidgetState();
}

class _ActivityCardWidgetState extends State<_ActivityCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _progAnim = Tween<double>(begin: 0, end: widget.card.progress).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.card;
    return GestureDetector(
      onTap: () { if (c.route != null) context.push(c.route!); },
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.bg,
            border: Border.all(color: c.borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: c.iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(c.icon, color: c.iconColor, size: 20),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.badgeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(c.badge,
                        style: AppTextStyles.caption
                            .copyWith(color: c.badgeColor, fontSize: 9)),
                  ),
                ],
              ),
              const Spacer(),
              Text(c.name, style: AppTextStyles.titleSmall),
              Text(c.sub,
                  style: AppTextStyles.caption.copyWith(fontSize: 10)),
              if (c.progress > 0) ...[
                const SizedBox(height: 6),
                AnimatedBuilder(
                  animation: _progAnim,
                  builder: (_, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _progAnim.value,
                      minHeight: 3,
                      backgroundColor: AppColors.border,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(c.progressColor),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard {
  final String name;
  final String sub;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color borderColor;
  final Color bg;
  final String badge;
  final Color badgeBg;
  final Color badgeColor;
  final double progress;
  final Color progressColor;
  final String? route;

  const _ActivityCard({
    required this.name,
    required this.sub,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.borderColor,
    required this.bg,
    required this.badge,
    required this.badgeBg,
    required this.badgeColor,
    required this.progress,
    required this.progressColor,
    this.route,
  });
}