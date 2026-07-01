import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/child_entity.dart';

/// Contract for child management operations.
abstract class ChildrenRepository {
  Future<Result<List<ChildEntity>>> getChildren();
  Future<Result<ChildEntity>> getChildDetails(String id);
  Future<Result<ChildEntity>> addChild(ChildEntity child);
  Future<Result<ChildEntity>> updateChild(ChildEntity child);
  Future<Result<void>> deleteChild(String id);
}
