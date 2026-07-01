import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/core/network/network_info.dart';
import 'package:kincare/data/datasource/local/auth_local_datasource.dart';
import 'package:kincare/data/datasource/remote/auth_remote_datasource.dart';
import 'package:kincare/domain/entities/user_entity.dart';
import 'package:kincare/domain/repositories/auth_repository.dart';

/// Repository implementation for authentication with offline-first support.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.networkInfo,
  });

  final AuthRemoteDatasource remoteDatasource;
  final AuthLocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<Result<UserEntity>> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(
        NetworkException('Internet connection required for login'),
      );
    }

    final result = await remoteDatasource.login(email, password);
    return result.when(
      success: (user) async {
        await localDatasource.saveSession(user, rememberMe: rememberMe);
        return Result.success(user);
      },
      failure: (e) => Result.failure(e),
    );
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await localDatasource.clearSession();
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(UnexpectedException(e.toString(), st));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return localDatasource.isLoggedIn();
  }

  @override
  Future<String?> getLastLoginEmail() async {
    return localDatasource.getLastLoginEmail();
  }
}
