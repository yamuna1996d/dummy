import 'package:kincare/core/api/graphql_queries.dart';
import 'package:kincare/core/api/graphql_service.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/data/models/child_model.dart';

/// Remote datasource for children data via GraphQL.
class ChildrenRemoteDatasource {
  const ChildrenRemoteDatasource(this._graphQLService);

  final GraphQLService _graphQLService;

  Future<Result<List<ChildModel>>> getChildren() async {
    final result = await _graphQLService.query(
      GraphQLQueries.getChildren,
      variables: {
        'options': {
          'paginate': {'page': 1, 'limit': 20},
        },
      },
    );

    return result.when(
      success: (data) {
        final children = data['children']?['data'] as List<dynamic>?;
        if (children == null) {
          return const Result.failure(ParsingException());
        }
        return Result.success(
          children
              .map((e) => ChildModel.fromGraphQL(e as Map<String, dynamic>))
              .toList(),
        );
      },
      failure: (e) => Result.failure(e),
    );
  }

  Future<Result<ChildModel>> getChildDetails(String id) async {
    final result = await _graphQLService.query(
      GraphQLQueries.getChild,
      variables: {'id': id},
    );

    return result.when(
      success: (data) {
        final child = data['child'] as Map<String, dynamic>?;
        if (child == null) {
          return const Result.failure(ParsingException());
        }
        return Result.success(ChildModel.fromGraphQL(child));
      },
      failure: (e) => Result.failure(e),
    );
  }

  Future<Result<ChildModel>> addChild(ChildModel child) async {
    final result = await _graphQLService.mutate(
      GraphQLQueries.createChild,
      variables: {
        'input': {
          'name': child.name,
          'age': child.age,
          'gender': child.gender,
          'guardianName': child.guardianName,
          'description': child.description,
        },
      },
    );

    return result.when(
      success: (data) {
        final created = data['createChild'] as Map<String, dynamic>?;
        if (created == null) {
          return const Result.failure(ParsingException());
        }
        return Result.success(ChildModel.fromGraphQL(created));
      },
      failure: (e) => Result.failure(e),
    );
  }

  Future<Result<ChildModel>> updateChild(ChildModel child) async {
    final result = await _graphQLService.mutate(
      GraphQLQueries.updateChild,
      variables: {
        'id': child.id,
        'input': {
          'name': child.name,
          'age': child.age,
          'gender': child.gender,
          'guardianName': child.guardianName,
          'description': child.description,
        },
      },
    );

    return result.when(
      success: (data) {
        final updated = data['updateChild'] as Map<String, dynamic>?;
        if (updated == null) {
          return const Result.failure(ParsingException());
        }
        return Result.success(ChildModel.fromGraphQL(updated));
      },
      failure: (e) => Result.failure(e),
    );
  }

  Future<Result<void>> deleteChild(String id) async {
    final result = await _graphQLService.mutate(
      GraphQLQueries.deleteChild,
      variables: {'id': id},
    );

    return result.when(
      success: (_) => const Result.success(null),
      failure: (e) => Result.failure(e),
    );
  }
}
