import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _SettingsTab { main, editProfile, notifications, privacy }

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});
  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  _SettingsTab _tab = _SettingsTab.main;

  // Notification toggles
  bool _togRemind = true, _togStreak = true, _togSchol = true;
  bool _togDuel = true, _togRoom = true, _togRank = false;
  bool _togAI = true, _togOffline = false;

  // Privacy toggles
  bool _togPublicProfile = true, _togShowStreak = true, _togShowRank = true;
  bool _togShowActivity = false, _togAllowDuel = true, _togAllowRoom = true;

  // Edit profile controllers
  late final TextEditingController _nameCtrl = TextEditingController(text: _displayName);
  late final TextEditingController _bioCtrl = TextEditingController();
  late final TextEditingController _schoolCtrl = TextEditingController();
  late final TextEditingController _courseCtrl = TextEditingController();
  void _go(_SettingsTab tab) { HapticFeedback.selectionClick(); setState(() => _tab = tab); }

  String get _displayName {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user.displayName : 'User';
  }

  String get _email {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user.email : '';
  }

  String get _initials {
    final name = _displayName;
    return name.trim().split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0].toUpperCase()).join();
  }

  void _signOut() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Sign out?', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      content: Text('You will be signed out of your account.', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textTertiary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.dmSans(color: AppColors.textTertiary))),
       TextButton(onPressed: () async {
          Navigator.pop(ctx);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('has_onboarded', false);
          if (context.mounted) context.read<AuthBloc>().add(const AuthSignOut());
          if (context.mounted) context.go('/onboarding');
        }, child: Text('Sign out', style: GoogleFonts.dmSans(color: const Color(0xFFE8960F), fontWeight: FontWeight.w500))),
      ],
    ));
  }

  void _deleteAccount() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Delete account?', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.error)),
      content: Text('This will permanently delete all your data including streaks, XP and progress. This cannot be undone.', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textTertiary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.dmSans(color: AppColors.textTertiary))),
        TextButton(onPressed: () { Navigator.pop(ctx); }, child: Text('Delete', style: GoogleFonts.dmSans(color: AppColors.error, fontWeight: FontWeight.w500))),
      ],
    ));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _schoolCtrl.dispose();
    _courseCtrl.dispose();
    super.dispose();
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
      case _SettingsTab.main:         return _mainSettings();
      case _SettingsTab.editProfile:  return _editProfile();
      case _SettingsTab.notifications: return _notifications();
      case _SettingsTab.privacy:      return _privacy();
    }
  }

  // ══════════════════════════════════════════
  // MAIN SETTINGS
  // ══════════════════════════════════════════
  Widget _mainSettings() => Column(children: [
    _header('Settings', onBack: () => context.pop()),
    Expanded(child: SingleChildScrollView(child: Column(children: [

      // Account switcher
      _sectionLabel('Accounts'),
      _card([
        _accountRow(_initials, _displayName, _email, true),
        _divider(),
        _srow(Icons.add_circle_outline_rounded, AppColors.surfaceVariant, AppColors.textTertiary, 'Add another account', '', onTap: () {}),
      ]),

      // Profile & account
      _sectionLabel('Profile & account'),
      _card([
        _srow(Icons.person_outline_rounded, AppColors.accentSurface, AppColors.accentLight, 'Edit profile', 'Name, bio, school, photo', onTap: () => _go(_SettingsTab.editProfile)),
        _divider(),
        _srow(Icons.lock_outline_rounded, AppColors.surfaceVariant, AppColors.textSecondary, 'Change password', 'Last changed 3 months ago', onTap: () {}),
        _divider(),
        _srow(Icons.mail_outline_rounded, AppColors.surfaceVariant, AppColors.textSecondary, 'Email & phone', _email, onTap: () {}),
        _divider(),
        _srow(Icons.workspace_premium_rounded, const Color(0xFF2D1E00), const Color(0xFFE8960F), 'Subscription', 'Free tier · Upgrade to Premium', onTap: () {}, trailing: _pill('Upgrade', const Color(0xFF2D1E00), const Color(0xFFE8960F), const Color(0xFFC47D0E))),
      ]),

      // Preferences
      _sectionLabel('Preferences'),
      _card([
        _srow(Icons.notifications_none_rounded, AppColors.surfaceVariant, AppColors.textSecondary, 'Notifications', 'Streaks, duels, study reminders', onTap: () => _go(_SettingsTab.notifications)),
        _divider(),
        _srow(Icons.shield_outlined, AppColors.surfaceVariant, AppColors.textSecondary, 'Privacy', 'Who can see your profile', onTap: () => _go(_SettingsTab.privacy)),
        _divider(),
        _srow(Icons.palette_outlined, AppColors.surfaceVariant, AppColors.textSecondary, 'Appearance', 'Dark mode · Font size', onTap: () {}, trailing: Text('Dark', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary))),
        _divider(),
        _srow(Icons.language_rounded, AppColors.surfaceVariant, AppColors.textSecondary, 'Language', 'App display language', onTap: () {}, trailing: Text('English', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary))),
      ]),

      // Study & learning
      _sectionLabel('Study & learning'),
      _card([
        _srow(Icons.track_changes_rounded, AppColors.accentSurface, AppColors.accentLight, 'Daily study goal', 'Currently 4 hours', onTap: () {}, trailing: Text('4h', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textTertiary))),
        _divider(),
        _srow(Icons.psychology_rounded, AppColors.successSurface, AppColors.success, 'Gemini AI settings', 'Explanation depth, language', onTap: () {}),
        _divider(),
        _srow(Icons.phone_android_rounded, AppColors.surfaceVariant, AppColors.textSecondary, 'Offline mode', 'Download content for offline use', onTap: () {}, trailing: _toggle(_togOffline, () => setState(() => _togOffline = !_togOffline))),
      ]),

      // Support
      _sectionLabel('Support'),
      _card([
        _srow(Icons.help_outline_rounded, AppColors.surfaceVariant, AppColors.textSecondary, 'Help & FAQ', '', onTap: () {}),
        _divider(),
        _srow(Icons.chat_bubble_outline_rounded, AppColors.surfaceVariant, AppColors.textSecondary, 'Contact support', '', onTap: () {}),
        _divider(),
        _srow(Icons.star_outline_rounded, AppColors.surfaceVariant, AppColors.textSecondary, 'Rate EduLink', '', onTap: () {}),
        _divider(),
        _srow(Icons.info_outline_rounded, AppColors.surfaceVariant, AppColors.textSecondary, 'About EduLink', 'Version 1.0.0 · Build 1', onTap: () {}),
      ]),

      // Account actions
      _sectionLabel('Account actions'),
      _card([
        _srow(Icons.logout_rounded, const Color(0xFF2D1E00), const Color(0xFFE8960F), 'Sign out', _email, onTap: _signOut, titleColor: const Color(0xFFE8960F)),
        _divider(),
        _srow(Icons.delete_outline_rounded, AppColors.errorSurface, AppColors.error, 'Delete account', 'Permanently remove all data', onTap: _deleteAccount, titleColor: AppColors.error),
      ]),
      const SizedBox(height: 20),
    ]))),
  ]);

  // ══════════════════════════════════════════
  // EDIT PROFILE
  // ══════════════════════════════════════════
  Widget _editProfile() {
    final nameCtrl = _nameCtrl;
    final bioCtrl = _bioCtrl;
    final schoolCtrl = _schoolCtrl;
    final courseCtrl = _courseCtrl;

    return Column(children: [
      _header('Edit profile', onBack: () => _go(_SettingsTab.main), action: GestureDetector(
        onTap: () async {
          HapticFeedback.lightImpact();
          await UserService.updateDisplayName(nameCtrl.text.trim());
          await UserService.updateProfile(bio: bioCtrl.text.trim(), school: schoolCtrl.text.trim(), course: courseCtrl.text.trim());
          if (mounted) context.read<AuthBloc>().add(const AuthStarted());
          if (mounted) _go(_SettingsTab.main);
        },
        child: Text('Save', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.accentLight)),
      )),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(14), child: Column(children: [
        // Avatar
        Column(children: [
          Stack(children: [
            Container(width: 76, height: 76, decoration: BoxDecoration(color: AppColors.accentSurface, shape: BoxShape.circle, border: Border.all(color: AppColors.accent, width: 3)),
              child: Center(child: Text(_initials, style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.accentLight)))),
            Positioned(bottom: 0, right: 0, child: Container(width: 26, height: 26, decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle, border: Border.all(color: AppColors.background, width: 2)),
              child: const Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white))),
          ]),
          const SizedBox(height: 6),
          Text('Change photo', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.accentLight)),
        ]),
        const SizedBox(height: 20),

        _editField('Display name', nameCtrl),
        const SizedBox(height: 10),
        _editFieldMultiline('Bio', bioCtrl),
        const SizedBox(height: 10),
        _editField('School / University', schoolCtrl),
        const SizedBox(height: 10),
        _editField('Course / Field', courseCtrl),
        const SizedBox(height: 10),

        // Country picker
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Country', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textTertiary, letterSpacing: 0.5)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Text('🇳🇬 Nigeria', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary)),
              const Spacer(),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textTertiary),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
      ]))),
    ]);
  }

  Widget _editField(String label, TextEditingController ctrl) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textTertiary, letterSpacing: 0.5)),
    const SizedBox(height: 5),
    TextField(controller: ctrl, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent)), contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11))),
  ]);

  Widget _editFieldMultiline(String label, TextEditingController ctrl) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textTertiary, letterSpacing: 0.5)),
    const SizedBox(height: 5),
    TextField(controller: ctrl, maxLines: 3, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent)), contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11))),
  ]);

  // ══════════════════════════════════════════
  // NOTIFICATIONS
  // ══════════════════════════════════════════
  Widget _notifications() => Column(children: [
    _header('Notifications', onBack: () => _go(_SettingsTab.main)),
    Expanded(child: SingleChildScrollView(child: Column(children: [
      _sectionLabel('Study reminders'),
      _card([
        _srow(Icons.alarm_rounded, AppColors.accentSurface, AppColors.accentLight, 'Daily study reminder', '8:00 PM every day', onTap: (){}, trailing: _toggle(_togRemind, () => setState(() => _togRemind = !_togRemind))),
        _divider(),
        _srow(Icons.local_fire_department_rounded, AppColors.errorSurface, AppColors.error, 'Streak at risk', 'Alert before streak breaks', onTap: (){}, trailing: _toggle(_togStreak, () => setState(() => _togStreak = !_togStreak))),
        _divider(),
        _srow(Icons.emoji_events_rounded, const Color(0xFF2D1E00), const Color(0xFFE8960F), 'Scholarship deadlines', '7 days and 1 day before', onTap: (){}, trailing: _toggle(_togSchol, () => setState(() => _togSchol = !_togSchol))),
      ]),
      _sectionLabel('Social & duels'),
      _card([
        _srow(Icons.sports_kabaddi_rounded, AppColors.errorSurface, AppColors.error, 'Duel challenges', 'When someone challenges you',  onTap: (){}, trailing: _toggle(_togDuel, () => setState(() => _togDuel = !_togDuel))),
        _divider(),
        _srow(Icons.groups_rounded, AppColors.successSurface, AppColors.success, 'Study room invites', 'When friends open a room', onTap: (){}, trailing: _toggle(_togRoom, () => setState(() => _togRoom = !_togRoom))),
        _divider(),
        _srow(Icons.leaderboard_rounded, AppColors.surfaceVariant, AppColors.textSecondary, 'Leaderboard changes', 'When your rank changes', onTap: (){}, trailing: _toggle(_togRank, () => setState(() => _togRank = !_togRank))),
      ]),
      _sectionLabel('Gemini & AI'),
      _card([
        _srow(Icons.psychology_rounded, AppColors.accentSurface, AppColors.accentLight, 'Gemini weekly insights', 'Performance report every Monday', onTap: (){}, trailing: _toggle(_togAI, () => setState(() => _togAI = !_togAI))),
      ]),
      const SizedBox(height: 20),
    ]))),
  ]);

  // ══════════════════════════════════════════
  // PRIVACY
  // ══════════════════════════════════════════
  Widget _privacy() => Column(children: [
    _header('Privacy', onBack: () => _go(_SettingsTab.main)),
    Expanded(child: SingleChildScrollView(child: Column(children: [
      _sectionLabel('Profile visibility'),
      _card([
        _srow(Icons.public_rounded, AppColors.accentSurface, AppColors.accentLight, 'Public profile', 'Anyone can view your profile', onTap: (){}, trailing: _toggle(_togPublicProfile, () => setState(() => _togPublicProfile = !_togPublicProfile))),
        _divider(),
        _srow(Icons.local_fire_department_rounded, AppColors.errorSurface, AppColors.error, 'Show streak', 'Display your streak publicly', onTap: (){}, trailing: _toggle(_togShowStreak, () => setState(() => _togShowStreak = !_togShowStreak))),
        _divider(),
        _srow(Icons.leaderboard_rounded, AppColors.surfaceVariant, AppColors.textSecondary, 'Show rank', 'Display your rank on leaderboard', onTap: (){}, trailing: _toggle(_togShowRank, () => setState(() => _togShowRank = !_togShowRank))),
        _divider(),
        _srow(Icons.bar_chart_rounded, AppColors.surfaceVariant, AppColors.textSecondary, 'Show activity', 'Share study activity with friends', onTap: (){}, trailing: _toggle(_togShowActivity, () => setState(() => _togShowActivity = !_togShowActivity))),
      ]),
      _sectionLabel('Interactions'),
      _card([
        _srow(Icons.sports_kabaddi_rounded, AppColors.errorSurface, AppColors.error, 'Allow duel challenges', 'Friends can challenge you', onTap: (){}, trailing: _toggle(_togAllowDuel, () => setState(() => _togAllowDuel = !_togAllowDuel))),
        _divider(),
        _srow(Icons.meeting_room_rounded, AppColors.successSurface, AppColors.success, 'Allow room invites', 'Friends can invite you to rooms', onTap: (){}, trailing: _toggle(_togAllowRoom, () => setState(() => _togAllowRoom = !_togAllowRoom))),
      ]),
      const SizedBox(height: 20),
    ]))),
  ]);

  // ══════════════════════════════════════════
  // SHARED WIDGETS
  // ══════════════════════════════════════════
  Widget _header(String title, {required VoidCallback onBack, Widget? action}) => Container(
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
    child: Row(children: [
      GestureDetector(onTap: onBack, child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textTertiary)),
      const SizedBox(width: 12),
      Expanded(child: Text(title, style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
      if (action != null) action,
    ]),
  );

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
    child: Text(label.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textDisabled, letterSpacing: 0.6)),
  );

  Widget _card(List<Widget> children) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
    child: Column(children: children),
  );

  Widget _srow(IconData icon, Color iconBg, Color iconColor, String title, String sub, {required VoidCallback onTap, Widget? trailing, Color? titleColor}) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: Colors.transparent,
      child: Row(children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 17, color: iconColor)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: titleColor ?? AppColors.textPrimary)),
          if (sub.isNotEmpty) Text(sub, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary, height: 1.4)),
        ])),
        if (trailing != null) trailing
        else const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textDisabled),
      ]),
    ),
  );

  Widget _accountRow(String initials, String name, String email, bool active) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(color: active ? AppColors.accentSurface : Colors.transparent, borderRadius: BorderRadius.circular(12), border: active ? Border.all(color: const Color(0xFF2D1B6B), width: 0.5) : null),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.accentSurface, shape: BoxShape.circle, border: Border.all(color: active ? AppColors.accent : AppColors.border, width: 2)),
        child: Center(child: Text(initials, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.accentLight)))),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        Text('$email · Active', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textTertiary)),
      ])),
      if (active) Container(width: 18, height: 18, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, size: 10, color: Colors.white)),
    ]),
  );

  Widget _divider() => Container(height: 0.5, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 14));

  Widget _toggle(bool val, VoidCallback onTap) => GestureDetector(
    onTap: () { HapticFeedback.selectionClick(); onTap(); },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 40, height: 22,
      decoration: BoxDecoration(color: val ? AppColors.accent : AppColors.surfaceVariant, borderRadius: BorderRadius.circular(11)),
      child: AnimatedAlign(duration: const Duration(milliseconds: 200), alignment: val ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(margin: const EdgeInsets.all(2), width: 18, height: 18, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))),
    ),
  );

  Widget _pill(String label, Color bg, Color tc, Color border) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bg, border: Border.all(color: border), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w500, color: tc)),
  );
}