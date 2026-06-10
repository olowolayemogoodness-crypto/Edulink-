import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});
  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  int _selectedCategory = 0;

  final _categories = ['All', 'PDFs', 'Notes', 'Textbooks', 'Past questions'];

  final _items = [
    _LibraryItem(title: 'WAEC Mathematics Past Questions 2023', type: 'PDF', subject: 'Mathematics', emoji: '📐', pages: 48, color: const Color(0xFF1E1240), border: const Color(0xFF2D1B6B)),
    _LibraryItem(title: 'IELTS Academic Writing Guide', type: 'PDF', subject: 'English', emoji: '📝', pages: 32, color: const Color(0xFF052E1E), border: const Color(0xFF0EA472)),
    _LibraryItem(title: 'Data Structures & Algorithms Notes', type: 'Notes', subject: 'Computer Science', emoji: '💻', pages: 24, color: const Color(0xFF2D1E00), border: const Color(0xFFC47D0E)),
    _LibraryItem(title: 'JAMB Chemistry Past Questions', type: 'Past questions', subject: 'Chemistry', emoji: '⚗️', pages: 60, color: const Color(0xFF2D0A1E), border: const Color(0xFFEC4899)),
    _LibraryItem(title: 'Biology Textbook — SS3', type: 'Textbooks', subject: 'Biology', emoji: '🔬', pages: 120, color: const Color(0xFF052E1E), border: const Color(0xFF0EA472)),
    _LibraryItem(title: 'WAEC Physics Past Questions 2022', type: 'Past questions', subject: 'Physics', emoji: '⚡', pages: 52, color: const Color(0xFF0C1A3D), border: const Color(0xFF3B82F6)),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 0
        ? _items
        : _items.where((i) => i.type == _categories[_selectedCategory]).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Study Library',
                  style: GoogleFonts.dmSans(fontSize: 17,
                      fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text('Books · PDFs · Notes',
                  style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
            ])),
            GestureDetector(
              onTap: () => _showUploadSheet(context),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
              ),
            ),
          ]),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              const Icon(Icons.search_rounded, size: 18, color: AppColors.textTertiary),
              const SizedBox(width: 8),
              Text('Search your library…',
                  style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textTertiary)),
            ]),
          ),
        ),

        // Categories
        SizedBox(
          height: 36,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final selected = _selectedCategory == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accent : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected ? AppColors.accent : AppColors.border,
                        width: 0.5),
                  ),
                  child: Text(_categories[i],
                      style: GoogleFonts.dmSans(fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : AppColors.textSecondary)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Stats row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(children: [
            _StatChip(label: '${_items.length} items', color: AppColors.accentLight),
            const SizedBox(width: 8),
            _StatChip(label: '3 PDFs', color: const Color(0xFF0EA472)),
            const SizedBox(width: 8),
            _StatChip(label: '2 past Qs', color: const Color(0xFFE8960F)),
          ]),
        ),

        // List
        Expanded(child: filtered.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('📚', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text('No items yet',
                  style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textTertiary)),
              const SizedBox(height: 4),
              Text('Tap + to upload a PDF or note',
                  style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textTertiary)),
            ]))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _LibraryCard(item: filtered[i]),
            ),
        ),
      ])),
    );
  }

  void _showUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('Add to library',
              style: GoogleFonts.dmSans(fontSize: 16,
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          _UploadOption(icon: Icons.picture_as_pdf_rounded,
              color: const Color(0xFFEA580C), label: 'Upload PDF',
              sub: 'Past questions, textbooks, notes'),
          const SizedBox(height: 10),
          _UploadOption(icon: Icons.note_add_rounded,
              color: AppColors.accentLight, label: 'Create note',
              sub: 'Write or paste your study notes'),
          const SizedBox(height: 10),
          _UploadOption(icon: Icons.camera_alt_rounded,
              color: const Color(0xFF0EA472), label: 'Scan document',
              sub: 'Take a photo of handwritten notes'),
          const SizedBox(height: 10),
        ]),
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final _LibraryItem item;
  const _LibraryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: item.color,
        border: Border.all(color: item.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
              color: AppColors.background, borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(item.emoji,
              style: const TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title, style: GoogleFonts.dmSans(fontSize: 13,
              fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20)),
              child: Text(item.type, style: GoogleFonts.dmSans(
                  fontSize: 9, color: AppColors.textTertiary)),
            ),
            const SizedBox(width: 6),
            Text(item.subject, style: GoogleFonts.dmSans(
                fontSize: 10, color: AppColors.textTertiary)),
          ]),
          const SizedBox(height: 4),
          Text('${item.pages} pages',
              style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
        ])),
        const Icon(Icons.chevron_right_rounded,
            size: 18, color: AppColors.textTertiary),
      ]),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: GoogleFonts.dmSans(
          fontSize: 10, fontWeight: FontWeight.w500, color: color)),
    );
  }
}

class _UploadOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, sub;
  const _UploadOption({required this.icon, required this.color,
      required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 13,
              fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          Text(sub, style: GoogleFonts.dmSans(
              fontSize: 10, color: AppColors.textTertiary)),
        ])),
        const Icon(Icons.chevron_right_rounded,
            size: 16, color: AppColors.textTertiary),
      ]),
    );
  }
}

class _LibraryItem {
  final String title, type, subject, emoji;
  final int pages;
  final Color color, border;
  const _LibraryItem({
    required this.title, required this.type, required this.subject,
    required this.emoji, required this.pages,
    required this.color, required this.border,
  });
}