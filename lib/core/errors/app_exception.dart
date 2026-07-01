/// Base exception class for the KinCare application.
sealed class AppException implements Exception {
  const AppException(this.message, [this.stackTrace]);

  /// Human-readable error message.
  final String message;

  /// Optional stack trace for debugging.
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when there is no internet connectivity.
final class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

/// Thrown when a request exceeds the timeout duration.
final class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out']);
}

/// Thrown when a GraphQL operation fails.
final class GraphQLException extends AppException {
  const GraphQLException(super.message, {this.errors});

  /// Raw GraphQL error list for debugging.
  final List<dynamic>? errors;
}

/// Thrown when response parsing fails.
final class ParsingException extends AppException {
  const ParsingException([super.message = 'Failed to parse response']);
}

/// Thrown when authentication fails or session expires.
final class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed']);
}

/// Thrown for any unhandled or unexpected errors.
final class UnexpectedException extends AppException {
  const UnexpectedException([
    super.message = 'An unexpected error occurred',
    super.stackTrace,
  ]);
}

/// Thrown when requested data is not found in cache.
final class CacheException extends AppException {
  const CacheException([super.message = 'No cached data available']);
}
