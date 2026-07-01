import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/user_entity.dart';
import 'package:kincare/domain/usecases/get_profile_usecase.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockProfileRepository repository;
  late GetProfileUseCase useCase;

  setUp(() {
    repository = MockProfileRepository();
    useCase = GetProfileUseCase(repository);
  });

  test('delegates to repository.getProfile and forwards a success', () async {
    const user = UserEntity(id: '1', name: 'Jane', email: 'jane@kincare.com');
    when(
      repository.getProfile(),
    ).thenAnswer((_) async => const Result.success(user));

    final result = await useCase();

    expect(result.dataOrNull, user);
    verify(repository.getProfile()).called(1);
  });

  test('forwards a failure from the repository unchanged', () async {
    when(
      repository.getProfile(),
    ).thenAnswer((_) async => const Result.failure(NetworkException()));

    final result = await useCase();

    expect(result.isFailure, isTrue);
  });
}
