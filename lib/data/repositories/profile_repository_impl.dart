import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/core/network/network_info.dart';
import 'package:kincare/data/datasource/remote/profile_remote_datasource.dart';
import 'package:kincare/domain/entities/user_entity.dart';
import 'package:kincare/domain/repositories/profile_repository.dart';

/// Repository implementation for user profile.
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final ProfileRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<Result<UserEntity>> getProfile() async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkException());
    }
    return remoteDatasource.getProfile();
  }
}
