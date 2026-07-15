import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/visit_entity.dart';

/// Contract for visit management operations.
abstract class VisitRepository {
  Future<Result<List<VisitEntity>>> getVisits();
  Future<Result<VisitEntity>> getVisitDetails(String id);
  Future<Result<VisitEntity>> createVisit(VisitEntity visit);
  Future<Result<VisitEntity>> updateVisit(VisitEntity visit);
  Future<Result<void>> deleteVisit(String id);
}
