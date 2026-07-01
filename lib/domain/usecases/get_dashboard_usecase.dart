import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/dashboard_entity.dart';
import 'package:kincare/domain/repositories/dashboard_repository.dart';

/// Use case for loading dashboard summary data.
class GetDashboardUseCase {
  const GetDashboardUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Result<DashboardEntity>> call() {
    return _repository.getDashboard();
  }
}
