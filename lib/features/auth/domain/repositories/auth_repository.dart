import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/app_user.dart';
abstract class AuthRepository {
  Future<Either<Failure, AppUser>> signInWithEmail(String email, String password);
  Future<Either<Failure, AppUser>> signInWithGoogle();
  Future<Either<Failure, AppUser>> registerWithEmail(String name, String email, String password);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> sendPasswordReset(String email);
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;
}