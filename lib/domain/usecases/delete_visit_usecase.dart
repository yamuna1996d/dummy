import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/repositories/visit_repository.dart';

/// Use case for deleting a visit.
class DeleteVisitUseCase {
  const DeleteVisitUseCase(this._repository);

  final VisitRepository _repository;

  Future<Result<void>> call(String id) {
    return _repository.deleteVisit(id);
  }
}
