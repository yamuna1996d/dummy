import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/dashboard_entity.dart';

/// Contract for dashboard data operations.
abstract class DashboardRepository {
  Future<Result<DashboardEntity>> getDashboard();
}
