import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/user_entity.dart';
import 'package:kincare/domain/repositories/profile_repository.dart';

/// Use case for retrieving the current user profile.
class GetProfileUseCase {
  const GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Result<UserEntity>> call() {
    return _repository.getProfile();
  }
}
