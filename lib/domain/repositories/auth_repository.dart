import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/user_entity.dart';

/// Contract for authentication operations.
abstract class AuthRepository {
  Future<Result<UserEntity>> login(
    String email,
    String password, {
    bool rememberMe = false,
  });
  Future<Result<void>> logout();
  Future<bool> isLoggedIn();
  Future<String?> getLastLoginEmail();
}
