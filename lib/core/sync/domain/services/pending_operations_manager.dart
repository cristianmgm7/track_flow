import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';

/// Manages pending sync operations queue for offline changes
@lazySingleton
class PendingOperationsManager {
  final PendingOperationsRepository _repository;
  final NetworkStateManager _networkStateManager;
  final ProjectRemoteDataSource _projectRemoteDataSource;

  PendingOperationsManager(
    this._repository,
    this._networkStateManager,
    this._projectRemoteDataSource,
  );

  /// Add a new operation to the pending queue
  Future<void> addOperation({
    required String entityType,
    required String entityId,
    required String operationType,
    required SyncPriority priority,
    Map<String, dynamic>? data,
  }) async {
    final operation = SyncOperationDocument.create(
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      priority: priority,
      operationData: data != null ? jsonEncode(data) : null,
    );

    final result = await _repository.addOperation(operation);
    result.fold(
      (failure) {
        // Log error - TODO: Use proper logging
        // print('Failed to add pending operation: ${failure.message}');
      },
      (success) {
        // Operation added successfully
      },
    );
  }

  /// Add create operation
  Future<void> addCreateOperation({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
    SyncPriority priority = SyncPriority.medium,
  }) async {
    await addOperation(
      entityType: entityType,
      entityId: entityId,
      operationType: 'create',
      priority: priority,
      data: data,
    );
  }

  /// Add update operation
  Future<void> addUpdateOperation({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
    SyncPriority priority = SyncPriority.medium,
  }) async {
    await addOperation(
      entityType: entityType,
      entityId: entityId,
      operationType: 'update',
      priority: priority,
      data: data,
    );
  }

  /// Add delete operation
  Future<void> addDeleteOperation({
    required String entityType,
    required String entityId,
    SyncPriority priority = SyncPriority.medium,
  }) async {
    await addOperation(
      entityType: entityType,
      entityId: entityId,
      operationType: 'delete',
      priority: priority,
    );
  }

  /// Process all pending operations
  Future<void> processPendingOperations() async {
    // Check network connectivity
    if (!await _networkStateManager.isConnected) {
      return;
    }

    final result = await _repository.getPendingOperations();
    await result.fold(
      (failure) async {
        // Handle error
      },
      (operations) async {
        // Process operations by priority
        await _processOperationsByPriority(operations);
      },
    );
  }

  /// Process operations grouped by priority
  Future<void> _processOperationsByPriority(
    List<SyncOperationDocument> operations,
  ) async {
    // Group operations by priority
    final operationsByPriority = <SyncPriority, List<SyncOperationDocument>>{};
    
    for (final operation in operations) {
      final priority = _getPriorityEnum(operation.priority);
      operationsByPriority.putIfAbsent(priority, () => []).add(operation);
    }

    // Process in priority order
    final priorities = [
      SyncPriority.critical,
      SyncPriority.high,
      SyncPriority.medium,
      SyncPriority.low,
    ];

    for (final priority in priorities) {
      final priorityOperations = operationsByPriority[priority] ?? [];
      for (final operation in priorityOperations) {
        await _processOperation(operation);
      }
    }
  }

  /// Process a single operation
  Future<void> _processOperation(SyncOperationDocument operation) async {
    // Check if operation can be retried
    if (!operation.canRetry()) {
      await _repository.deleteOperation(operation.id);
      return;
    }

    try {
      // Execute the operation based on type
      await _executeOperation(operation);
      
      // Mark as completed
      await _repository.markOperationCompleted(operation.id);
      
    } catch (e) {
      // Mark as failed
      await _repository.markOperationFailed(operation.id, e.toString());
    }
  }

  /// Execute the actual operation
  Future<void> _executeOperation(SyncOperationDocument operation) async {
    // This is a simplified implementation
    // In practice, you would delegate to appropriate services
    
    switch (operation.entityType) {
      case 'project':
        await _executeProjectOperation(operation);
        break;
      case 'audio_track':
        await _executeAudioTrackOperation(operation);
        break;
      case 'audio_comment':
        await _executeAudioCommentOperation(operation);
        break;
      case 'user_profile':
        await _executeUserProfileOperation(operation);
        break;
      default:
        throw UnsupportedError('Unknown entity type: ${operation.entityType}');
    }
  }

  /// Execute project-specific operation
  Future<void> _executeProjectOperation(SyncOperationDocument operation) async {
    final operationData = operation.operationData != null 
        ? jsonDecode(operation.operationData!) as Map<String, dynamic>
        : <String, dynamic>{};

    switch (operation.operationType) {
      case 'create':
        final projectDto = ProjectDTO(
          id: operation.entityId,
          name: operationData['name'] ?? '',
          description: operationData['description'] ?? '',
          ownerId: operationData['ownerId'] ?? '',
          createdAt: DateTime.parse(operationData['createdAt'] ?? DateTime.now().toIso8601String()),
          updatedAt: null,
        );
        await _projectRemoteDataSource.createProject(projectDto);
        break;
        
      case 'update':
        final projectDto = ProjectDTO(
          id: operation.entityId,
          name: operationData['name'] ?? '',
          description: operationData['description'] ?? '',
          ownerId: operationData['ownerId'] ?? '',
          createdAt: DateTime.now(), // This should come from local data
          updatedAt: DateTime.parse(operationData['updatedAt'] ?? DateTime.now().toIso8601String()),
        );
        await _projectRemoteDataSource.updateProject(projectDto);
        break;
        
      case 'delete':
        await _projectRemoteDataSource.deleteProject(operation.entityId);
        break;
        
      default:
        throw UnsupportedError('Unknown project operation: ${operation.operationType}');
    }
  }

  /// Execute audio track operation
  Future<void> _executeAudioTrackOperation(SyncOperationDocument operation) async {
    // NOTE: AudioTrack operations are handled by the repository's remote data source
    // This would require injecting AudioTrackRemoteDataSource and implementing
    // similar logic to project operations above.
    // For now, we'll skip audio track remote sync (operations stay queued)
    throw UnimplementedError('Audio track remote sync operations require data source injection');
  }

  /// Execute audio comment operation
  Future<void> _executeAudioCommentOperation(SyncOperationDocument operation) async {
    // NOTE: AudioComment operations are handled by the repository's remote data source
    // This would require injecting AudioCommentRemoteDataSource and implementing
    // similar logic to project operations above.
    // For now, we'll skip audio comment remote sync (operations stay queued)
    throw UnimplementedError('Audio comment remote sync operations require data source injection');
  }

  /// Execute user profile operation
  Future<void> _executeUserProfileOperation(SyncOperationDocument operation) async {
    // NOTE: UserProfile operations are handled by the repository's remote data source
    // This would require injecting UserProfileRemoteDataSource and implementing
    // similar logic to project operations above.
    // For now, we'll skip user profile remote sync (operations stay queued)
    throw UnimplementedError('User profile remote sync operations require data source injection');
  }

  /// Get count of pending operations
  Future<int> getPendingOperationsCount() async {
    final result = await _repository.getPendingOperationsCount();
    return result.fold(
      (failure) => 0,
      (count) => count,
    );
  }

  /// Watch pending operations stream
  Stream<List<SyncOperationDocument>> watchPendingOperations() {
    return _repository.watchPendingOperations();
  }

  /// Clear completed operations (cleanup)
  Future<void> clearCompletedOperations() async {
    await _repository.clearCompletedOperations();
  }

  /// Get priority enum from string
  SyncPriority _getPriorityEnum(String priority) {
    return SyncPriority.values.firstWhere(
      (p) => p.name == priority,
      orElse: () => SyncPriority.medium,
    );
  }
}