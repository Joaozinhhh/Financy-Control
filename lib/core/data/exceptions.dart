

abstract class Failure implements Exception {
  const Failure();

  String get message;

  @override
  String toString() {
    return '$runtimeType Exception';
  }
}

class NetworkFailure implements Failure {
  final String _message;
  const NetworkFailure(this._message);

  @override
  String get message => _message;
}

class UnknownFailure implements Failure {
  final String _message;
  const UnknownFailure(this._message);

  @override
  String get message => _message;
}
