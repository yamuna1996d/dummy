import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/medication_entity.dart';
import 'package:kincare/domain/usecases/create_medication_usecase.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockMedicationRepository repository;
  late CreateMedicationUseCase useCase;

  const medication = MedicationEntity(id: '', name: 'Ibuprofen');

  setUp(() {
    repository = MockMedicationRepository();
    useCase = CreateMedicationUseCase(repository);
  });

  test(
    'passes the given medication through to repository.createMedication',
    () async {
      const created = MedicationEntity(id: '1', name: 'Ibuprofen');
      when(
        repository.createMedication(medication),
      ).thenAnswer((_) async => const Result.success(created));

      final result = await useCase(medication);

      expect(result.dataOrNull, created);
      verify(repository.createMedication(medication)).called(1);
    },
  );

  test('forwards a failure from the repository unchanged', () async {
    when(
      repository.createMedication(any),
    ).thenAnswer((_) async => const Result.failure(UnexpectedException()));

    final result = await useCase(medication);

    expect(result.isFailure, isTrue);
  });
}
