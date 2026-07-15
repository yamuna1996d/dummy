import 'package:kincare/core/api/graphql_queries.dart';
import 'package:kincare/core/api/graphql_service.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/data/models/visit_model.dart';

/// Remote datasource for visit data via GraphQL.
class VisitRemoteDatasource {
  const VisitRemoteDatasource(this._graphQLService);

  final GraphQLService _graphQLService;

  Future<Result<List<VisitModel>>> getVisits() async {
    final result = await _graphQLService.query(
      GraphQLQueries.getVisits,
      variables: {
        'options': {
          'paginate': {'page': 1, 'limit': 50},
        },
      },
    );

    return result.when(
      success: (response) {
        final visits = response.connectionItems('visits');
        if (visits == null) {
          return const Result.failure(ParsingException());
        }
        return Result.success(
          visits.map((e) => VisitModel.fromGraphQL(e)).toList(),
        );
      },
      failure: (e) => Result.failure(e),
    );
  }

  Future<Result<VisitModel>> getVisit(String id) async {
    final result = await _graphQLService.query(
      GraphQLQueries.getVisit,
      variables: {'id': id},
    );

    return result.when(
      success: (response) {
        final visit = response.object('visit');
        if (visit == null) {
          return const Result.failure(ParsingException());
        }
        return Result.success(VisitModel.fromGraphQL(visit));
      },
      failure: (e) => Result.failure(e),
    );
  }

  Future<Result<VisitModel>> createVisit(VisitModel visit) async {
    final result = await _graphQLService.mutate(
      GraphQLQueries.createVisit,
      variables: {
        'input': {
          'childId': visit.childId,
          'visitType': visit.visitType,
          'visitDate': visit.visitDate?.toIso8601String(),
          'purpose': visit.purpose,
          'physician': visit.physician,
          'hospital': visit.hospital,
          'comment': visit.comment,
          'documents': visit.toJson()['documents'],
        },
      },
    );

    return result.when(
      success: (response) {
        final created = response.object('createVisit');
        if (created == null) {
          return const Result.failure(ParsingException());
        }
        return Result.success(VisitModel.fromGraphQL(created));
      },
      failure: (e) => Result.failure(e),
    );
  }

  Future<Result<VisitModel>> updateVisit(VisitModel visit) async {
    final result = await _graphQLService.mutate(
      GraphQLQueries.updateVisit,
      variables: {
        'id': visit.id,
        'input': {
          'childId': visit.childId,
          'visitType': visit.visitType,
          'visitDate': visit.visitDate?.toIso8601String(),
          'purpose': visit.purpose,
          'physician': visit.physician,
          'hospital': visit.hospital,
          'comment': visit.comment,
          'documents': visit.toJson()['documents'],
        },
      },
    );

    return result.when(
      success: (response) {
        final updated = response.object('updateVisit');
        if (updated == null) {
          return const Result.failure(ParsingException());
        }
        return Result.success(VisitModel.fromGraphQL(updated));
      },
      failure: (e) => Result.failure(e),
    );
  }

  Future<Result<void>> deleteVisit(String id) async {
    final result = await _graphQLService.mutate(
      GraphQLQueries.deleteVisit,
      variables: {'id': id},
    );

    return result.when(
      success: (_) => const Result.success(null),
      failure: (e) => Result.failure(e),
    );
  }
}
