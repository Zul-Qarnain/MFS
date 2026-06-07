/// Base error class. Every thrown error in the app extends [MfsException].
abstract class MfsException implements Exception {
  const MfsException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'MfsException($code): $message';
}

class NetworkException extends MfsException {
  const NetworkException(super.message, {super.code, this.statusCode});
  final int? statusCode;
}

class ProviderException extends MfsException {
  const ProviderException(super.message, {super.code, this.providerId});
  final String? providerId;
}

class SecurityException extends MfsException {
  const SecurityException(super.message, {super.code});
}

class ValidationException extends MfsException {
  const ValidationException(super.message, {super.code, this.field});
  final String? field;
}
