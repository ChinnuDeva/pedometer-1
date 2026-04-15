/// Generic result type for handling success and failure cases
abstract class Result<Success, Failure> {
  const Result();

  factory Result.success(Success data) => _Success<Success, Failure>(data);
  factory Result.failure(Failure error) => _Failure<Success, Failure>(error);

  T fold<T>(
    T Function(Failure) onFailure,
    T Function(Success) onSuccess,
  );

  Result<NewSuccess, Failure> map<NewSuccess>(
    NewSuccess Function(Success) onSuccess,
  );

  Result<Success, NewFailure> mapFailure<NewFailure>(
    NewFailure Function(Failure) onFailure,
  );
}

class _Success<S, F> extends Result<S, F> {

  const _Success(this.data);
  final S data;

  @override
  T fold<T>(
    T Function(F) onFailure,
    T Function(S) onSuccess,
  ) =>
      onSuccess(data);

  @override
  Result<NewSuccess, F> map<NewSuccess>(
    NewSuccess Function(S) onSuccess,
  ) =>
      Result.success(onSuccess(data));

  @override
  Result<S, NewFailure> mapFailure<NewFailure>(
    NewFailure Function(F) onFailure,
  ) =>
      Result.success(data);
}

class _Failure<S, F> extends Result<S, F> {

  const _Failure(this.error);
  final F error;

  @override
  T fold<T>(
    T Function(F) onFailure,
    T Function(S) onSuccess,
  ) =>
      onFailure(error);

  @override
  Result<NewSuccess, F> map<NewSuccess>(
    NewSuccess Function(S) onSuccess,
  ) =>
      Result.failure(error);

  @override
  Result<S, NewFailure> mapFailure<NewFailure>(
    NewFailure Function(F) onFailure,
  ) =>
      Result.failure(onFailure(error));
}
