import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/user_entity.dart';
import 'package:kincare/domain/repositories/auth_repository.dart';

/// Use case for authenticating a user.
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<UserEntity>> call(
    String email,
    String password, {
    bool rememberMe = false,
  }) {
    return _repository.login(email, password, rememberMe: rememberMe);
  }
}
