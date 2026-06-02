import 'package:equatable/equatable.dart';
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}
class AuthStarted extends AuthEvent { const AuthStarted(); }
class AuthSignInWithEmail extends AuthEvent {
  final String email; final String password;
  const AuthSignInWithEmail({required this.email, required this.password});
  @override List<Object> get props => [email, password];
}
class AuthSignInWithGoogle extends AuthEvent { const AuthSignInWithGoogle(); }
class AuthRegister extends AuthEvent {
  final String name; final String email; final String password;
  const AuthRegister({required this.name, required this.email, required this.password});
  @override List<Object> get props => [name, email, password];
}
class AuthSignOut extends AuthEvent { const AuthSignOut(); }
class AuthSendPasswordReset extends AuthEvent {
  final String email;
  const AuthSendPasswordReset(this.email);
  @override List<Object> get props => [email];
}