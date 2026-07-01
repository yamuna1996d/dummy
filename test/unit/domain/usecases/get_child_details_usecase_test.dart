import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/child_entity.dart';
import 'package:kincare/domain/usecases/get_child_details_usecase.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockChildrenRepository repository;
  late GetChildDetailsUseCase useCase;

  setUp(() {
    repository = MockChildrenRepository();
    useCase = GetChildDetailsUseCase(repository);
  });

  test('passes the given id through to repository.getChildDetails', () async {
    const child = ChildEntity(id: '1', name: 'Riya');
    when(
      repository.getChildDetails('1'),
    ).thenAnswer((_) async => const Result.success(child));

    final result = await useCase('1');

    expect(result.dataOrNull, child);
    verify(repository.getChildDetails('1')).called(1);
  });

  test('forwards a failure from the repository unchanged', () async {
    when(
      repository.getChildDetails(any),
    ).thenAnswer((_) async => const Result.failure(UnexpectedException()));

    final result = await useCase('missing');

    expect(result.isFailure, isTrue);
  });
}
