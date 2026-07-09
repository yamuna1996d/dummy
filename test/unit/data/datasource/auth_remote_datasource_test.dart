import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/api/graphql_response.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/data/datasource/remote/auth_remote_datasource.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockGraphQLService graphQLService;
  late AuthRemoteDatasource datasource;

  setUp(() {
    graphQLService = MockGraphQLService();
    datasource = AuthRemoteDatasource(graphQLService);
  });

  group('login', () {
    test('rejects an incorrect password without calling the API', () async {
      final result = await datasource.login('admin@kincare.com', 'wrong');

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('expected a failure'),
        failure: (e) => expect(e, isA<AuthException>()),
      );
      verifyNever(graphQLService.query(any, variables: anyNamed('variables')));
    });

    test('rejects an unknown email without calling the API', () async {
      final result = await datasource.login('nobody@kincare.com', 'password');

      expect(result.isFailure, isTrue);
      verifyNever(graphQLService.query(any, variables: anyNamed('variables')));
    });

    test(
      'returns a user built from the query response on valid credentials',
      () async {
        when(
          graphQLService.query(any, variables: anyNamed('variables')),
        ).thenAnswer(
          (_) async => const Result.success(
            GraphQLResponse({
              'user': {'id': '1', 'name': 'Admin User', 'username': 'admin'},
            }),
          ),
        );

        final result = await datasource.login('admin@kincare.com', 'password');

        expect(result.isSuccess, isTrue);
        result.when(
          success: (user) {
            expect(user.id, '1');
            expect(user.name, 'Admin User');
            expect(user.email, 'admin@kincare.com');
          },
          failure: (_) => fail('expected a success'),
        );
      },
    );

    test(
      'returns a ParsingException when the response has no user data',
      () async {
        when(
          graphQLService.query(any, variables: anyNamed('variables')),
        ).thenAnswer((_) async => const Result.success(GraphQLResponse({})));

        final result = await datasource.login('admin@kincare.com', 'password');

        expect(result.isFailure, isTrue);
        result.when(
          success: (_) => fail('expected a failure'),
          failure: (e) => expect(e, isA<ParsingException>()),
        );
      },
    );

    test('propagates a failure from the underlying GraphQL call', () async {
      when(
        graphQLService.query(any, variables: anyNamed('variables')),
      ).thenAnswer((_) async => const Result.failure(TimeoutException()));

      final result = await datasource.login('admin@kincare.com', 'password');

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('expected a failure'),
        failure: (e) => expect(e, isA<TimeoutException>()),
      );
    });
  });
}
