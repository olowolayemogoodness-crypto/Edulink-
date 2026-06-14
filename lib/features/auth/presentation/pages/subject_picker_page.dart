import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Models ──
class SubjectOption {
  final String id, emoji, name;
  final Color color, bg, border;
  final List<ExamOption> exams;
  const SubjectOption({
    required this.id, required this.emoji, required this.name,
    required this.color, required this.bg, required this.border,
    required this.exams,
  });
}

class ExamOption {
  final String id, label, tag;
  final Color tagBg, tagColor;
  const ExamOption({
    required this.id, required this.label, required this.tag,
    required this.tagBg, required this.tagColor,
  });
}

class SelectedSubject {
  final String subjectId;
  final String examId;
  const SelectedSubject({required this.subjectId, required this.examId});
}

// ── All subjects ──
const _secondarySubjects = [
  SubjectOption(
    id: 'math', emoji: '📐', name: 'Mathematics',
    color: Color(0xFF9D6FEC), bg: Color(0xFF1E1240), border: Color(0xFF2D1B6B),
    exams: [
      ExamOption(id: 'waec_math', label: 'WAEC Mathematics', tag: 'WAEC', tagBg: Color(0xFF2D1E00), tagColor: Color(0xFFE8960F)),
      ExamOption(id: 'jamb_math', label: 'JAMB Mathematics', tag: 'JAMB', tagBg: Color(0xFF1E1240), tagColor: Color(0xFF9D6FEC)),
      ExamOption(id: 'neco_math', label: 'NECO Mathematics', tag: 'NECO', tagBg: Color(0xFF052E1E), tagColor: Color(0xFF0EA472)),
    ],
  ),
  SubjectOption(
    id: 'eng', emoji: '📝', name: 'English Language',
    color: Color(0xFF0EA472), bg: Color(0xFF052E1E), border: Color(0xFF0EA472),
    exams: [
      ExamOption(id: 'waec_eng', label: 'WAEC English', tag: 'WAEC', tagBg: Color(0xFF2D1E00), tagColor: Color(0xFFE8960F)),
      ExamOption(id: 'jamb_eng', label: 'JAMB Use of English', tag: 'JAMB', tagBg: Color(0xFF1E1240), tagColor: Color(0xFF9D6FEC)),
      ExamOption(id: 'neco_eng', label: 'NECO English', tag: 'NECO', tagBg: Color(0xFF052E1E), tagColor: Color(0xFF0EA472)),
    ],
  ),
  SubjectOption(
    id: 'bio', emoji: '🔬', name: 'Biology',
    color: Color(0xFF0EA472), bg: Color(0xFF052E1E), border: Color(0xFF0EA472),
    exams: [
      ExamOption(id: 'waec_bio', label: 'WAEC Biology', tag: 'WAEC', tagBg: Color(0xFF2D1E00), tagColor: Color(0xFFE8960F)),
      ExamOption(id: 'jamb_bio', label: 'JAMB Biology', tag: 'JAMB', tagBg: Color(0xFF1E1240), tagColor: Color(0xFF9D6FEC)),
    ],
  ),
  SubjectOption(
    id: 'chem', emoji: '⚗️', name: 'Chemistry',
    color: Color(0xFFEA580C), bg: Color(0xFF2D1200), border: Color(0xFFEA580C),
    exams: [
      ExamOption(id: 'waec_chem', label: 'WAEC Chemistry', tag: 'WAEC', tagBg: Color(0xFF2D1E00), tagColor: Color(0xFFE8960F)),
      ExamOption(id: 'jamb_chem', label: 'JAMB Chemistry', tag: 'JAMB', tagBg: Color(0xFF1E1240), tagColor: Color(0xFF9D6FEC)),
    ],
  ),
  SubjectOption(
    id: 'phys', emoji: '⚡', name: 'Physics',
    color: Color(0xFF60A5FA), bg: Color(0xFF0C1A3D), border: Color(0xFF185FA5),
    exams: [
      ExamOption(id: 'waec_phys', label: 'WAEC Physics', tag: 'WAEC', tagBg: Color(0xFF2D1E00), tagColor: Color(0xFFE8960F)),
      ExamOption(id: 'jamb_phys', label: 'JAMB Physics', tag: 'JAMB', tagBg: Color(0xFF1E1240), tagColor: Color(0xFF9D6FEC)),
    ],
  ),
  SubjectOption(
    id: 'econ', emoji: '💹', name: 'Economics',
    color: Color(0xFFE8960F), bg: Color(0xFF2D1E00), border: Color(0xFFC47D0E),
    exams: [
      ExamOption(id: 'waec_econ', label: 'WAEC Economics', tag: 'WAEC', tagBg: Color(0xFF2D1E00), tagColor: Color(0xFFE8960F)),
      ExamOption(id: 'jamb_econ', label: 'JAMB Economics', tag: 'JAMB', tagBg: Color(0xFF1E1240), tagColor: Color(0xFF9D6FEC)),
    ],
  ),
  SubjectOption(
    id: 'govt', emoji: '🏛️', name: 'Government',
    color: Color(0xFFEA580C), bg: Color(0xFF2D1200), border: Color(0xFFEA580C),
    exams: [
      ExamOption(id: 'waec_govt', label: 'WAEC Government', tag: 'WAEC', tagBg: Color(0xFF2D1E00), tagColor: Color(0xFFE8960F)),
      ExamOption(id: 'jamb_govt', label: 'JAMB Government', tag: 'JAMB', tagBg: Color(0xFF1E1240), tagColor: Color(0xFF9D6FEC)),
    ],
  ),
  SubjectOption(
    id: 'lit', emoji: '📖', name: 'Literature in English',
    color: Color(0xFFEC4899), bg: Color(0xFF2D0A1E), border: Color(0xFFEC4899),
    exams: [
      ExamOption(id: 'waec_lit', label: 'WAEC Literature', tag: 'WAEC', tagBg: Color(0xFF2D1E00), tagColor: Color(0xFFE8960F)),
    ],
  ),
  SubjectOption(
    id: 'agric', emoji: '🌱', name: 'Agricultural Science',
    color: Color(0xFF0EA472), bg: Color(0xFF052E1E), border: Color(0xFF0EA472),
    exams: [
      ExamOption(id: 'waec_agric', label: 'WAEC Agric Science', tag: 'WAEC', tagBg: Color(0xFF2D1E00), tagColor: Color(0xFFE8960F)),
    ],
  ),
  SubjectOption(
    id: 'cs_sec', emoji: '💻', name: 'Computer Science',
    color: Color(0xFF9D6FEC), bg: Color(0xFF1E1240), border: Color(0xFF2D1B6B),
    exams: [
      ExamOption(id: 'waec_cs', label: 'WAEC Comp Science', tag: 'WAEC', tagBg: Color(0xFF2D1E00), tagColor: Color(0xFFE8960F)),
      ExamOption(id: 'jamb_cs', label: 'JAMB Comp Science', tag: 'JAMB', tagBg: Color(0xFF1E1240), tagColor: Color(0xFF9D6FEC)),
    ],
  ),
];

const _universitySubjects = [
  SubjectOption(
    id: 'ielts', emoji: '🌍', name: 'IELTS Academic',
    color: Color(0xFF0EA472), bg: Color(0xFF052E1E), border: Color(0xFF0EA472),
    exams: [
      ExamOption(id: 'ielts_b7', label: 'Target Band 7', tag: 'Band 7', tagBg: Color(0xFF052E1E), tagColor: Color(0xFF0EA472)),
      ExamOption(id: 'ielts_b75', label: 'Target Band 7.5', tag: '7.5', tagBg: Color(0xFF052E1E), tagColor: Color(0xFF0EA472)),
      ExamOption(id: 'ielts_b8', label: 'Target Band 8', tag: 'Band 8', tagBg: Color(0xFF052E1E), tagColor: Color(0xFF0EA472)),
    ],
  ),
  SubjectOption(
    id: 'toefl', emoji: '🇺🇸', name: 'TOEFL iBT',
    color: Color(0xFF60A5FA), bg: Color(0xFF0C1A3D), border: Color(0xFF185FA5),
    exams: [
      ExamOption(id: 'toefl_90', label: 'Target 90+', tag: '90+', tagBg: Color(0xFF0C1A3D), tagColor: Color(0xFF60A5FA)),
      ExamOption(id: 'toefl_100', label: 'Target 100+', tag: '100+', tagBg: Color(0xFF0C1A3D), tagColor: Color(0xFF60A5FA)),
    ],
  ),
  SubjectOption(
    id: 'gre', emoji: '🎓', name: 'GRE',
    color: Color(0xFF9D6FEC), bg: Color(0xFF1E1240), border: Color(0xFF2D1B6B),
    exams: [
      ExamOption(id: 'gre_q', label: 'GRE Quantitative', tag: 'Quant', tagBg: Color(0xFF1E1240), tagColor: Color(0xFF9D6FEC)),
      ExamOption(id: 'gre_v', label: 'GRE Verbal', tag: 'Verbal', tagBg: Color(0xFF1E1240), tagColor: Color(0xFF9D6FEC)),
      ExamOption(id: 'gre_both', label: 'GRE Full (Q+V)', tag: 'Full', tagBg: Color(0xFF1E1240), tagColor: Color(0xFF9D6FEC)),
    ],
  ),
  SubjectOption(
    id: 'ds', emoji: '💻', name: 'Data Structures & Algorithms',
    color: Color(0xFF9D6FEC), bg: Color(0xFF1E1240), border: Color(0xFF2D1B6B),
    exams: [
      ExamOption(id: 'ds_beg', label: 'Beginner', tag: 'Beginner', tagBg: Color(0xFF1E1240), tagColor: Color(0xFF9D6FEC)),
      ExamOption(id: 'ds_int', label: 'Intermediate', tag: 'Inter', tagBg: Color(0xFF1E1240), tagColor: Color(0xFF9D6FEC)),
      ExamOption(id: 'ds_adv', label: 'Advanced', tag: 'Advanced', tagBg: Color(0xFF1E1240), tagColor: Color(0xFF9D6FEC)),
    ],
  ),
  SubjectOption(
    id: 'calc', emoji: '📐', name: 'Calculus',
    color: Color(0xFFE8960F), bg: Color(0xFF2D1E00), border: Color(0xFFC47D0E),
    exams: [
      ExamOption(id: 'calc_1', label: 'Calculus I', tag: 'Cal I', tagBg: Color(0xFF2D1E00), tagColor: Color(0xFFE8960F)),
      ExamOption(id: 'calc_2', label: 'Calculus II', tag: 'Cal II', tagBg: Color(0xFF2D1E00), tagColor: Color(0xFFE8960F)),
    ],
  ),
  SubjectOption(
    id: 'stats', emoji: '📊', name: 'Statistics',
    color: Color(0xFF0EA472), bg: Color(0xFF052E1E), border: Color(0xFF0EA472),
    exams: [
      ExamOption(id: 'stats_intro', label: 'Intro Statistics', tag: 'Intro', tagBg: Color(0xFF052E1E), tagColor: Color(0xFF0EA472)),
      ExamOption(id: 'stats_adv', label: 'Advanced Statistics', tag: 'Advanced', tagBg: Color(0xFF052E1E), tagColor: Color(0xFF0EA472)),
    ],
  ),
  SubjectOption(
    id: 'econ_uni', emoji: '💹', name: 'Economics',
    color: Color(0xFFE8960F), bg: Color(0xFF2D1E00), border: Color(0xFFC47D0E),
    exams: [
      ExamOption(id: 'micro', label: 'Microeconomics', tag: 'Micro', tagBg: Color(0xFF2D1E00), tagColor: Color(0xFFE8960F)),
      ExamOption(id: 'macro', label: 'Macroeconomics', tag: 'Macro', tagBg: Color(0xFF2D1E00), tagColor: Color(0xFFE8960F)),
    ],
  ),
];

class SubjectPickerPage extends StatefulWidget {
  const SubjectPickerPage({super.key});
  @override
  State<SubjectPickerPage> createState() => _SubjectPickerPageState();
}

class _SubjectPickerPageState extends State<SubjectPickerPage> {
  final List<SelectedSubject> _selected = [];
  String? _expandedId;
  bool _reviewing = false;
  bool _saving = false;
  String _studentType = 'secondary';

@override
void initState() {
  super.initState();
  _loadStudentType();
}

Future<void> _loadStudentType() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() => _studentType = prefs.getString('student_type') ?? 'secondary');
}

List<SubjectOption> get _subjects => _studentType == 'university'
    ? _universitySubjects
    : _secondarySubjects;

  SubjectOption? _getSubject(String id) =>
      _subjects.where((s) => s.id == id).firstOrNull;

  bool _isSelected(String subjectId) =>
      _selected.any((s) => s.subjectId == subjectId);

  SelectedSubject? _getEntry(String subjectId) =>
      _selected.where((s) => s.subjectId == subjectId).firstOrNull;

  void _toggleSubject(SubjectOption subject) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_isSelected(subject.id)) {
        _selected.removeWhere((s) => s.subjectId == subject.id);
        if (_expandedId == subject.id) _expandedId = null;
      } else {
        _selected.add(SelectedSubject(
          subjectId: subject.id,
          examId: subject.exams.first.id,
        ));
        _expandedId = subject.id;
      }
    });
  }

  void _selectExam(String subjectId, String examId) {
    HapticFeedback.selectionClick();
    setState(() {
      final idx = _selected.indexWhere((s) => s.subjectId == subjectId);
      if (idx != -1) {
        _selected[idx] = SelectedSubject(subjectId: subjectId, examId: examId);
      }
      _expandedId = null;
    });
  }

  void _toggleExpanded(String subjectId) {
    setState(() => _expandedId = _expandedId == subjectId ? null : subjectId);
  }

  Future<void> _saveAndContinue() async {
    if (_selected.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select at least 2 subjects',
            style: GoogleFonts.dmSans(fontSize: 13)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _saving = true);
    final subjectNames = _selected.map((s) {
      final sub = _getSubject(s.subjectId);
      final exam = sub?.exams.where((e) => e.id == s.examId).firstOrNull;
      return exam?.label ?? sub?.name ?? s.subjectId;
    }).toList();
    await UserService.updateProfile(course: subjectNames.join(', '));
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _reviewing ? _reviewScreen() : _pickerScreen()),
    );
  }

  Widget _pickerScreen() {
    return Column(children: [
      // Step dots
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _dot(done: true), const SizedBox(width: 6),
          _dot(done: true), const SizedBox(width: 6),
          _dot(active: true), const SizedBox(width: 6),
          _dot(),
        ]),
      ),
      // Header
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Pick your subjects',
              style: GoogleFonts.dmSans(fontSize: 18,
                  fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          Text('Select what you\'re studying and choose the exam level for each.',
              style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
        ]),
      ),
      // Count badge
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          RichText(text: TextSpan(children: [
            TextSpan(text: '${_selected.length} subject${_selected.length != 1 ? "s" : ""}',
                style: GoogleFonts.dmSans(fontSize: 10,
                    fontWeight: FontWeight.w500, color: AppColors.accentLight)),
            TextSpan(text: ' selected · tap each to set exam type',
                style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: const Color(0xFF052E1E),
                border: Border.all(color: const Color(0xFF0EA472), width: 0.5),
                borderRadius: BorderRadius.circular(20)),
            child: Text('Min 2',
                style: GoogleFonts.dmSans(fontSize: 9, color: const Color(0xFF0EA472))),
          ),
        ]),
      ),
      // Subject list
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _subjects.length,
        itemBuilder: (_, i) {
          final subject = _subjects[i];
          final selected = _isSelected(subject.id);
          final expanded = _expandedId == subject.id;
          final entry = _getEntry(subject.id);
          final selectedExam = entry != null
              ? subject.exams.where((e) => e.id == entry.examId).firstOrNull
              : null;

          return Column(children: [
            GestureDetector(
              onTap: () {
                if (selected) {
                  _toggleExpanded(subject.id);
                } else {
                  _toggleSubject(subject);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(bottom: expanded ? 0 : 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  color: selected ? subject.bg : AppColors.surface,
                  border: Border.all(
                      color: selected
                          ? (expanded ? subject.border : subject.border)
                          : AppColors.border,
                      width: selected ? 1.5 : 0.5),
                  borderRadius: expanded
                      ? const BorderRadius.vertical(top: Radius.circular(14))
                      : BorderRadius.circular(14),
                ),
                child: Row(children: [
                  Text(subject.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(subject.name,
                        style: GoogleFonts.dmSans(fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: selected ? AppColors.textPrimary : AppColors.textSecondary)),
                    if (selected && selectedExam != null)
                      Text(selectedExam.label,
                          style: GoogleFonts.dmSans(fontSize: 10, color: subject.color)),
                  ])),
                  if (selected)
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                            color: expanded ? subject.bg : subject.bg,
                            borderRadius: BorderRadius.circular(7)),
                        child: Icon(Icons.keyboard_arrow_down_rounded,
                            size: 16, color: subject.color),
                      ),
                    )
                  else
                    Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(7)),
                      child: const Icon(Icons.add_rounded,
                          size: 14, color: AppColors.textTertiary),
                    ),
                ]),
              ),
            ),
            // Exam dropdown
            if (expanded) AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: subject.border, width: 1.5),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
              ),
              child: Column(
                children: subject.exams.map((exam) {
                  final picked = entry?.examId == exam.id;
                  return GestureDetector(
                    onTap: () => _selectExam(subject.id, exam.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                      decoration: BoxDecoration(
                        color: picked ? subject.bg : Colors.transparent,
                        border: Border(
                            bottom: BorderSide(color: AppColors.border, width: 0.5)),
                      ),
                      child: Row(children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 18, height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: picked ? subject.color : Colors.transparent,
                            border: Border.all(
                                color: picked ? subject.color : AppColors.border,
                                width: 1.5),
                          ),
                          child: picked
                              ? const Icon(Icons.check_rounded,
                                  size: 10, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(exam.label,
                            style: GoogleFonts.dmSans(fontSize: 12,
                                fontWeight: picked ? FontWeight.w500 : FontWeight.normal,
                                color: picked ? AppColors.textPrimary : AppColors.textSecondary))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                              color: exam.tagBg,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(exam.tag,
                              style: GoogleFonts.dmSans(
                                  fontSize: 9, color: exam.tagColor)),
                        ),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),
          ]);
        },
      )),
      // CTA
      Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: AppColors.border))),
        child: GestureDetector(
          onTap: _selected.length >= 2
              ? () => setState(() => _reviewing = true)
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: _selected.length >= 2 ? AppColors.accent : AppColors.border,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Continue',
                  style: GoogleFonts.dmSans(fontSize: 14,
                      fontWeight: FontWeight.w500, color: Colors.white)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
            ]),
          ),
        ),
      ),
    ]);
  }

  Widget _reviewScreen() {
    return Column(children: [
      // Step dots
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _dot(done: true), const SizedBox(width: 6),
          _dot(done: true), const SizedBox(width: 6),
          _dot(done: true), const SizedBox(width: 6),
          _dot(active: true),
        ]),
      ),
      // Header
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Your study plan',
              style: GoogleFonts.dmSans(fontSize: 18,
                  fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          Text('Here\'s what EduLink will prepare you for.',
              style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
        ]),
      ),
      // Review list
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _selected.length,
        itemBuilder: (_, i) {
          final entry = _selected[i];
          final subject = _getSubject(entry.subjectId)!;
          final exam = subject.exams
              .where((e) => e.id == entry.examId).firstOrNull;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: subject.bg,
              border: Border.all(color: subject.border, width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(subject.emoji,
                    style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(subject.name,
                    style: GoogleFonts.dmSans(fontSize: 14,
                        fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                if (exam != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: exam.tagBg,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(exam.label,
                        style: GoogleFonts.dmSans(
                            fontSize: 10, color: exam.tagColor)),
                  ),
                ],
              ])),
              GestureDetector(
                onTap: () => setState(() {
                  _selected.removeAt(i);
                  _reviewing = false;
                }),
                child: const Icon(Icons.close_rounded,
                    size: 16, color: AppColors.textTertiary),
              ),
            ]),
          );
        },
      )),
      // CTAs
      Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: AppColors.border))),
        child: Column(children: [
          GestureDetector(
            onTap: _saving ? null : _saveAndContinue,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(14)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (_saving)
                  const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                else ...[
                  const Icon(Icons.rocket_launch_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text('Let\'s start learning',
                      style: GoogleFonts.dmSans(fontSize: 14,
                          fontWeight: FontWeight.w500, color: Colors.white)),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _reviewing = false),
            child: Text('← Edit subjects',
                style: GoogleFonts.dmSans(
                    fontSize: 12, color: AppColors.textTertiary)),
          ),
        ]),
      ),
    ]);
  }

  Widget _dot({bool done = false, bool active = false}) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    width: active ? 20 : 6,
    height: 6,
    decoration: BoxDecoration(
      color: active
          ? AppColors.accent
          : done
              ? AppColors.accent.withValues(alpha: 0.4)
              : AppColors.border,
      borderRadius: BorderRadius.circular(3),
    ),
  );
}

}