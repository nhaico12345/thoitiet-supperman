// Định nghĩa các loại lỗi (Failure) trong ứng dụng.
// Bao gồm: ServerFailure (lỗi server), CacheFailure (lỗi cache), NetworkFailure (lỗi mạng).

abstract class Failure implements Exception {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
