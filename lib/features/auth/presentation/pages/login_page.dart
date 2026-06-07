import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  void _signIn() {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      _showError('Please enter your email and password.');
      return;
    }
    HapticFeedback.lightImpact();
    context.read<AuthBloc>().add(AuthSignInWithEmail(email: email, password: pass));
  }

  void _signInGoogle() {
    HapticFeedback.lightImpact();
    context.read<AuthBloc>().add(const AuthSignInWithGoogle());
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans(fontSize: 13)),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthAuthenticated) ctx.go('/home');
        if (state is AuthError) _showError(state.message);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 12),
          Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.accentSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.accent, width: 1.5)),
            child: const Icon(Icons.bolt_rounded, color: AppColors.accentLight, size: 24)),
          const SizedBox(height: 18),
          Text('Welcome back', style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('Sign in to continue learning', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textTertiary)),
          const SizedBox(height: 24),

          _label('Email'),
          _field(ctrl: _emailCtrl, hint: 'you@example.com', type: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _label('Password'),
          _passField(),
          Align(alignment: Alignment.centerRight, child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 14),
            child: GestureDetector(onTap: () {}, child: Text('Forgot password?', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.accentLight))),
          )),

          BlocBuilder<AuthBloc, AuthState>(builder: (ctx, state) {
            final loading = state is AuthLoading;
            return GestureDetector(
              onTap: loading ? null : _signIn,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(12)),
                child: Center(child: loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Sign in', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white))),
              ),
            );
          }),
          const SizedBox(height: 16),
          _divider(),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: _signInGoogle,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 18, height: 18, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Center(child: Text('G', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF4285F4))))),
                const SizedBox(width: 8),
                Text('Continue with Google', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary)),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          Center(child: GestureDetector(
            onTap: () => context.go('/register'),
            child: RichText(text: TextSpan(children: [
              TextSpan(text: 'No account? ', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textTertiary)),
              TextSpan(text: 'Sign up', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.accentLight, fontWeight: FontWeight.w500)),
            ])),
          )),
        ]))),
      ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textTertiary)));

  Widget _field({required TextEditingController ctrl, required String hint, TextInputType type = TextInputType.text}) => TextField(
    controller: ctrl, keyboardType: type,
    style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary),
    decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textDisabled),
      filled: true, fillColor: AppColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
  );

  Widget _passField() => TextField(
    controller: _passCtrl, obscureText: _obscure,
    style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textPrimary),
    decoration: InputDecoration(hintText: '••••••••', hintStyle: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textDisabled),
      filled: true, fillColor: AppColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      suffixIcon: GestureDetector(onTap: () => setState(() => _obscure = !_obscure), child: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: AppColors.textDisabled))),
  );

  Widget _divider() => Row(children: [
    Expanded(child: Container(height: 0.5, color: AppColors.border)),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textDisabled))),
    Expanded(child: Container(height: 0.5, color: AppColors.border)),
  ]);
}