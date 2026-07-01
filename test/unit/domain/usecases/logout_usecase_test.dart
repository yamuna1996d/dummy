import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/usecases/logout_usecase.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockAuthRepository repository;
  late LogoutUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = LogoutUseCase(repository);
  });

  test('delegates to repository.logout and forwards a success', () async {
    when(
      repository.logout(),
    ).thenAnswer((_) async => const Result.success(null));

    final result = await useCase();

    expect(result.isSuccess, isTrue);
    verify(repository.logout()).called(1);
  });

  test('forwards a failure from the repository unchanged', () async {
    when(
      repository.logout(),
    ).thenAnswer((_) async => const Result.failure(UnexpectedException()));

    final result = await useCase();

    expect(result.isFailure, isTrue);
  });
}
