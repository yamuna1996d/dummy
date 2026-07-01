import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/medication_entity.dart';
import 'package:kincare/domain/repositories/medication_repository.dart';

/// Use case for retrieving the list of medications.
class GetMedicationsUseCase {
  const GetMedicationsUseCase(this._repository);

  final MedicationRepository _repository;

  Future<Result<List<MedicationEntity>>> call() {
    return _repository.getMedications();
  }
}
