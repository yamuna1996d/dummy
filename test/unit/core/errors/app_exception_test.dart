import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';

void main() {
  group('AppException hierarchy', () {
    test('NetworkException uses its default message when none is given', () {
      const exception = NetworkException();
      expect(exception.message, 'No internet connection');
    });

    test('NetworkException accepts a custom message', () {
      const exception = NetworkException('custom offline message');
      expect(exception.message, 'custom offline message');
    });

    test('TimeoutException default message', () {
      expect(const TimeoutException().message, 'Request timed out');
    });

    test('ParsingException default message', () {
      expect(const ParsingException().message, 'Failed to parse response');
    });

    test('AuthException default message', () {
      expect(const AuthException().message, 'Authentication failed');
    });

    test('CacheException default message', () {
      expect(const CacheException().message, 'No cached data available');
    });

    test('UnexpectedException default message and optional stack trace', () {
      const exception = UnexpectedException();
      expect(exception.message, 'An unexpected error occurred');
      expect(exception.stackTrace, isNull);
    });

    test('GraphQLException carries the raw error list', () {
      final errors = [
        {'message': 'field not found'},
      ];
      final exception = GraphQLException('query failed', errors: errors);

      expect(exception.message, 'query failed');
      expect(exception.errors, errors);
    });

    test('toString includes the runtime type and message', () {
      const exception = AuthException('session expired');
      expect(exception.toString(), 'AuthException: session expired');
    });

    test('every exception type is an AppException and an Exception', () {
      const exceptions = <AppException>[
        NetworkException(),
        TimeoutException(),
        ParsingException(),
        AuthException(),
        CacheException(),
        UnexpectedException(),
      ];

      for (final e in exceptions) {
        expect(e, isA<AppException>());
        expect(e, isA<Exception>());
      }
    });
  });
}
