import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';

void main() {
  group('Result', () {
    test('Result.success wraps the data and reports isSuccess', () {
      const result = Result<int>.success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, 42);
    });

    test('Result.failure wraps the exception and reports isFailure', () {
      const exception = NetworkException();
      const result = Result<int>.failure(exception);

      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.dataOrNull, isNull);
    });

    test('when() invokes the success branch for a Success', () {
      const result = Result<String>.success('hello');

      final output = result.when(
        success: (data) => 'got: $data',
        failure: (e) => 'error: ${e.message}',
      );

      expect(output, 'got: hello');
    });

    test('when() invokes the failure branch for a Failure', () {
      const result = Result<String>.failure(AuthException('bad token'));

      final output = result.when(
        success: (data) => 'got: $data',
        failure: (e) => 'error: ${e.message}',
      );

      expect(output, 'error: bad token');
    });

    test('Success exposes its data field directly', () {
      const success = Success<int>(7);
      expect(success.data, 7);
    });

    test('Failure exposes its exception field directly', () {
      const failure = Failure<int>(CacheException());
      expect(failure.exception, isA<CacheException>());
    });

    test('Result<void> failures report isFailure correctly', () {
      const result = Result<void>.failure(UnexpectedException());
      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
    });
  });
}
