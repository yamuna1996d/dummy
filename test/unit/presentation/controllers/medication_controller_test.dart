import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/child_entity.dart';
import 'package:kincare/domain/entities/medication_entity.dart';
import 'package:kincare/presentation/controllers/medication_controller.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockGetMedicationsUseCase getMedicationsUseCase;
  late MockCreateMedicationUseCase createMedicationUseCase;
  late MockUpdateMedicationUseCase updateMedicationUseCase;
  late MockDeleteMedicationUseCase deleteMedicationUseCase;
  late MockGetChildrenUseCase getChildrenUseCase;
  late MockNetworkInfo networkInfo;
  late MedicationController controller;

  const medA = MedicationEntity(id: '1', name: 'Amoxicillin', childId: 'c1');
  const medB = MedicationEntity(id: '2', name: 'Ibuprofen', childId: 'c2');

  setUp(() {
    getMedicationsUseCase = MockGetMedicationsUseCase();
    createMedicationUseCase = MockCreateMedicationUseCase();
    updateMedicationUseCase = MockUpdateMedicationUseCase();
    deleteMedicationUseCase = MockDeleteMedicationUseCase();
    getChildrenUseCase = MockGetChildrenUseCase();
    networkInfo = MockNetworkInfo();

    when(
      getChildrenUseCase(),
    ).thenAnswer((_) async => const Result.success(<ChildEntity>[]));
    when(
      networkInfo.onConnectivityChanged,
    ).thenAnswer((_) => const Stream.empty());

    controller = MedicationController(
      getMedicationsUseCase: getMedicationsUseCase,
      createMedicationUseCase: createMedicationUseCase,
      updateMedicationUseCase: updateMedicationUseCase,
      deleteMedicationUseCase: deleteMedicationUseCase,
      getChildrenUseCase: getChildrenUseCase,
      networkInfo: networkInfo,
    );
  });

  group('loadMedications', () {
    test('populates medications and filteredMedications on success', () async {
      when(
        getMedicationsUseCase(),
      ).thenAnswer((_) async => const Result.success([medA, medB]));

      await controller.loadMedications();

      expect(controller.medications, [medA, medB]);
      expect(controller.filteredMedications, [medA, medB]);
      expect(controller.isLoading.value, isFalse);
    });

    test('maps NetworkException to its own message', () async {
      when(getMedicationsUseCase()).thenAnswer(
        (_) async => const Result.failure(NetworkException('offline')),
      );

      await controller.loadMedications();

      expect(controller.errorMessage.value, 'offline');
    });
  });

  group('setChildFilter', () {
    setUp(() async {
      when(
        getMedicationsUseCase(),
      ).thenAnswer((_) async => const Result.success([medA, medB]));
      await controller.loadMedications();
    });

    test('restricts filteredMedications to the given child', () {
      controller.setChildFilter('c1');
      expect(controller.filteredMedications, [medA]);
    });

    test('clearing the filter with null restores the full list', () {
      controller.setChildFilter('c1');
      controller.setChildFilter(null);
      expect(controller.filteredMedications, [medA, medB]);
    });

    test('setting the same filter again is a no-op', () {
      controller.setChildFilter('c1');
      controller.filteredMedications.add(medB);

      controller.setChildFilter('c1');

      // _applyFilters would have removed medB; the guard prevented that.
      expect(controller.filteredMedications, [medA, medB]);
    });
  });

  group('createMedication', () {
    test('adds the created medication to the list and returns true', () async {
      when(
        createMedicationUseCase(medA),
      ).thenAnswer((_) async => const Result.success(medA));

      final success = await controller.createMedication(medA);

      expect(success, isTrue);
      expect(controller.medications, contains(medA));
      expect(controller.isSaving.value, isFalse);
    });

    test('sets errorMessage and returns false on failure', () async {
      when(createMedicationUseCase(any)).thenAnswer(
        (_) async => const Result.failure(UnexpectedException('boom')),
      );

      final success = await controller.createMedication(medA);

      expect(success, isFalse);
      expect(controller.errorMessage.value, 'boom');
      expect(controller.medications, isEmpty);
    });
  });

  group('updateMedication', () {
    test('replaces the matching medication in place', () async {
      when(
        getMedicationsUseCase(),
      ).thenAnswer((_) async => const Result.success([medA]));
      await controller.loadMedications();

      const updated = MedicationEntity(id: '1', name: 'Amoxicillin 500mg');
      when(
        updateMedicationUseCase(updated),
      ).thenAnswer((_) async => const Result.success(updated));

      final success = await controller.updateMedication(updated);

      expect(success, isTrue);
      expect(controller.medications.first.name, 'Amoxicillin 500mg');
    });
  });

  group('deleteMedication', () {
    test('removes the medication with the matching id', () async {
      when(
        getMedicationsUseCase(),
      ).thenAnswer((_) async => const Result.success([medA, medB]));
      await controller.loadMedications();

      when(
        deleteMedicationUseCase('1'),
      ).thenAnswer((_) async => const Result.success(null));

      final success = await controller.deleteMedication('1');

      expect(success, isTrue);
      expect(controller.medications, [medB]);
    });
  });

  group('clearForm / populateForm', () {
    test('populateForm fills text controllers from a medication', () {
      controller.populateForm(medA);

      expect(controller.nameController.text, 'Amoxicillin');
      expect(controller.selectedChildId.value, 'c1');
    });

    test('clearForm resets text controllers and selections', () {
      controller.populateForm(medA);
      controller.clearForm();

      expect(controller.nameController.text, '');
      expect(controller.selectedChildId.value, isNull);
      expect(controller.selectedFrequency.value, isNull);
    });
  });
}
