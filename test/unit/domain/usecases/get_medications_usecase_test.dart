import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/medication_entity.dart';
import 'package:kincare/domain/repositories/medication_repository.dart';
import 'package:kincare/domain/usecases/get_medications_usecase.dart';

@GenerateNiceMocks([MockSpec<MedicationRepository>()])
import 'get_medications_usecase_test.mocks.dart';

void main() {
  late GetMedicationsUseCase useCase;
  late MockMedicationRepository mockRepository;

  const testMedications = [
    MedicationEntity(id: '1', name: 'Vitamin D', dosage: '1000IU'),
    MedicationEntity(id: '2', name: 'Iron', dosage: '65mg'),
  ];

  setUpAll(() {
    provideDummy<Result<List<MedicationEntity>>>(
      const Result.success([]),
    );
    provideDummy<Result<MedicationEntity>>(
      const Result.success(
        MedicationEntity(id: '0', name: 'dummy'),
      ),
    );
    provideDummy<Result<void>>(const Result.success(null));
  });

  setUp(() {
    mockRepository = MockMedicationRepository();
    useCase = GetMedicationsUseCase(mockRepository);
  });

  test('should return medications list on success', () async {
    when(mockRepository.getMedications())
        .thenAnswer((_) async => const Result.success(testMedications));

    final result = await useCase();

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull?.length, 2);
    verify(mockRepository.getMedications()).called(1);
  });

  test('should return failure when offline', () async {
    when(mockRepository.getMedications())
        .thenAnswer((_) async => const Result.failure(NetworkException()));

    final result = await useCase();

    expect(result.isFailure, isTrue);
  });
}
