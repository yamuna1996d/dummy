import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/core/network/network_info.dart';
import 'package:kincare/data/datasource/remote/dashboard_remote_datasource.dart';
import 'package:kincare/domain/entities/dashboard_entity.dart';
import 'package:kincare/domain/repositories/dashboard_repository.dart';

/// Repository implementation for dashboard data.
class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final DashboardRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<Result<DashboardEntity>> getDashboard() async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkException('No internet connection'));
    }
    return remoteDatasource.getDashboard();
  }
}
