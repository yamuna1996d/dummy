import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/core/network/network_info.dart';
import 'package:kincare/data/datasource/remote/children_remote_datasource.dart';
import 'package:kincare/data/models/child_model.dart';
import 'package:kincare/domain/entities/child_entity.dart';
import 'package:kincare/domain/repositories/children_repository.dart';

/// Repository implementation for children.
class ChildrenRepositoryImpl implements ChildrenRepository {
  const ChildrenRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final ChildrenRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<Result<List<ChildEntity>>> getChildren() async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkException());
    }
    return remoteDatasource.getChildren();
  }

  @override
  Future<Result<ChildEntity>> getChildDetails(String id) async {
    return remoteDatasource.getChildDetails(id);
  }

  @override
  Future<Result<ChildEntity>> addChild(ChildEntity child) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkException());
    }
    return remoteDatasource.addChild(ChildModel.fromEntity(child));
  }

  @override
  Future<Result<ChildEntity>> updateChild(ChildEntity child) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkException());
    }
    return remoteDatasource.updateChild(ChildModel.fromEntity(child));
  }

  @override
  Future<Result<void>> deleteChild(String id) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkException());
    }
    return remoteDatasource.deleteChild(id);
  }
}
