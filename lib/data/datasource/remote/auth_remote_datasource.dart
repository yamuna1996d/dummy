import 'package:kincare/core/api/graphql_queries.dart';
import 'package:kincare/core/api/graphql_service.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/data/models/user_model.dart';

/// Remote datasource for authentication via GraphQL.
class AuthRemoteDatasource {
  const AuthRemoteDatasource(this._graphQLService);

  final GraphQLService _graphQLService;

  /// Mock login: fetches a user from GraphQL API and validates credentials.
  Future<Result<UserModel>> login(String email, String password) async {
    // Mock validation
    if (email != 'admin@kincare.com' || password != 'password') {
      return const Result.failure(AuthException('Invalid email or password'));
    }

    final result = await _graphQLService.query(
      GraphQLQueries.getUser,
      variables: {'id': '1'},
    );

    return result.when(
      success: (response) {
        final userData = response.object('user');
        if (userData == null) {
          return const Result.failure(ParsingException('User data not found'));
        }
        final user = UserModel.fromJson({...userData, 'email': email});
        return Result.success(user);
      },
      failure: (e) => Result.failure(e),
    );
  }
}
