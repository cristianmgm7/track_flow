import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart';

/// Manages pending sync operations queue for offline changes
/// 
/// This manager coordinates the execution of pending operations
/// by delegating to appropriate operation executors via the factory pattern.
/// It maintains single responsibility by focusing on queue management and coordination.
@lazySingleton
class PendingOperationsManager {
  final PendingOperationsRepository _repository;
  final NetworkStateManager _networkStateManager;
  final OperationExecutorFactory _executorFactory;

  PendingOperationsManager(
    this._repository,
    this._networkStateManager,
    this._executorFactory,
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

  /// Execute the actual operation by delegating to appropriate executor
  Future<void> _executeOperation(SyncOperationDocument operation) async {
    final executor = _executorFactory.getExecutor(operation.entityType);
    await executor.execute(operation);
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