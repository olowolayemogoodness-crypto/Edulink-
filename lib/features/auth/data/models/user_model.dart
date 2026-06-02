import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../domain/entities/app_user.dart';
class UserModel extends AppUser {
  const UserModel({required super.uid, required super.email, required super.displayName, super.photoUrl, required super.emailVerified, required super.createdAt});
  factory UserModel.fromFirebase(fb.User user) => UserModel(
    uid: user.uid, email: user.email ?? '',
    displayName: user.displayName ?? user.email?.split('@').first ?? 'Student',
    photoUrl: user.photoURL, emailVerified: user.emailVerified,
    createdAt: user.metadata.creationTime ?? DateTime.now());
}