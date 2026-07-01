import 'app_exception.dart';

/// A discriminated union representing either success or failure.
sealed class Result<T> {
  const Result();

  /// Creates a successful result.
  const factory Result.success(T data) = Success<T>;

  /// Creates a failure result.
  const factory Result.failure(AppException exception) = Failure<T>;

  /// Pattern-matches on the result, calling [onSuccess] or [onFailure].
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) {
    return switch (this) {
      Success<T>(data: final d) => success(d),
      Failure<T>(exception: final e) => failure(e),
    };
  }

  /// Returns the data if successful, or null on failure.
  T? get dataOrNull => switch (this) {
    Success<T>(data: final d) => d,
    Failure<T>() => null,
  };

  /// Returns true if this result represents a success.
  bool get isSuccess => this is Success<T>;

  /// Returns true if this result represents a failure.
  bool get isFailure => this is Failure<T>;
}

/// Represents a successful outcome containing [data].
final class Success<T> extends Result<T> {
  const Success(this.data);

  /// The successful value.
  final T data;
}

/// Represents a failed outcome containing an [exception].
final class Failure<T> extends Result<T> {
  const Failure(this.exception);

  /// The exception describing the failure.
  final AppException exception;
}
