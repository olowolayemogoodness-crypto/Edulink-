import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class LearningStyleCard extends StatelessWidget {
  const LearningStyleCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: const Color(0xFF1A1A18), borderRadius: BorderRadius.circular(16)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFF1E1D3A), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.lightbulb_outline, size: 18, color: Color(0xFF7F77DD))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Visual + spaced repetition learner',
              style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('You retain 40% more with diagrams and concept maps. Study in focused 45-min blocks with 15-min breaks. Review on days 1, 3 and 7 after learning for best retention.',
              style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary, height: 1.6)),
        ])),
      ]),
    );
  }
}
