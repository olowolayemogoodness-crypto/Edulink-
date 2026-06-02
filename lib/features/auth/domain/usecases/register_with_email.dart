import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';
class RegisterWithEmail extends UseCase<AppUser, RegisterParams> {
  final AuthRepository repository;
  RegisterWithEmail(this.repository);
  @override
  Future<Either<Failure, AppUser>> call(RegisterParams params) => repository.registerWithEmail(params.name, params.email, params.password);
}
class RegisterParams extends Equatable {
  final String name; final String email; final String password;
  const RegisterParams({required this.name, required this.email, required this.password});
  @override
  List<Object> get props => [name, email, password];
}