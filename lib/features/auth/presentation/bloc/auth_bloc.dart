import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/register_with_email.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../../../core/usecases/usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;
  final SignInWithEmail _signInWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final RegisterWithEmail _registerWithEmail;
  final SignOut _signOut;
  StreamSubscription<AppUser?>? _authSubscription;
  AuthBloc({required AuthRepository repository, required SignInWithEmail signInWithEmail, required SignInWithGoogle signInWithGoogle, required RegisterWithEmail registerWithEmail, required SignOut signOut})
      : _repository = repository, _signInWithEmail = signInWithEmail, _signInWithGoogle = signInWithGoogle, _registerWithEmail = registerWithEmail, _signOut = signOut, super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignInWithEmail>(_onSignInWithEmail);
    on<AuthSignInWithGoogle>(_onSignInWithGoogle);
    on<AuthRegister>(_onRegister);
    on<AuthSignOut>(_onSignOut);
    on<AuthSendPasswordReset>(_onPasswordReset);
  }
  void _onStarted(AuthStarted event, Emitter<AuthState> emit) {
    final current = _repository.currentUser;
    if (current != null) { emit(AuthAuthenticated(current)); } else { emit(const AuthUnauthenticated()); }
  }
  Future<void> _onSignInWithEmail(AuthSignInWithEmail event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _signInWithEmail(SignInParams(email: event.email, password: event.password));
    result.fold((f) => emit(AuthError(f.message)), (u) => emit(AuthAuthenticated(u)));
  }
  Future<void> _onSignInWithGoogle(AuthSignInWithGoogle event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _signInWithGoogle(const NoParams());
    result.fold((f) => emit(AuthError(f.message)), (u) => emit(AuthAuthenticated(u)));
  }
  Future<void> _onRegister(AuthRegister event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _registerWithEmail(RegisterParams(name: event.name, email: event.email, password: event.password));
    result.fold((f) => emit(AuthError(f.message)), (u) => emit(AuthAuthenticated(u)));
  }
  Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    await _signOut(const NoParams()); emit(const AuthUnauthenticated());
  }
  Future<void> _onPasswordReset(AuthSendPasswordReset event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _repository.sendPasswordReset(event.email);
    result.fold((f) => emit(AuthError(f.message)), (_) => emit(const AuthPasswordResetSent()));
  }
  @override
  Future<void> close() { _authSubscription?.cancel(); return super.close(); }
}