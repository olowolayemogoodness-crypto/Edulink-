import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool emailVerified;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.emailVerified,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, emailVerified, createdAt];
}
