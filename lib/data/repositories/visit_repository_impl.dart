import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/core/network/network_info.dart';
import 'package:kincare/data/datasource/remote/visit_remote_datasource.dart';
import 'package:kincare/data/models/visit_model.dart';
import 'package:kincare/domain/entities/visit_entity.dart';
import 'package:kincare/domain/repositories/visit_repository.dart';

/// Repository implementation for visits.
class VisitRepositoryImpl implements VisitRepository {
  const VisitRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final VisitRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<Result<List<VisitEntity>>> getVisits() async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkException());
    }
    return remoteDatasource.getVisits();
  }

  @override
  Future<Result<VisitEntity>> getVisitDetails(String id) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkException());
    }
    return remoteDatasource.getVisit(id);
  }

  @override
  Future<Result<VisitEntity>> createVisit(VisitEntity visit) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkException());
    }
    return remoteDatasource.createVisit(VisitModel.fromEntity(visit));
  }

  @override
  Future<Result<VisitEntity>> updateVisit(VisitEntity visit) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkException());
    }
    return remoteDatasource.updateVisit(VisitModel.fromEntity(visit));
  }

  @override
  Future<Result<void>> deleteVisit(String id) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkException());
    }
    return remoteDatasource.deleteVisit(id);
  }
}
