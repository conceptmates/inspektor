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
