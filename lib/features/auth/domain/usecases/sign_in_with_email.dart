import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';
class SignInWithEmail extends UseCase<AppUser, SignInParams> {
  final AuthRepository repository;
  SignInWithEmail(this.repository);
  @override
  Future<Either<Failure, AppUser>> call(SignInParams params) => repository.signInWithEmail(params.email, params.password);
}
class SignInParams extends Equatable {
  final String email;
  final String password;
  const SignInParams({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}