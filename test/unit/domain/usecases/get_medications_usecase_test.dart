import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/medication_entity.dart';
import 'package:kincare/domain/usecases/get_medications_usecase.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockMedicationRepository repository;
  late GetMedicationsUseCase useCase;

  setUp(() {
    repository = MockMedicationRepository();
    useCase = GetMedicationsUseCase(repository);
  });

  test(
    'delegates to repository.getMedications and forwards a success',
    () async {
      const medications = [MedicationEntity(id: '1', name: 'Amoxicillin')];
      when(
        repository.getMedications(),
      ).thenAnswer((_) async => const Result.success(medications));

      final result = await useCase();

      expect(result.dataOrNull, medications);
      verify(repository.getMedications()).called(1);
    },
  );

  test('forwards a failure from the repository unchanged', () async {
    when(
      repository.getMedications(),
    ).thenAnswer((_) async => const Result.failure(NetworkException()));

    final result = await useCase();

    expect(result.isFailure, isTrue);
  });
}
