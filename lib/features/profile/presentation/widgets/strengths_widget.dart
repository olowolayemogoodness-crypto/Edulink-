import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StrengthsWidget extends StatelessWidget {
  const StrengthsWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: _Card(titleLabel: 'Strengths', titleIcon: Icons.trending_up,
          titleColor: const Color(0xFF1D9E75), items: const [
            _Item('Problem solving', Color(0xFF0D2219), Icons.check, Color(0xFF1D9E75)),
            _Item('Reading speed',   Color(0xFF0D2219), Icons.check, Color(0xFF1D9E75)),
            _Item('Memory recall',   Color(0xFF0D2219), Icons.check, Color(0xFF1D9E75)),
          ])),
      const SizedBox(width: 8),
      Expanded(child: _Card(titleLabel: 'Work on these', titleIcon: Icons.warning_amber_rounded,
          titleColor: const Color(0xFFD85A30), items: const [
            _Item('Essay writing',   Color(0xFF2E1A0F), Icons.arrow_upward, Color(0xFFD85A30)),
            _Item('Time management', Color(0xFF2E1A0F), Icons.arrow_upward, Color(0xFFD85A30)),
            _Item('Speaking drills', Color(0xFF2A1F00), Icons.remove,       Color(0xFFEF9F27)),
          ])),
    ]);
  }
}

class _Item {
  final String label; final Color bg, iconColor; final IconData icon;
  const _Item(this.label, this.bg, this.icon, this.iconColor);
}

class _Card extends StatelessWidget {
  final String titleLabel; final IconData titleIcon; final Color titleColor; final List<_Item> items;
  const _Card({required this.titleLabel, required this.titleIcon, required this.titleColor, required this.items});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF1A1A18), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(titleIcon, size: 12, color: titleColor), const SizedBox(width: 5),
            Text(titleLabel, style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500, color: titleColor)),
          ]),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 4),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(color: item.bg, borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Icon(item.icon, size: 11, color: item.iconColor), const SizedBox(width: 5),
                    Expanded(child: Text(item.label,
                        style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFFCCCCCC)),
                        overflow: TextOverflow.ellipsis)),
                  ])))),
        ]));
  }
}
