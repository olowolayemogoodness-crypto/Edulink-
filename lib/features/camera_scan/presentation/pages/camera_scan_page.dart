import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';

const _geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';

class CameraScanPage extends StatefulWidget {
  const CameraScanPage({super.key});
  @override
  State<CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> {
  final _picker = ImagePicker();
  File? _image;
  bool _loading = false;
  String? _question;
  String? _explanation;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;
      setState(() { _image = File(picked.path); _question = null; _explanation = null; _error = null; });
      await _analyzeWithGemini(File(picked.path));
    } catch (e) {
      setState(() => _error = 'Could not access camera. Please check permissions.');
    }
  }

  Future<void> _analyzeWithGemini(File imageFile) async {
    setState(() { _loading = true; _error = null; });
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _geminiApiKey);
      final imageBytes = await imageFile.readAsBytes();
      final prompt = '''You are an expert tutor. Look at this image and:
1. Extract the question or problem shown
2. Provide a clear step-by-step explanation and solution

Format your response exactly like this:
QUESTION: [the question text]
EXPLANATION: [step-by-step solution]''';
      final response = await model.generateContent([
        Content.multi([DataPart('image/jpeg', imageBytes), TextPart(prompt)])
      ]);
      final text = response.text ?? '';
      final qMatch = RegExp(r'QUESTION:\s*(.+?)(?=EXPLANATION:|$)', dotAll: true).firstMatch(text);
      final eMatch = RegExp(r'EXPLANATION:\s*(.+)', dotAll: true).firstMatch(text);
      setState(() {
        _question = qMatch?.group(1)?.trim() ?? 'Question detected';
        _explanation = eMatch?.group(1)?.trim() ?? text;
        _loading = false;
      });
    } catch (e) {
      setState(() { _loading = false; _error = 'Gemini could not read the image. Try better lighting.'; });
    }
  }

  void _reset() => setState(() { _image = null; _question = null; _explanation = null; _error = null; _loading = false; });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(children: [
            GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
            const SizedBox(width: 12),
            Expanded(child: Text('Camera scan', style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
            if (_image != null) GestureDetector(onTap: _reset, child: Text('Reset', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.accentLight))),
          ]),
        ),

        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [

          // Image preview or placeholder
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFF0A0A0C), border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
            child: _image != null
              ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_image!, fit: BoxFit.cover))
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.camera_alt_outlined, size: 36, color: AppColors.textDisabled),
                  const SizedBox(height: 8),
                  Text('Take a photo or choose from gallery', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textDisabled), textAlign: TextAlign.center),
                ]),
          ),
          const SizedBox(height: 16),

          // Loading indicator
          if (_loading) Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentLight)),
              const SizedBox(width: 12),
              Text('Gemini is analysing your question…', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ),

          // Error
          if (_error != null) Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: AppColors.errorSurface, border: Border.all(color: AppColors.error.withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.error),
              const SizedBox(width: 8),
              Expanded(child: Text(_error!, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary))),
            ]),
          ),

          // Result
          if (_question != null && !_loading) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('Question detected', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accentLight)),
                ]),
                const SizedBox(height: 8),
                Text(_question!, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.5)),
                const SizedBox(height: 12),
                Container(height: 0.5, color: AppColors.border),
                const SizedBox(height: 12),
                Row(children: [
                  Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('Gemini explanation', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success)),
                ]),
                const SizedBox(height: 8),
                Text(_explanation!, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary, height: 1.7)),
              ]),
            ),
            const SizedBox(height: 12),
          ],

          // Action buttons
          if (!_loading) ...[
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () { HapticFeedback.mediumImpact(); _pickImage(ImageSource.camera); },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(12)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('Take photo', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  ]),
                ),
              )),
              const SizedBox(width: 10),
              Expanded(child: GestureDetector(
                onTap: () { HapticFeedback.lightImpact(); _pickImage(ImageSource.gallery); },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.photo_library_rounded, color: AppColors.textSecondary, size: 18),
                    const SizedBox(width: 8),
                    Text('Gallery', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary)),
                  ]),
                ),
              )),
            ]),
            const SizedBox(height: 10),
            Text('Point camera at any question — Gemini will extract and explain it', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textDisabled), textAlign: TextAlign.center),
          ],
        ]))),
      ])),
    );
  }
}