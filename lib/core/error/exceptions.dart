class ServerException implements Exception {
  final String? message;
  final String? code;

  ServerException({this.message, this.code});
}

class NetworkException implements Exception {
  final String? message;
  final String? code;

  NetworkException({this.message, this.code});
}

class CacheException implements Exception {
  final String? message;
  final String? code;

  CacheException({this.message, this.code});
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);
}

class AuthenticationException implements Exception {
  final String? message;
  final String? code;

  AuthenticationException({this.message, this.code});
}

class DatabaseException implements Exception {
  final String? message;
  final String? code;

  DatabaseException({this.message, this.code});
}
