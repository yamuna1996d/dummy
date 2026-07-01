import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/user_entity.dart';
import 'package:kincare/domain/usecases/login_usecase.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockAuthRepository repository;
  late LoginUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = LoginUseCase(repository);
  });

  test(
    'passes email, password, and rememberMe through to repository.login',
    () async {
      const user = UserEntity(
        id: '1',
        name: 'Admin',
        email: 'admin@kincare.com',
      );
      when(
        repository.login('admin@kincare.com', 'password', rememberMe: true),
      ).thenAnswer((_) async => const Result.success(user));

      final result = await useCase(
        'admin@kincare.com',
        'password',
        rememberMe: true,
      );

      expect(result.dataOrNull, user);
      verify(
        repository.login('admin@kincare.com', 'password', rememberMe: true),
      ).called(1);
    },
  );

  test('defaults rememberMe to false when not supplied', () async {
    when(
      repository.login(any, any, rememberMe: anyNamed('rememberMe')),
    ).thenAnswer((_) async => const Result.failure(AuthException()));

    await useCase('admin@kincare.com', 'password');

    verify(
      repository.login('admin@kincare.com', 'password', rememberMe: false),
    ).called(1);
  });

  test('forwards a failure from the repository unchanged', () async {
    when(
      repository.login(any, any, rememberMe: anyNamed('rememberMe')),
    ).thenAnswer((_) async => const Result.failure(AuthException()));

    final result = await useCase('admin@kincare.com', 'wrong');

    expect(result.isFailure, isTrue);
  });
}
