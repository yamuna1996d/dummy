import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/data/models/user_model.dart';
import 'package:kincare/data/repositories/auth_repository_impl.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockAuthRemoteDatasource remoteDatasource;
  late MockAuthLocalDatasource localDatasource;
  late MockNetworkInfo networkInfo;
  late AuthRepositoryImpl repository;

  const user = UserModel(id: '1', name: 'Admin', email: 'admin@kincare.com');

  setUp(() {
    remoteDatasource = MockAuthRemoteDatasource();
    localDatasource = MockAuthLocalDatasource();
    networkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDatasource: remoteDatasource,
      localDatasource: localDatasource,
      networkInfo: networkInfo,
    );
  });

  group('login', () {
    test(
      'returns NetworkException without calling the datasource when offline',
      () async {
        when(networkInfo.isConnected).thenAnswer((_) async => false);

        final result = await repository.login('admin@kincare.com', 'password');

        expect(result.isFailure, isTrue);
        result.when(
          success: (_) => fail('expected a failure'),
          failure: (e) => expect(e, isA<NetworkException>()),
        );
        verifyNever(remoteDatasource.login(any, any));
      },
    );

    test('saves the session and returns the user on success', () async {
      when(networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        remoteDatasource.login('admin@kincare.com', 'password'),
      ).thenAnswer((_) async => const Result.success(user));

      final result = await repository.login(
        'admin@kincare.com',
        'password',
        rememberMe: true,
      );

      expect(result.dataOrNull, user);
      verify(localDatasource.saveSession(user, rememberMe: true)).called(1);
    });

    test('does not save a session when the datasource login fails', () async {
      when(networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        remoteDatasource.login(any, any),
      ).thenAnswer((_) async => const Result.failure(AuthException()));

      final result = await repository.login('admin@kincare.com', 'wrong');

      expect(result.isFailure, isTrue);
      verifyNever(
        localDatasource.saveSession(any, rememberMe: anyNamed('rememberMe')),
      );
    });
  });

  group('logout', () {
    test('clears the session and returns success', () async {
      when(localDatasource.clearSession()).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result.isSuccess, isTrue);
      verify(localDatasource.clearSession()).called(1);
    });

    test(
      'wraps a thrown error from clearSession as an UnexpectedException',
      () async {
        when(localDatasource.clearSession()).thenThrow(Exception('hive error'));

        final result = await repository.logout();

        expect(result.isFailure, isTrue);
        result.when(
          success: (_) => fail('expected a failure'),
          failure: (e) => expect(e, isA<UnexpectedException>()),
        );
      },
    );
  });

  group('isLoggedIn', () {
    test('delegates to the local datasource', () async {
      when(localDatasource.isLoggedIn()).thenReturn(true);
      expect(await repository.isLoggedIn(), isTrue);
    });
  });

  group('getLastLoginEmail', () {
    test('delegates to the local datasource', () async {
      when(localDatasource.getLastLoginEmail()).thenReturn('admin@kincare.com');
      expect(await repository.getLastLoginEmail(), 'admin@kincare.com');
    });
  });
}
