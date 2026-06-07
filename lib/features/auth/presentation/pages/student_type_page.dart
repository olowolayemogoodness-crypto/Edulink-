import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';

class StudentTypePage extends StatefulWidget {
  const StudentTypePage({super.key});
  @override
  State<StudentTypePage> createState() => _StudentTypePageState();
}

class _StudentTypePageState extends State<StudentTypePage> {
  String? _selected;

  Future<void> _continue() async {
    if (_selected == null) return;
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('student_type', _selected!);
    if (mounted) context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 12),
          Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.accentSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.accent, width: 1.5)),
            child: const Icon(Icons.bolt_rounded, color: AppColors.accentLight, size: 24)),
          const SizedBox(height: 24),
          Text('What describes\nyou best?', style: GoogleFonts.dmSans(fontSize: 26, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.3)),
          const SizedBox(height: 8),
          Text('We\'ll personalise your experience based on your level', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textTertiary, height: 1.6)),
          const SizedBox(height: 32),

          // University
          GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); setState(() => _selected = 'university'); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: _selected == 'university' ? AppColors.accentSurface : AppColors.surface,
                border: Border.all(color: _selected == 'university' ? AppColors.accent : AppColors.border, width: _selected == 'university' ? 2 : 1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(children: [
                Container(width: 52, height: 52, decoration: BoxDecoration(color: _selected == 'university' ? const Color(0xFF2D1B6B) : AppColors.surfaceVariant, borderRadius: BorderRadius.circular(16)),
                  child: const Center(child: Text('🎓', style: TextStyle(fontSize: 26)))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('University student', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: _selected == 'university' ? AppColors.accentLight : AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text('IELTS · TOEFL · GRE · degree-level prep', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
                ])),
                Container(width: 22, height: 22, decoration: BoxDecoration(color: _selected == 'university' ? AppColors.accent : AppColors.surfaceVariant, shape: BoxShape.circle),
                  child: _selected == 'university' ? const Icon(Icons.check_rounded, size: 13, color: Colors.white) : null),
              ]),
            ),
          ),

          // Secondary school
          GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); setState(() => _selected = 'secondary'); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _selected == 'secondary' ? AppColors.accentSurface : AppColors.surface,
                border: Border.all(color: _selected == 'secondary' ? AppColors.accent : AppColors.border, width: _selected == 'secondary' ? 2 : 1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(children: [
                Container(width: 52, height: 52, decoration: BoxDecoration(color: _selected == 'secondary' ? const Color(0xFF2D1B6B) : AppColors.surfaceVariant, borderRadius: BorderRadius.circular(16)),
                  child: const Center(child: Text('📚', style: TextStyle(fontSize: 26)))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Secondary school student', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: _selected == 'secondary' ? AppColors.accentLight : AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text('WAEC · JAMB · NECO · O-level prep', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
                ])),
                Container(width: 22, height: 22, decoration: BoxDecoration(color: _selected == 'secondary' ? AppColors.accent : AppColors.surfaceVariant, shape: BoxShape.circle),
                  child: _selected == 'secondary' ? const Icon(Icons.check_rounded, size: 13, color: Colors.white) : null),
              ]),
            ),
          ),

          const Spacer(),

          // CTA
          GestureDetector(
            onTap: _selected != null ? _continue : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _selected != null ? AppColors.accent : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text('Continue', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: _selected != null ? Colors.white : AppColors.textDisabled))),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: GestureDetector(
            onTap: () => context.go('/register'),
            child: Text('Skip for now', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textDisabled)),
          )),
        ]),
      )),
    );
  }
}