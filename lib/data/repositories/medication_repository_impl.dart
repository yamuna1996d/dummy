import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/core/network/network_info.dart';
import 'package:kincare/data/datasource/remote/medication_remote_datasource.dart';
import 'package:kincare/data/models/medication_model.dart';
import 'package:kincare/domain/entities/medication_entity.dart';
import 'package:kincare/domain/repositories/medication_repository.dart';

/// Repository implementation for medications.
class MedicationRepositoryImpl implements MedicationRepository {
  const MedicationRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final MedicationRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<Result<List<MedicationEntity>>> getMedications() async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkException());
    }
    return remoteDatasource.getMedications();
  }

  @override
  Future<Result<MedicationEntity>> createMedication(
    MedicationEntity medication,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkException());
    }
    return remoteDatasource.createMedication(
      MedicationModel.fromEntity(medication),
    );
  }

  @override
  Future<Result<MedicationEntity>> updateMedication(
    MedicationEntity medication,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkException());
    }
    return remoteDatasource.updateMedication(
      MedicationModel.fromEntity(medication),
    );
  }

  @override
  Future<Result<void>> deleteMedication(String id) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkException());
    }
    return remoteDatasource.deleteMedication(id);
  }
}
