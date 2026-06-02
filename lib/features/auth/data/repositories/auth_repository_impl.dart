import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl(this.remoteDataSource);
  @override
  Future<Either<Failure, AppUser>> signInWithEmail(String email, String password) async {
    try { return Right(await remoteDataSource.signInWithEmail(email, password));
    } on AuthFailure catch (e) { return Left(e); } catch (_) { return const Left(ServerFailure()); }
  }
  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try { return Right(await remoteDataSource.signInWithGoogle());
    } on AuthFailure catch (e) { return Left(e); } catch (_) { return const Left(ServerFailure()); }
  }
  @override
  Future<Either<Failure, AppUser>> registerWithEmail(String name, String email, String password) async {
    try { return Right(await remoteDataSource.registerWithEmail(name, email, password));
    } on AuthFailure catch (e) { return Left(e); } catch (_) { return const Left(ServerFailure()); }
  }
  @override
  Future<Either<Failure, void>> signOut() async {
    try { await remoteDataSource.signOut(); return const Right(null);
    } catch (_) { return const Left(ServerFailure()); }
  }
  @override
  Future<Either<Failure, void>> sendPasswordReset(String email) async {
    try { await remoteDataSource.sendPasswordReset(email); return const Right(null);
    } on AuthFailure catch (e) { return Left(e); } catch (_) { return const Left(ServerFailure()); }
  }
  @override
  Stream<AppUser?> get authStateChanges => remoteDataSource.authStateChanges;
  @override
  AppUser? get currentUser => remoteDataSource.currentUser;
}