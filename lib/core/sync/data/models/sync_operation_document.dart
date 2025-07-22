import 'package:isar/isar.dart';

part 'sync_operation_document.g.dart';

/// Represents a pending sync operation that needs to be executed
/// when connectivity is restored
@collection
class SyncOperationDocument {
  Id id = Isar.autoIncrement;

  /// Type of entity being synced (e.g., 'project', 'audio_track', 'audio_comment')
  @Index()
  late String entityType;
  
  /// ID of the entity being synced
  @Index()
  late String entityId;
  
  /// Type of operation ('create', 'update', 'delete')
  @Index()
  late String operationType;
  
  /// When this operation was created
  @Index()
  late DateTime timestamp;
  
  /// Priority of this operation
  @Index()
  late String priority; // 'critical', 'high', 'medium', 'low'

  /// Serialized data for the operation (JSON string)
  String? operationData;
  
  /// Number of retry attempts
  late int retryCount;
  
  /// Error message if operation failed
  String? errorMessage;
  
  /// Whether this operation is completed
  @Index()
  late bool isCompleted;
  
  /// When this operation was last attempted
  DateTime? lastAttemptTime;

  SyncOperationDocument();

  /// Create a new sync operation
  factory SyncOperationDocument.create({
    required String entityType,
    required String entityId,
    required String operationType,
    required SyncPriority priority,
    String? operationData,
  }) {
    return SyncOperationDocument()
      ..entityType = entityType
      ..entityId = entityId
      ..operationType = operationType
      ..timestamp = DateTime.now()
      ..priority = priority.name
      ..operationData = operationData
      ..retryCount = 0
      ..isCompleted = false;
  }

  /// Mark operation as completed
  void markAsCompleted() {
    isCompleted = true;
  }

  /// Mark operation as failed and increment retry count
  void markAsFailed(String error) {
    retryCount = retryCount + 1;
    errorMessage = error;
    lastAttemptTime = DateTime.now();
  }

  /// Check if operation can be retried
  bool canRetry({int maxRetries = 3}) {
    return retryCount < maxRetries && !isCompleted;
  }
}

/// Priority levels for sync operations
enum SyncPriority {
  critical,  // User profile, authentication
  high,      // Projects, collaborators
  medium,    // Audio tracks
  low,       // Comments, metadata
}

/// Extension for display names
extension SyncPriorityExtension on SyncPriority {
  String get displayName {
    switch (this) {
      case SyncPriority.critical:
        return 'Critical';
      case SyncPriority.high:
        return 'High';
      case SyncPriority.medium:
        return 'Medium';
      case SyncPriority.low:
        return 'Low';
    }
  }

  /// Get sort order (lower number = higher priority)
  int get sortOrder {
    switch (this) {
      case SyncPriority.critical:
        return 0;
      case SyncPriority.high:
        return 1;
      case SyncPriority.medium:
        return 2;
      case SyncPriority.low:
        return 3;
    }
  }
}