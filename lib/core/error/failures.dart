import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Represents validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Represents server/API failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Represents network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Represents authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

/// Represents database operation failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Represents unexpected failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}

/// Represents cache-related failures
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Represents storage/file system failures
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// Represents permission/access failures
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied']);
}

/// Represents audio recording failures
class RecordingFailure extends Failure {
  const RecordingFailure(super.message);
}

class InvalidEmailFailure extends Failure {
  const InvalidEmailFailure() : super('Invalid email format');
}

class InvalidPasswordFailure extends Failure {
  const InvalidPasswordFailure()
    : super('Password must be at least 6 characters');
}




/// ------------------------------------------------------------
/// 
/// 
