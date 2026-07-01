import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/medication_entity.dart';
import 'package:kincare/domain/repositories/medication_repository.dart';

/// Use case for creating a new medication.
class CreateMedicationUseCase {
  const CreateMedicationUseCase(this._repository);

  final MedicationRepository _repository;

  Future<Result<MedicationEntity>> call(MedicationEntity medication) {
    return _repository.createMedication(medication);
  }
}
