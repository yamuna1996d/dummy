import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/visit_entity.dart';
import 'package:kincare/domain/repositories/visit_repository.dart';

/// Use case for retrieving a single visit's details.
class GetVisitDetailsUseCase {
  const GetVisitDetailsUseCase(this._repository);

  final VisitRepository _repository;

  Future<Result<VisitEntity>> call(String id) {
    return _repository.getVisitDetails(id);
  }
}
