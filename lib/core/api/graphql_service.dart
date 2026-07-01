import 'package:kincare/app/services/logger_service.dart';
import 'package:kincare/core/api/graphql_json_executor.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';

/// Service layer that executes the app's GraphQL operations against the
/// local JSON-backed executor and wraps the outcome in a [Result].
class GraphQLService {
  GraphQLService();

  final _log = LoggerService.instance;
  final _executor = GraphQLJsonExecutor.instance;

  /// Executes a GraphQL query.
  Future<Result<Map<String, dynamic>>> query(
    String document, {
    Map<String, dynamic>? variables,
    String? operationName,
  }) {
    return _run(document, variables, operationName ?? 'query');
  }

  /// Executes a GraphQL mutation.
  Future<Result<Map<String, dynamic>>> mutate(
    String document, {
    Map<String, dynamic>? variables,
    String? operationName,
  }) {
    return _run(document, variables, operationName ?? 'mutation');
  }

  Future<Result<Map<String, dynamic>>> _run(
    String document,
    Map<String, dynamic>? variables,
    String operationName,
  ) async {
    try {
      final data = await _executor.execute(document, variables ?? const {});
      _log.debug('$operationName completed successfully');
      return Result.success(data);
    } on AppException catch (e) {
      return Result.failure(e);
    } catch (e, st) {
      _log.error('Unexpected error in $operationName', e, st);
      return Result.failure(UnexpectedException(e.toString(), st));
    }
  }
}
