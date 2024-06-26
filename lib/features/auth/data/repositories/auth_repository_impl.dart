import 'package:fpdart/fpdart.dart';
import 'package:inkwel_blog_app/core/common/entities/user.dart';
import 'package:inkwel_blog_app/core/constants/constants.dart';
import 'package:inkwel_blog_app/core/error/exception.dart';
import 'package:inkwel_blog_app/core/error/failures.dart';
import 'package:inkwel_blog_app/core/network/connection_checker.dart';
import 'package:inkwel_blog_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:inkwel_blog_app/features/auth/data/models/user_model.dart';
import 'package:inkwel_blog_app/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ConncectionChecker conncectionChecker;
  const AuthRepositoryImpl(this.remoteDataSource, this.conncectionChecker);

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      if (!await (conncectionChecker.isConnected)) {
        final session = remoteDataSource.currentUserSession;
        if (session == null) {
          return left(Failure('User not logged in!'));
        }
        return right(
          UserModel(
            id: session.user.id,
            email: session.user.email ?? '',
            name: '',
          ),
        );
      }
      final user = await remoteDataSource.getCurrentUserData();
      if (user == null) {
        return left(Failure('User not logged in!'));
      }
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.loginWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  Future<Either<Failure, User>> _getUser(Future<User> Function() fn) async {
    try {
      if (!await (conncectionChecker.isConnected)) {
        return left(Failure(Constatns.noConnectionErrorMessage));
      }
      final user = await fn();
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
