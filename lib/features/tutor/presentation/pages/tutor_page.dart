import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

enum _TutorTab { home, chat, camera, history }

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

class _HistorySession {
  final String emoji, title, subtitle, tag, day;
  final Color tagColor, tagBg;
  final int messages;
  const _HistorySession({
    required this.emoji, required this.title, required this.subtitle,
    required this.tag, required this.tagColor, required this.tagBg,
    required this.day, required this.messages,
  });
}

class TutorPage extends StatefulWidget {
  const TutorPage({super.key});
  @override
  State<TutorPage> createState() => _TutorPageState();
}

class _TutorPageState extends State<TutorPage> {
  _TutorTab _tab = _TutorTab.home;
  String _activeSubject = 'all';
  final TextEditingController _homeInputCtrl = TextEditingController();
  final TextEditingController _chatInputCtrl = TextEditingController();
  final ScrollController _chatScroll = ScrollController();
  bool _isTyping = false;
  String _chatTitle = 'Gemini AI Tutor';

  final List<_ChatMessage> _messages = [
    _ChatMessage(text: "I don't understand how Binary Search Trees work. Can you explain insertion?", isUser: true),
    _ChatMessage(text: "Sure! A BST stores values so that for any node, all left children are smaller and all right children are larger.\n\nInsertion: start at the root, go left if your value is smaller, right if larger — repeat until you find an empty spot.", isUser: false),
  ];

  final List<_HistorySession> _history = const [
    _HistorySession(emoji: '🌳', title: 'Binary Search Trees', subtitle: 'Insertion · search · traversal', tag: 'Computer Sci', tagColor: AppColors.accentLight, tagBg: AppColors.accentSurface, day: 'Today', messages: 12),
    _HistorySession(emoji: '✍️', title: 'IELTS Writing Task 2', subtitle: 'Essay format · cohesion · examples', tag: 'IELTS', tagColor: AppColors.success, tagBg: AppColors.successSurface, day: 'Sun', messages: 9),
    _HistorySession(emoji: '🔬', title: 'Photosynthesis explained', subtitle: 'Light reaction · dark reaction · ATP', tag: 'Biology', tagColor: AppColors.textTertiary, tagBg: AppColors.surface, day: 'Sat', messages: 7),
    _HistorySession(emoji: '📐', title: 'Trigonometric identities', subtitle: 'sin · cos · tan · CAST rule', tag: 'Maths', tagColor: Color(0xFFE8960F), tagBg: Color(0xFF2D1E00), day: 'Fri', messages: 15),
  ];

  static const List<Map<String, dynamic>> _topics = [
    {'emoji': '🌳', 'title': 'Binary Search Trees', 'sub': 'Insertion · search · traversal', 'bg': AppColors.accentSurface, 'q': 'Explain what a Binary Search Tree is and how insertion works'},
    {'emoji': '✍️', 'title': 'IELTS Writing Task 2', 'sub': 'Essay structure · arguments · timing', 'bg': AppColors.successSurface, 'q': 'Explain IELTS Writing Task 2 — how should I structure my essay?'},
    {'emoji': '📐', 'title': 'Trigonometric identities', 'sub': 'sin · cos · tan · CAST rule', 'bg': Color(0xFF2D1E00), 'q': 'Explain trigonometric identities: sin, cos and tan with examples.'},
    {'emoji': '🌱', 'title': 'Photosynthesis', 'sub': 'Light reaction · Calvin cycle', 'bg': AppColors.successSurface, 'q': 'Explain photosynthesis step by step in a way that is easy to understand'},
  ];

  static const _aiReplies = [
    "BST search is O(log n) for a balanced tree. You compare the target with the current node and go left if smaller, right if larger — the tree halves the search space at each step.",
    "BST deletion has three cases: a leaf (just remove it), a node with one child (replace with child), and a node with two children (replace with its in-order successor).",
    "A balanced BST keeps height at O(log n). Examples are AVL trees and Red-Black trees. Without balancing, sorted insertions create a skewed tree where search degrades to O(n).",
    "Great question! Let me break that down for you step by step.",
    "That's a common area of confusion — here's how to think about it.",
    "Exactly right! Here's a deeper explanation with an example.",
  ];
  int _replyIdx = 0;

  bool _camScanning = false, _camDone = false, _camError = false, _flashOn = false;
  String _camStatus = 'Snap a question';
  String _camLabel = 'Gemini is reading…';
  final _camLabels = const ['Gemini is reading…', 'Identifying question…', 'Extracting text…', 'Generating explanation…'];

  @override
  void dispose() {
    _homeInputCtrl.dispose();
    _chatInputCtrl.dispose();
    _chatScroll.dispose();
    super.dispose();
  }

  void _go(_TutorTab tab) {
    HapticFeedback.selectionClick();
    setState(() => _tab = tab);
    if (tab == _TutorTab.camera) _resetCam();
  }

  void _startChat(String q) {
    if (q.trim().isEmpty) return;
    setState(() {
      _chatTitle = q.length > 30 ? '${q.substring(0, 30)}…' : q;
      _messages.clear();
      _messages.add(_ChatMessage(text: q, isUser: true));
      _isTyping = true;
      _tab = _TutorTab.chat;
    });
    _homeInputCtrl.clear();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(text: _aiReplies[_replyIdx++ % _aiReplies.length], isUser: false));
      });
      _scrollDown();
    });
  }

  void _sendMsg() {
    final t = _chatInputCtrl.text.trim();
    if (t.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(_ChatMessage(text: t, isUser: true));
      _isTyping = true;
    });
    _chatInputCtrl.clear();
    _scrollDown();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(text: _aiReplies[_replyIdx++ % _aiReplies.length], isUser: false));
      });
      _scrollDown();
    });
  }

  void _scrollDown() => Future.delayed(const Duration(milliseconds: 100), () {
    if (_chatScroll.hasClients) {
      _chatScroll.animateTo(_chatScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  });

  void _resetCam() => setState(() {
    _camScanning = false; _camDone = false; _camError = false;
    _camStatus = 'Snap a question'; _camLabel = _camLabels[0];
  });

  void _shoot() {
    if (_camScanning || _camDone) return;
    HapticFeedback.mediumImpact();
    setState(() { _camScanning = true; _camStatus = 'Analysing…'; _camLabel = _camLabels[0]; });
    for (int i = 1; i < _camLabels.length; i++) {
      Future.delayed(Duration(milliseconds: 900 * i), () {
        if (mounted && _camScanning) setState(() => _camLabel = _camLabels[i]);
      });
    }
    Future.delayed(const Duration(milliseconds: 3800), () {
      if (!mounted) return;
      final err = DateTime.now().millisecond % 5 == 0;
      setState(() {
        _camScanning = false; _camDone = true; _camError = err;
        _camStatus = err ? 'Could not read' : 'Question found!';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    switch (_tab) {
      case _TutorTab.home:    return _home();
      case _TutorTab.chat:    return _chat();
      case _TutorTab.camera:  return _camera();
      case _TutorTab.history: return _historyScreen();
    }
  }

  // ══════════════════════════════════════════
  // HOME
  // ══════════════════════════════════════════
  Widget _home() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Tutor', style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Row(children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text('Gemini · always available', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),
            ]),
          ])),
          Row(children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.textTertiary)),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _go(_TutorTab.history),
          child: Container(width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.history_rounded, size: 18, color: AppColors.textTertiary)),
        ),
      ]),
        ]),
      ),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Greeting card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.accentSurface, border: Border.all(color: const Color(0xFF3D2580)), borderRadius: BorderRadius.circular(18)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 44, height: 44,
                decoration: const BoxDecoration(color: Color(0xFF3D2580), shape: BoxShape.circle),
                child: const Icon(Icons.smart_toy_rounded, size: 22, color: AppColors.accentLight)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Hey Adaeze, I'm your AI tutor", style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text("Ask me anything — a concept, a past question, or snap a photo and I'll explain it step by step.",
                    style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.accentLight, height: 1.6)),
              ])),
            ]),
          ),
          const SizedBox(height: 18),

          // Subject pills
          Text('ASK ABOUT', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _pill('all', '✨', 'All subjects'),
              _pill('math', '📐', 'Maths'),
              _pill('eng', '📝', 'English'),
              _pill('sci', '🔬', 'Science'),
              _pill('ielts', '🌍', 'IELTS'),
            ]),
          ),
          const SizedBox(height: 18),

          // Suggested topics
          Text('SUGGESTED TOPICS', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          ..._topics.map((t) => GestureDetector(
            onTap: () => _startChat(t['q'] as String),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Container(width: 38, height: 38,
                  decoration: BoxDecoration(color: t['bg'] as Color, borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text(t['emoji'] as String, style: const TextStyle(fontSize: 18)))),
                const SizedBox(width: 11),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t['title'] as String, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                  Text(t['sub'] as String, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
                ])),
                const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textDisabled),
              ]),
            ),
          )),

          // Camera CTA
          GestureDetector(
            onTap: () => _go(_TutorTab.camera),
            child: Container(
              padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: AppColors.errorSurface,
                border: Border.all(color: AppColors.error.withOpacity(0.6), width: 1.5),
                borderRadius: BorderRadius.circular(18)),
              child: Row(children: [
                Container(width: 42, height: 42,
                  decoration: BoxDecoration(color: const Color(0xFF3D1500), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.camera_alt_rounded, size: 22, color: AppColors.error)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Snap a question', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error)),
                  Text('Take a photo of any past question — Gemini will solve and explain it',
                      style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary, height: 1.5)),
                ])),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.error),
              ]),
            ),
          ),
        ]),
      )),
      _inputBar(ctrl: _homeInputCtrl, hint: 'Ask Gemini anything…', onSend: () => _startChat(_homeInputCtrl.text), onCam: () => _go(_TutorTab.camera)),
    ]);
  }

  Widget _pill(String key, String emoji, String label) {
    final on = _activeSubject == key;
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); setState(() => _activeSubject = key); },
      child: Container(
        margin: const EdgeInsets.only(right: 7),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: on ? AppColors.accentSurface : AppColors.surface,
          border: Border.all(color: on ? AppColors.accent : AppColors.border, width: on ? 1.5 : 1),
          borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: on ? AppColors.accentLight : AppColors.textTertiary)),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════
  // CHAT
  // ══════════════════════════════════════════
  Widget _chat() {
    return Column(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(children: [
          GestureDetector(onTap: () => _go(_TutorTab.home), child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
          const SizedBox(width: 10),
          Container(width: 36, height: 36,
            decoration: const BoxDecoration(color: AppColors.accentSurface, shape: BoxShape.circle),
            child: const Icon(Icons.smart_toy_rounded, size: 18, color: AppColors.accentLight)),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_chatTitle, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Row(children: [
              Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text('Online', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.success)),
            ]),
          ])),
          _iBtn(Icons.camera_alt_rounded, () => _go(_TutorTab.camera)),
          const SizedBox(width: 6),
          _iBtn(Icons.more_horiz_rounded, () {}),
        ]),
      ),
      Expanded(child: ListView.builder(
        controller: _chatScroll,
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 8),
        itemCount: _messages.length + (_isTyping ? 1 : 0),
        itemBuilder: (ctx, i) => i == _messages.length ? _typingBubble() : _bubble(_messages[i]),
      )),
      if (_messages.length >= 2 && !_isTyping)
        Padding(
          padding: const EdgeInsets.fromLTRB(46, 0, 14, 6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: ['Explain more', 'Give an example', 'Test me on this', 'Summarise'].map((c) =>
              GestureDetector(
                onTap: () { _chatInputCtrl.text = c; _sendMsg(); },
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.accentSurface, border: Border.all(color: const Color(0xFF3D2580)), borderRadius: BorderRadius.circular(20)),
                  child: Text(c, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.accentLight)),
                ),
              ),
            ).toList()),
          ),
        ),
      _inputBar(ctrl: _chatInputCtrl, hint: 'Ask a follow-up…', onSend: _sendMsg, onCam: () => _go(_TutorTab.camera)),
    ]);
  }

  Widget _bubble(_ChatMessage m) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: m.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: m.isUser ? [
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 240),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentSurface,
                border: Border.all(color: const Color(0xFF3D2580)),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(4))),
              child: Text(m.text, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.accentLight, height: 1.6)),
            ),
            const SizedBox(height: 2),
            Text('just now', style: GoogleFonts.dmSans(fontSize: 8, color: AppColors.textDisabled)),
          ]),
          const SizedBox(width: 7),
          Container(width: 26, height: 26,
            decoration: const BoxDecoration(color: AppColors.accentSurface, shape: BoxShape.circle),
            child: Center(child: Text('AO', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.accentLight, fontWeight: FontWeight.w600)))),
        ] : [
          Container(width: 26, height: 26,
            decoration: const BoxDecoration(color: AppColors.accentSurface, shape: BoxShape.circle),
            child: const Icon(Icons.smart_toy_rounded, size: 14, color: AppColors.accentLight)),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 240),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: const Color(0xFF3D2580)),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(4), bottomRight: Radius.circular(16))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text('Gemini', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.accentLight)),
                ]),
                const SizedBox(height: 6),
                Text(m.text, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textSecondary, height: 1.7)),
              ]),
            ),
            const SizedBox(height: 2),
            Text('just now', style: GoogleFonts.dmSans(fontSize: 8, color: AppColors.textDisabled)),
          ]),
        ],
      ),
    );
  }

  Widget _typingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(width: 26, height: 26,
          decoration: const BoxDecoration(color: AppColors.accentSurface, shape: BoxShape.circle),
          child: const Icon(Icons.smart_toy_rounded, size: 14, color: AppColors.accentLight)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
          child: Row(children: List.generate(3, (i) => _Dot(delay: Duration(milliseconds: i * 150)))),
        ),
      ]),
    );
  }

  Widget _iBtn(IconData icon, VoidCallback fn) => GestureDetector(
    onTap: fn,
    child: Container(width: 32, height: 32,
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(9)),
      child: Icon(icon, size: 16, color: AppColors.textTertiary)),
  );

  // ══════════════════════════════════════════
  // CAMERA
  // ══════════════════════════════════════════
  Widget _camera() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Row(children: [
          GestureDetector(onTap: () => _go(_TutorTab.home), child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
          const SizedBox(width: 12),
          Expanded(child: Text(_camStatus, style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
          GestureDetector(
            onTap: () { setState(() => _flashOn = !_flashOn); HapticFeedback.selectionClick(); },
            child: Container(width: 34, height: 34,
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.flash_on_rounded, size: 18, color: _flashOn ? const Color(0xFFFFD700) : AppColors.textTertiary)),
          ),
        ]),
      ),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(children: [
          // Viewfinder
          Container(
            height: 220,
            decoration: BoxDecoration(color: const Color(0xFF0A0A0C), border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
            child: Stack(children: [
              if (!_camDone) CustomPaint(size: const Size(double.infinity, 220), painter: _GridPainter()),
              Center(child: SizedBox(width: 200, height: 160, child: Stack(children: [
                _corner(top: 0, left: 0, tl: true),
                _corner(top: 0, right: 0, tr: true),
                _corner(bottom: 0, left: 0, bl: true),
                _corner(bottom: 0, right: 0, br: true),
                if (_camScanning) const Positioned(left: 0, right: 0, child: _ScanBar()),
              ]))),
              if (!_camScanning && !_camDone) Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.camera_alt_outlined, size: 32, color: AppColors.textDisabled),
                const SizedBox(height: 8),
                Text('Position question inside frame', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textDisabled)),
              ])),
              if (_camScanning) Positioned(bottom: 12, left: 0, right: 0, child: Center(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(color: AppColors.background.withOpacity(0.85), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.accentLight)),
                  const SizedBox(width: 8),
                  Text(_camLabel, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textSecondary)),
                ]),
              ))),
              if (_camDone && !_camError) Center(child: Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: AppColors.successSurface, shape: BoxShape.circle, border: Border.all(color: AppColors.success)),
                child: const Icon(Icons.check_rounded, color: AppColors.success, size: 28))),
            ]),
          ),
          const SizedBox(height: 16),
          if (!_camDone) Text('Tap the button below to scan your question', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary)),

          // Result card
          if (_camDone && !_camError) ...[
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
                Text('If sin θ = 3/5 and θ is acute, find (sin θ + cos θ) / tan θ',
                    style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.5)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: GestureDetector(
                    onTap: () => _startChat('Solve: If sin θ = 3/5 and θ is acute, find (sin θ + cos θ) / tan θ'),
                    child: Container(padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text('Solve with Gemini', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)))),
                  )),
                  const SizedBox(width: 8),
                  GestureDetector(onTap: _resetCam, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                    child: Text('Retry', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary)))),
                ]),
              ]),
            ),
          ],

          // Error card
          if (_camDone && _camError) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.errorSurface, border: Border.all(color: AppColors.error.withOpacity(0.5)), borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                Text('Could not read the question. Make sure the text is clear and well-lit.',
                    style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
                const SizedBox(height: 12),
                GestureDetector(onTap: _resetCam, child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text('Try again', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary))))),
              ]),
            ),
          ],
          const SizedBox(height: 20),
          if (!_camDone) GestureDetector(
            onTap: _shoot,
            child: Container(width: 68, height: 68,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: _camScanning ? AppColors.surface : AppColors.accent,
                border: Border.all(color: _camScanning ? AppColors.border : AppColors.accentLight.withOpacity(0.4), width: 3)),
              child: Icon(_camScanning ? Icons.hourglass_top_rounded : Icons.camera_alt_rounded, color: Colors.white, size: 28)),
          ),
        ]),
      )),
    ]);
  }

  Widget _corner({double? top, double? bottom, double? left, double? right,
      bool tl = false, bool tr = false, bool bl = false, bool br = false}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(width: 20, height: 20, decoration: BoxDecoration(border: Border(
        top: (tl || tr) ? const BorderSide(color: AppColors.accent, width: 2) : BorderSide.none,
        bottom: (bl || br) ? const BorderSide(color: AppColors.accent, width: 2) : BorderSide.none,
        left: (tl || bl) ? const BorderSide(color: AppColors.accent, width: 2) : BorderSide.none,
        right: (tr || br) ? const BorderSide(color: AppColors.accent, width: 2) : BorderSide.none,
      ))),
    );
  }

  // ══════════════════════════════════════════
  // HISTORY
  // ══════════════════════════════════════════
  Widget _historyScreen() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(children: [
          GestureDetector(onTap: () => _go(_TutorTab.home), child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
          const SizedBox(width: 12),
          Text('Session History', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ]),
      ),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _history.length,
        itemBuilder: (ctx, i) {
          final s = _history[i];
          return GestureDetector(
            onTap: () => _go(_TutorTab.chat),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 34, height: 34,
                  decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(9)),
                  child: Center(child: Text(s.emoji, style: const TextStyle(fontSize: 16)))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.title, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                  Text(s.subtitle, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: s.tagBg, border: Border.all(color: s.tagColor.withOpacity(0.5)), borderRadius: BorderRadius.circular(20)),
                      child: Text(s.tag, style: GoogleFonts.dmSans(fontSize: 9, color: s.tagColor))),
                    const SizedBox(width: 7),
                    Text('${s.day} · ${s.messages} messages', style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textDisabled)),
                  ]),
                ])),
                const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textDisabled),
              ]),
            ),
          );
        },
      )),
    ]);
  }

  // ══════════════════════════════════════════
  // SHARED INPUT BAR
  // ══════════════════════════════════════════
  Widget _inputBar({required TextEditingController ctrl, required String hint, required VoidCallback onSend, required VoidCallback onCam}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(children: [
        GestureDetector(onTap: onCam, child: Container(width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
          child: const Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.textTertiary))),
        const SizedBox(width: 8),
        Expanded(child: TextField(
          controller: ctrl,
          style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textTertiary),
            filled: true, fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: AppColors.accentDark)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          onSubmitted: (_) => onSend(),
        )),
        const SizedBox(width: 8),
        GestureDetector(onTap: onSend, child: Container(width: 36, height: 36,
          decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
          child: const Icon(Icons.send_rounded, size: 16, color: Colors.white))),
      ]),
    );
  }
}

// ── Typing dot animation ──
class _Dot extends StatefulWidget {
  final Duration delay;
  const _Dot({required this.delay});
  @override State<_Dot> createState() => _DotState();
}
class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _a = Tween(begin: 0.0, end: -5.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
    Future.delayed(widget.delay, () { if (mounted) _c.forward(); });
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    builder: (_, __) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 7, height: 7,
      decoration: const BoxDecoration(color: AppColors.accentLight, shape: BoxShape.circle),
      transform: Matrix4.translationValues(0, _a.value, 0),
    ),
  );
}

// ── Scan sweep bar animation ──
class _ScanBar extends StatefulWidget {
  const _ScanBar();
  @override State<_ScanBar> createState() => _ScanBarState();
}
class _ScanBarState extends State<_ScanBar> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
    _a = Tween(begin: 0.0, end: 148.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    builder: (_, __) => Positioned(
      top: _a.value, left: 0, right: 0,
      child: Container(height: 1.5, decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.transparent, AppColors.accent.withOpacity(0.8), Colors.transparent]))),
    ),
  );
}

// ── Viewfinder grid painter ──
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF1E1E24)..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += size.width / 3) canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += size.height / 3) canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }
  @override bool shouldRepaint(_) => false;
}