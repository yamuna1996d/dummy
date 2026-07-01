import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/child_entity.dart';
import 'package:kincare/domain/repositories/children_repository.dart';

/// Use case for retrieving details of a single child.
class GetChildDetailsUseCase {
  const GetChildDetailsUseCase(this._repository);

  final ChildrenRepository _repository;

  Future<Result<ChildEntity>> call(String id) {
    return _repository.getChildDetails(id);
  }
}
