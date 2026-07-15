import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/visit_entity.dart';
import 'package:kincare/domain/repositories/visit_repository.dart';

/// Use case for creating a new visit.
class CreateVisitUseCase {
  const CreateVisitUseCase(this._repository);

  final VisitRepository _repository;

  Future<Result<VisitEntity>> call(VisitEntity visit) {
    return _repository.createVisit(visit);
  }
}
