import 'exceptions.dart';

sealed class DataResult<S> {
  const DataResult();
  factory DataResult.failure(Failure failure) => _FailureResult<S>(failure);
  factory DataResult.success(S data) => _SuccessResult<S>(data);

  Failure? get error => switch (this) {
    _FailureResult(:final _value) => _value,
    _SuccessResult() => null,
  };

  S? get data => switch (this) {
    _SuccessResult(:final _value) => _value,
    _FailureResult() => null,
  };

  T fold<T>(
    T Function(Failure error) fnFailure,
    T Function(S data) fnData,
  ) => switch (this) {
    _FailureResult(:final _value) => fnFailure(_value),
    _SuccessResult(:final _value) => fnData(_value),
  };
}

class _SuccessResult<S> extends DataResult<S> {
  const _SuccessResult(this._value);
  final S _value;

  @override
  T fold<T>(
    T Function(Failure error) fnFailure,
    T Function(S data) fnData,
  ) => fnData(_value);
}

class _FailureResult<S> extends DataResult<S> {
  const _FailureResult(this._value);
  final Failure _value;

  @override
  T fold<T>(
    T Function(Failure error) fnFailure,
    T Function(S data) fnData,
  ) => fnFailure(_value);
}
