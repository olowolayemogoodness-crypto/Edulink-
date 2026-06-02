import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class HomeTopBar extends StatefulWidget {
  final int streakCount;
  final int xpCount;
  const HomeTopBar({super.key, required this.streakCount, required this.xpCount});

  @override
  State<HomeTopBar> createState() => _HomeTopBarState();
}

class _HomeTopBarState extends State<HomeTopBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _flameCtrl;
  late Animation<double> _flameAnim;
    
  @override
  void initState() {
    super.initState();
    _flameCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _flameAnim = Tween<double>(begin: -0.07, end: 0.07).animate(
        CurvedAnimation(parent: _flameCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _flameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        children: [
          // Streak chip
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0xFF2E1A0F),
                border: Border.all(color: AppColors.streak, width: 1.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _flameAnim,
                    builder: (_, child) => Transform.rotate(
                      angle: _flameAnim.value,
                      child: child,
                    ),
                    child: const Text('🔥', style: TextStyle(fontSize: 15)),
                  ),
                  const SizedBox(width: 5),
                  Text('${widget.streakCount}',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.streak)),
                ],
              ),
            ),
          ),
          const Spacer(),
          // XP chip
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1D3A),
              border: Border.all(color: AppColors.accent, width: 1.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, size: 14, color: AppColors.accentLight),
                const SizedBox(width: 4),
                _AnimatedCounter(target: widget.xpCount),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Hearts
          Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    ...List.generate(3, (_) => const Padding(
          padding: EdgeInsets.only(left: 2),
          child: Text('❤️', style: TextStyle(fontSize: 13)),
        )),
    ...List.generate(2, (_) => const Padding(
          padding: EdgeInsets.only(left: 2),
          child: Opacity(
            opacity: 0.25,
            child: Text('❤️', style: TextStyle(fontSize: 13)),
          ),
        )),
  ],
),
        ],
      ),
    );
}
}
class _AnimatedCounter extends StatefulWidget {
  final int target;
  const _AnimatedCounter({required this.target});

  @override
  State<_AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<_AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<int> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = IntTween(begin: 0, end: widget.target)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 300), () {
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
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Text(
        _anim.value.toString(),
        style: AppTextStyles.labelLarge.copyWith(color: AppColors.accentLight),
      ),
    );
  }
}