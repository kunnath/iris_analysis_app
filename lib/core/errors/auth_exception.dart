class AuthException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  const AuthException(
    this.message, {
    this.code,
    this.originalException,
  });

  @override
  String toString() => 'AuthException: $message';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthException &&
        other.message == message &&
        other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ (code?.hashCode ?? 0);
}

class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException(this.message, {this.statusCode});

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  const ValidationException(this.message, {this.fieldErrors});

  @override
  String toString() => 'ValidationException: $message';
}

class StorageException implements Exception {
  final String message;
  final String? path;

  const StorageException(this.message, {this.path});

  @override
  String toString() => 'StorageException: $message';
}

class SubscriptionException implements Exception {
  final String message;
  final String? productId;

  const SubscriptionException(this.message, {this.productId});

  @override
  String toString() => 'SubscriptionException: $message';
}