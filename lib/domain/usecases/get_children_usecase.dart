import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/child_entity.dart';
import 'package:kincare/domain/repositories/children_repository.dart';

/// Use case for retrieving the list of children.
class GetChildrenUseCase {
  const GetChildrenUseCase(this._repository);

  final ChildrenRepository _repository;

  Future<Result<List<ChildEntity>>> call() {
    return _repository.getChildren();
  }
}
