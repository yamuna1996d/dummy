import 'package:kincare/core/api/graphql_queries.dart';
import 'package:kincare/core/api/graphql_service.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/data/models/medication_model.dart';

/// Remote datasource for medication data via GraphQL.
class MedicationRemoteDatasource {
  const MedicationRemoteDatasource(this._graphQLService);

  final GraphQLService _graphQLService;

  Future<Result<List<MedicationModel>>> getMedications() async {
    final result = await _graphQLService.query(
      GraphQLQueries.getMedications,
      variables: {
        'options': {
          'paginate': {'page': 1, 'limit': 20},
        },
      },
    );

    return result.when(
      success: (data) {
        final medications = data['medications']?['data'] as List<dynamic>?;
        if (medications == null) {
          return const Result.failure(ParsingException());
        }
        return Result.success(
          medications
              .map(
                (e) => MedicationModel.fromGraphQL(e as Map<String, dynamic>),
              )
              .toList(),
        );
      },
      failure: (e) => Result.failure(e),
    );
  }

  Future<Result<MedicationModel>> createMedication(
    MedicationModel medication,
  ) async {
    final result = await _graphQLService.mutate(
      GraphQLQueries.createMedication,
      variables: {
        'input': {
          'name': medication.name,
          'dosage': medication.dosage,
          'frequency': medication.frequency,
          'isActive': medication.isActive,
          'childId': medication.childId,
          'notes': medication.notes,
          'startDate': medication.startDate?.toIso8601String(),
          'endDate': medication.endDate?.toIso8601String(),
        },
      },
    );

    return result.when(
      success: (data) {
        final created = data['createMedication'] as Map<String, dynamic>?;
        if (created == null) {
          return const Result.failure(ParsingException());
        }
        return Result.success(MedicationModel.fromGraphQL(created));
      },
      failure: (e) => Result.failure(e),
    );
  }

  Future<Result<MedicationModel>> updateMedication(
    MedicationModel medication,
  ) async {
    final result = await _graphQLService.mutate(
      GraphQLQueries.updateMedication,
      variables: {
        'id': medication.id,
        'input': {
          'name': medication.name,
          'dosage': medication.dosage,
          'frequency': medication.frequency,
          'isActive': medication.isActive,
          'childId': medication.childId,
          'notes': medication.notes,
          'startDate': medication.startDate?.toIso8601String(),
          'endDate': medication.endDate?.toIso8601String(),
        },
      },
    );

    return result.when(
      success: (data) {
        final updated = data['updateMedication'] as Map<String, dynamic>?;
        if (updated == null) {
          return const Result.failure(ParsingException());
        }
        return Result.success(MedicationModel.fromGraphQL(updated));
      },
      failure: (e) => Result.failure(e),
    );
  }

  Future<Result<void>> deleteMedication(String id) async {
    final result = await _graphQLService.mutate(
      GraphQLQueries.deleteMedication,
      variables: {'id': id},
    );

    return result.when(
      success: (_) => const Result.success(null),
      failure: (e) => Result.failure(e),
    );
  }
}
