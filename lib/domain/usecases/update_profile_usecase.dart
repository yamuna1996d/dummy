import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/user_entity.dart';
import 'package:kincare/domain/repositories/profile_repository.dart';

/// Use case for updating the current user profile.
class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Result<UserEntity>> call(UserEntity user) {
    return _repository.updateProfile(user);
  }
}
