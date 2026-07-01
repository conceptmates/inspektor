/// Sealed result of every API call. Callers handle outcomes with an exhaustive
/// switch — no try/catch needed for normal HTTP/network outcomes.
sealed class ApiResult<T> {
  const ApiResult();
}

final class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

final class ApiBadRequest<T> extends ApiResult<T> {
  final String? message;
  const ApiBadRequest({this.message});
}

final class ApiUnauthorized<T> extends ApiResult<T> {
  final String? message;
  const ApiUnauthorized({this.message});
}

final class ApiForbidden<T> extends ApiResult<T> {
  final String? message;
  const ApiForbidden({this.message});
}

final class ApiNotFound<T> extends ApiResult<T> {
  final String? message;
  const ApiNotFound({this.message});
}

/// Other 4xx (e.g. 409, 422).
final class ApiClientError<T> extends ApiResult<T> {
  final int? statusCode;
  final String? message;
  const ApiClientError({this.statusCode, this.message});
}

/// 5xx.
final class ApiServerError<T> extends ApiResult<T> {
  final int? statusCode;
  final String? message;
  const ApiServerError({this.statusCode, this.message});
}

/// Connection / timeout / no network.
final class ApiNetworkError<T> extends ApiResult<T> {
  final String? message;
  const ApiNetworkError({this.message});
}

/// Re-type a non-success result to a new payload type T (for repositories that
/// transform the success payload but pass errors through unchanged).
ApiResult<T> castApiError<T>(ApiResult<Object?> r) => switch (r) {
      ApiSuccess() => throw StateError('castApiError called on ApiSuccess'),
      ApiBadRequest(:final message) => ApiBadRequest<T>(message: message),
      ApiUnauthorized(:final message) => ApiUnauthorized<T>(message: message),
      ApiForbidden(:final message) => ApiForbidden<T>(message: message),
      ApiNotFound(:final message) => ApiNotFound<T>(message: message),
      ApiClientError(:final statusCode, :final message) =>
        ApiClientError<T>(statusCode: statusCode, message: message),
      ApiServerError(:final statusCode, :final message) =>
        ApiServerError<T>(statusCode: statusCode, message: message),
      ApiNetworkError(:final message) => ApiNetworkError<T>(message: message),
    };
