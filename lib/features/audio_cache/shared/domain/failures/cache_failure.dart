import 'package:equatable/equatable.dart';

/// Base class for all cache-related failures
abstract class CacheFailure extends Equatable {
  const CacheFailure({
    required this.message,
    this.stackTrace,
  });

  final String message;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [message, stackTrace];
}

/// Network-related cache failures
class NetworkCacheFailure extends CacheFailure {
  const NetworkCacheFailure({
    required super.message,
    this.errorCode,
    this.statusCode,
    super.stackTrace,
  });

  final String? errorCode;
  final int? statusCode;

  @override
  List<Object?> get props => [...super.props, errorCode, statusCode];
}

/// Storage-related cache failures
class StorageCacheFailure extends CacheFailure {
  const StorageCacheFailure({
    required super.message,
    required this.type,
    super.stackTrace,
  });

  final StorageFailureType type;

  @override
  List<Object?> get props => [...super.props, type];
}

enum StorageFailureType {
  insufficientSpace,
  permissionDenied,
  diskError,
  fileNotFound,
  fileCorrupted,
  quotaExceeded,
}

/// Permission-related cache failures
class PermissionCacheFailure extends CacheFailure {
  const PermissionCacheFailure({
    required super.message,
    required this.requiredPermission,
    super.stackTrace,
  });

  final String requiredPermission;

  @override
  List<Object?> get props => [...super.props, requiredPermission];
}

/// File corruption cache failures
class CorruptedCacheFailure extends CacheFailure {
  const CorruptedCacheFailure({
    required super.message,
    required this.trackId,
    required this.checksum,
    this.expectedChecksum,
    super.stackTrace,
  });

  final String trackId;
  final String checksum;
  final String? expectedChecksum;

  @override
  List<Object?> get props => [...super.props, trackId, checksum, expectedChecksum];
}

/// CRITICAL: Cache key collision failures - prevents data loss
class CacheKeyCollisionFailure extends CacheFailure {
  const CacheKeyCollisionFailure({
    required super.message,
    required this.trackId,
    required this.existingChecksum,
    required this.conflictingChecksum,
    super.stackTrace,
  });

  final String trackId;
  final String existingChecksum;
  final String conflictingChecksum;

  @override
  List<Object?> get props => [
    ...super.props,
    trackId,
    existingChecksum,
    conflictingChecksum,
  ];
}

/// Download-specific failures
class DownloadCacheFailure extends CacheFailure {
  const DownloadCacheFailure({
    required super.message,
    required this.trackId,
    this.downloadAttempts = 0,
    this.lastAttemptAt,
    super.stackTrace,
  });

  final String trackId;
  final int downloadAttempts;
  final DateTime? lastAttemptAt;

  bool get canRetry => downloadAttempts < 3;

  @override
  List<Object?> get props => [
    ...super.props,
    trackId,
    downloadAttempts,
    lastAttemptAt,
  ];
}

/// Reference counting failures
class ReferenceCacheFailure extends CacheFailure {
  const ReferenceCacheFailure({
    required super.message,
    required this.trackId,
    required this.referenceId,
    this.operation,
    super.stackTrace,
  });

  final String trackId;
  final String referenceId;
  final String? operation;

  @override
  List<Object?> get props => [
    ...super.props,
    trackId,
    referenceId,
    operation,
  ];
}

/// Validation failures
class ValidationCacheFailure extends CacheFailure {
  const ValidationCacheFailure({
    required super.message,
    required this.field,
    required this.value,
    super.stackTrace,
  });

  final String field;
  final dynamic value;

  @override
  List<Object?> get props => [...super.props, field, value];
}

/// Timeout failures
class TimeoutCacheFailure extends CacheFailure {
  const TimeoutCacheFailure({
    required super.message,
    required this.operation,
    required this.timeoutDuration,
    super.stackTrace,
  });

  final String operation;
  final Duration timeoutDuration;

  @override
  List<Object?> get props => [...super.props, operation, timeoutDuration];
}