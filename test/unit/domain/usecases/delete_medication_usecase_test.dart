import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/usecases/delete_medication_usecase.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockMedicationRepository repository;
  late DeleteMedicationUseCase useCase;

  setUp(() {
    repository = MockMedicationRepository();
    useCase = DeleteMedicationUseCase(repository);
  });

  test('passes the given id through to repository.deleteMedication', () async {
    when(
      repository.deleteMedication('1'),
    ).thenAnswer((_) async => const Result.success(null));

    final result = await useCase('1');

    expect(result.isSuccess, isTrue);
    verify(repository.deleteMedication('1')).called(1);
  });

  test('forwards a failure from the repository unchanged', () async {
    when(
      repository.deleteMedication(any),
    ).thenAnswer((_) async => const Result.failure(NetworkException()));

    final result = await useCase('1');

    expect(result.isFailure, isTrue);
  });
}
