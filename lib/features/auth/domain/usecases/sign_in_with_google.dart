import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';
class SignInWithGoogle extends UseCase<AppUser, NoParams> {
  final AuthRepository repository;
  SignInWithGoogle(this.repository);
  @override
  Future<Either<Failure, AppUser>> call(NoParams params) => repository.signInWithGoogle();
}