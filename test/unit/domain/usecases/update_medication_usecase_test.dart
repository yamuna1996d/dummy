import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/medication_entity.dart';
import 'package:kincare/domain/usecases/update_medication_usecase.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockMedicationRepository repository;
  late UpdateMedicationUseCase useCase;

  const medication = MedicationEntity(id: '1', name: 'Ibuprofen updated');

  setUp(() {
    repository = MockMedicationRepository();
    useCase = UpdateMedicationUseCase(repository);
  });

  test(
    'passes the given medication through to repository.updateMedication',
    () async {
      when(
        repository.updateMedication(medication),
      ).thenAnswer((_) async => const Result.success(medication));

      final result = await useCase(medication);

      expect(result.dataOrNull, medication);
      verify(repository.updateMedication(medication)).called(1);
    },
  );

  test('forwards a failure from the repository unchanged', () async {
    when(
      repository.updateMedication(any),
    ).thenAnswer((_) async => const Result.failure(NetworkException()));

    final result = await useCase(medication);

    expect(result.isFailure, isTrue);
  });
}
