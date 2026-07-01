import 'package:kincare/core/api/graphql_queries.dart';
import 'package:kincare/core/api/graphql_service.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/data/models/user_model.dart';

/// Remote datasource for user profile data via GraphQL.
class ProfileRemoteDatasource {
  const ProfileRemoteDatasource(this._graphQLService);

  final GraphQLService _graphQLService;

  Future<Result<UserModel>> getProfile() async {
    final result = await _graphQLService.query(
      GraphQLQueries.getUser,
      variables: {'id': '1'},
    );

    return result.when(
      success: (data) {
        final userData = data['user'] as Map<String, dynamic>?;
        if (userData == null) {
          return const Result.failure(ParsingException());
        }
        return Result.success(UserModel.fromJson(userData));
      },
      failure: (e) => Result.failure(e),
    );
  }
}
