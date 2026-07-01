import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/medication_entity.dart';

/// Contract for medication management operations.
abstract class MedicationRepository {
  Future<Result<List<MedicationEntity>>> getMedications();
  Future<Result<MedicationEntity>> createMedication(
    MedicationEntity medication,
  );
  Future<Result<MedicationEntity>> updateMedication(
    MedicationEntity medication,
  );
  Future<Result<void>> deleteMedication(String id);
}
