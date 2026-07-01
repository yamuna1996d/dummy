import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/child_entity.dart';
import 'package:kincare/domain/usecases/get_children_usecase.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockChildrenRepository repository;
  late GetChildrenUseCase useCase;

  setUp(() {
    repository = MockChildrenRepository();
    useCase = GetChildrenUseCase(repository);
  });

  test('delegates to repository.getChildren and forwards a success', () async {
    const children = [ChildEntity(id: '1', name: 'Riya')];
    when(
      repository.getChildren(),
    ).thenAnswer((_) async => const Result.success(children));

    final result = await useCase();

    expect(result.dataOrNull, children);
    verify(repository.getChildren()).called(1);
  });

  test('forwards a failure from the repository unchanged', () async {
    when(
      repository.getChildren(),
    ).thenAnswer((_) async => const Result.failure(NetworkException()));

    final result = await useCase();

    expect(result.isFailure, isTrue);
    result.when(
      success: (_) => fail('expected a failure'),
      failure: (e) => expect(e, isA<NetworkException>()),
    );
  });
}
