import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/visit_entity.dart';
import 'package:kincare/domain/repositories/visit_repository.dart';

/// Use case for retrieving the list of visits.
class GetVisitsUseCase {
  const GetVisitsUseCase(this._repository);

  final VisitRepository _repository;

  Future<Result<List<VisitEntity>>> call() {
    return _repository.getVisits();
  }
}
