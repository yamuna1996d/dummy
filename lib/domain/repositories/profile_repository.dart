import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/user_entity.dart';

/// Contract for user profile operations.
abstract class ProfileRepository {
  Future<Result<UserEntity>> getProfile();
  Future<Result<UserEntity>> updateProfile(UserEntity user);
}
