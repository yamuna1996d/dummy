import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/repositories/medication_repository.dart';

/// Use case for deleting a medication.
class DeleteMedicationUseCase {
  const DeleteMedicationUseCase(this._repository);

  final MedicationRepository _repository;

  Future<Result<void>> call(String id) {
    return _repository.deleteMedication(id);
  }
}
