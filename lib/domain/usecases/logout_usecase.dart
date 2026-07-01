import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/repositories/auth_repository.dart';

/// Use case for logging out the current user.
class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() {
    return _repository.logout();
  }
}
