import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/data/models/medication_model.dart';
import 'package:kincare/data/repositories/medication_repository_impl.dart';
import 'package:kincare/domain/entities/medication_entity.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockMedicationRemoteDatasource remoteDatasource;
  late MockNetworkInfo networkInfo;
  late MedicationRepositoryImpl repository;

  const medication = MedicationEntity(id: '1', name: 'Ibuprofen');

  setUp(() {
    remoteDatasource = MockMedicationRemoteDatasource();
    networkInfo = MockNetworkInfo();
    repository = MedicationRepositoryImpl(
      remoteDatasource: remoteDatasource,
      networkInfo: networkInfo,
    );
  });

  group('when offline', () {
    setUp(() {
      when(networkInfo.isConnected).thenAnswer((_) async => false);
    });

    test('getMedications returns NetworkException', () async {
      final result = await repository.getMedications();
      expect(result.isFailure, isTrue);
      verifyNever(remoteDatasource.getMedications());
    });

    test('createMedication returns NetworkException', () async {
      final result = await repository.createMedication(medication);
      expect(result.isFailure, isTrue);
      verifyNever(remoteDatasource.createMedication(any));
    });

    test('updateMedication returns NetworkException', () async {
      final result = await repository.updateMedication(medication);
      expect(result.isFailure, isTrue);
      verifyNever(remoteDatasource.updateMedication(any));
    });

    test('deleteMedication returns NetworkException', () async {
      final result = await repository.deleteMedication('1');
      expect(result.isFailure, isTrue);
      verifyNever(remoteDatasource.deleteMedication(any));
    });
  });

  group('when online', () {
    setUp(() {
      when(networkInfo.isConnected).thenAnswer((_) async => true);
    });

    test('createMedication converts the entity to a model', () async {
      when(remoteDatasource.createMedication(any)).thenAnswer(
        (_) async => Result.success(MedicationModel.fromEntity(medication)),
      );

      await repository.createMedication(medication);

      final captured =
          verify(remoteDatasource.createMedication(captureAny)).captured.single
              as MedicationModel;
      expect(captured.id, medication.id);
      expect(captured.name, medication.name);
    });

    test('getMedications delegates to the datasource', () async {
      when(
        remoteDatasource.getMedications(),
      ).thenAnswer((_) async => const Result.success([]));

      final result = await repository.getMedications();

      expect(result.isSuccess, isTrue);
      verify(remoteDatasource.getMedications()).called(1);
    });
  });
}
