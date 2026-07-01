import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('should hold data and report isSuccess', () {
        const result = Result<int>.success(42);

        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
        expect(result.dataOrNull, 42);
      });

      test('should call success branch in when()', () {
        const result = Result<String>.success('hello');

        final value = result.when(
          success: (data) => data.toUpperCase(),
          failure: (_) => 'FAILED',
        );

        expect(value, 'HELLO');
      });
    });

    group('Failure', () {
      test('should hold exception and report isFailure', () {
        const result = Result<int>.failure(NetworkException());

        expect(result.isFailure, isTrue);
        expect(result.isSuccess, isFalse);
        expect(result.dataOrNull, isNull);
      });

      test('should call failure branch in when()', () {
        const result = Result<String>.failure(
          AuthException('Unauthorized'),
        );

        final message = result.when(
          success: (_) => 'ok',
          failure: (e) => e.message,
        );

        expect(message, 'Unauthorized');
      });
    });
  });

  group('AppException', () {
    test('NetworkException has default message', () {
      const e = NetworkException();
      expect(e.message, 'No internet connection');
    });

    test('TimeoutException has default message', () {
      const e = TimeoutException();
      expect(e.message, 'Request timed out');
    });

    test('GraphQLException stores errors list', () {
      const e = GraphQLException('query failed', errors: ['error1']);
      expect(e.message, 'query failed');
      expect(e.errors, ['error1']);
    });

    test('AuthException has custom message', () {
      const e = AuthException('Session expired');
      expect(e.message, 'Session expired');
    });

    test('toString includes type and message', () {
      const e = ParsingException('bad JSON');
      expect(e.toString(), contains('ParsingException'));
      expect(e.toString(), contains('bad JSON'));
    });
  });
}
