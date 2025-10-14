import 'package:financy_control/core/data/data.dart';
import 'package:flutter_test/flutter_test.dart';

// Dummy Failure class for testing
class DummyFailure extends Failure {
  DummyFailure(this._message) : super();
  final String _message;

  @override
  String get message => _message;

  @override
  String toString() => 'DummyFailure: $_message';
}

void main() {
  group('DataResult', () {
    test('success returns correct data and null error', () {
      final result = DataResult.success(42);
      expect(result.data, 42);
      expect(result.error, isNull);
    });

    test('failure returns correct error and null data', () {
      final failure = DummyFailure('fail');
      final result = DataResult.failure(failure);
      expect(result.error, failure);
      expect(result.data, isNull);
    });

    test('fold returns correct value for success', () {
      final result = DataResult.success('ok');
      final value = result.fold(
        (error) => 'error',
        (data) => data,
      );
      expect(value, 'ok');
    });

    test('fold returns correct value for failure', () {
      final failure = DummyFailure('fail');
      final result = DataResult.failure(failure);
      final value = result.fold(
        (error) => error.message,
        (data) => 'data',
      );
      expect(value, 'fail');
    });
  });
}
