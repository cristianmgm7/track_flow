import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';

/// Abstract interface for executing specific types of sync operations
/// 
/// Each entity type (Project, AudioTrack, etc.) will have its own
/// implementation of this interface, following the Strategy pattern.
/// This ensures single responsibility and easy extensibility.
abstract class OperationExecutor {
  /// Execute a sync operation for a specific entity type
  /// 
  /// The executor is responsible for:
  /// - Parsing the operation data
  /// - Calling the appropriate remote data source method
  /// - Handling operation-specific error cases
  /// 
  /// Throws an exception if the operation fails.
  Future<void> execute(SyncOperationDocument operation);
  
  /// Get the entity type this executor handles
  String get entityType;
}