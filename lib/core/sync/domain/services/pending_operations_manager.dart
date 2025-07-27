import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/core/sync/data/repositories/pending_operations_repository.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// 🧠 UPSTREAM SYNC BRAIN
///
/// Manages the pending sync operations queue for offline changes.
/// Ensures that no offline operation is lost and that all eventually
/// reach the server.
///
/// RESPONSIBILITIES:
/// 1. 📥 QUEUE: Receives operations from repositories and stores them in Isar
/// 2. ⚡ PROCESS: Executes pending operations when network is available
/// 3. 🔄 RETRY: Retries failed operations up to a maximum number of attempts
/// 4. 🧹 CLEANUP: Removes completed operations and those exceeding the retry limit
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
  // ============================================================================
  // 📥 Queue Operations (Called by Repositories)
  // ============================================================================

  /// Core method to add any operation to the queue
  /// Repositories use the specific helpers below this method
  Future<Either<Failure, Unit>> addOperation({
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
    return result.fold(
      (failure) =>
          Left(failure), // ❌ Queue failed - Repository must handle this
      (success) => Right(unit), // ✅ Queued successfully
    );
  }

  /// 🔧 HELPER: Repositories call this when user creates entities offline
  /// Helper: Repositories call this when the user creates entities offline
  Future<Either<Failure, Unit>> addCreateOperation({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
    SyncPriority priority = SyncPriority.medium,
  }) async {
    return await addOperation(
      entityType: entityType,
      entityId: entityId,
      operationType: 'create',
      priority: priority,
      data: data,
    );
  }

  /// 📝 HELPER: Repositories call this when user updates entities offline
  /// Helper: Repositories call this when the user updates entities offline
  Future<Either<Failure, Unit>> addUpdateOperation({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
    SyncPriority priority = SyncPriority.medium,
  }) async {
    return await addOperation(
      entityType: entityType,
      entityId: entityId,
      operationType: 'update',
      priority: priority,
      data: data,
    );
  }

  /// 🗑️ HELPER: Repositories call this when user deletes entities offline
  /// Helper: Repositories call this when the user deletes entities offline
  Future<Either<Failure, Unit>> addDeleteOperation({
    required String entityType,
    required String entityId,
    SyncPriority priority = SyncPriority.medium,
  }) async {
    return await addOperation(
      entityType: entityType,
      entityId: entityId,
      operationType: 'delete',
      priority: priority,
    );
  }
  // ============================================================================
  // ⚡ Processing Operations (Called by BackgroundSyncCoordinator)
  // ============================================================================

  /// 🚀 MAIN ENTRY POINT: BackgroundSyncCoordinator calls this
  /// Processes all pending operations when network is available
  Future<void> processPendingOperations() async {
    // 📶 Only process if there is a network connection
    if (!await _networkStateManager.isConnected) {
      return;
    }

    // 🔄 Retry logic for getting pending operations
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      final result = await _repository.getPendingOperations();

      await result.fold(
        (failure) async {
          // 💥 Error getting operations from local database
          final errorMsg =
              'Failed to get pending operations (attempt $attempt/$maxRetries): ${failure.message}';

          AppLogger.error(errorMsg, tag: 'PendingOperationsManager');

          // 🔄 Retry logic
          if (attempt < maxRetries) {
            // Wait before retrying
            await Future.delayed(retryDelay);
            return; // Continue to next retry attempt
          }

          // 💀 All retries exhausted - this is a serious issue
          AppLogger.critical(
            'Exhausted retries getting pending operations. Database may have issues.',
            tag: 'PendingOperationsManager',
          );
          // ErrorMonitoringService.reportError(failure, context: 'upstream_sync_db_failure');
        },
        (operations) async {
          try {
            // ✅ Got operations - process them by priority
            await _processOperationsByPriority(operations);

            // 📈 Success logging
            if (operations.isNotEmpty) {
              AppLogger.info(
                'Successfully processed ${operations.length} pending operations',
                tag: 'PendingOperationsManager',
              );
            }

            return; // Success - exit retry loop
          } catch (e) {
            // 💥 Error during operation processing
            AppLogger.error(
              'Error processing operations: $e',
              tag: 'PendingOperationsManager',
            );

            // Don't retry processing errors - individual operations have their own retry logic
            return;
          }
        },
      );

      // If we reach here, we had a failure and need to retry
      // (only happens if we're in the failure case and attempt < maxRetries)
    }
  }

  /// 📊 Processes operations grouped by priority
  /// ORDER: Critical → High → Medium → Low
  Future<void> _processOperationsByPriority(
    List<SyncOperationDocument> operations,
  ) async {
    // 🗂️ Group operations by priority
    final operationsByPriority = <SyncPriority, List<SyncOperationDocument>>{};

    for (final operation in operations) {
      final priority = _getPriorityEnum(operation.priority);
      operationsByPriority.putIfAbsent(priority, () => []).add(operation);
    }

    // ⚡ Process in priority order: most important first
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

  /// 🔄 Processes ONE individual operation
  /// FLOW: Check retry limit → Execute → Mark completed/failed
  Future<void> _processOperation(SyncOperationDocument operation) async {
    // 🚫 Skip if operation exceeded retry limit
    if (!operation.canRetry()) {
      await _repository.deleteOperation(operation.id);
      return;
    }

    try {
      // ⚡ Execute the operation (calls remote API)
      await _executeOperation(operation);

      // ✅ Success: Mark as completed (will be cleaned up later)
      await _repository.markOperationCompleted(operation.id);
    } catch (e) {
      // ❌ Failed: Increment retry count, will retry later
      await _repository.markOperationFailed(operation.id, e.toString());
    }
  }

  /// 🎯 Delegates execution to appropriate OperationExecutor
  /// Executor handles the actual API call for each entity type
  Future<void> _executeOperation(SyncOperationDocument operation) async {
    final executor = _executorFactory.getExecutor(operation.entityType);
    await executor.execute(operation);
  }

  // ============================================================================
  // 📊 MONITORING & STATISTICS (Called by BackgroundSyncCoordinator)
  // ============================================================================
  // ============================================================================
  // 📊 MONITORING & STATISTICS (Called by BackgroundSyncCoordinator)
  // ============================================================================

  /// 📈 Count pending operations for UI progress indicators
  Future<int> getPendingOperationsCount() async {
    final result = await _repository.getPendingOperationsCount();
    return result.fold((failure) => 0, (count) => count);
  }

  /// 👀 Stream pending operations for real-time UI updates
  Stream<List<SyncOperationDocument>> watchPendingOperations() {
    return _repository.watchPendingOperations();
  }

  /// 🏥 Get upstream sync health status for monitoring and debugging
  /// Returns information about queue health, error rates, and processing status
  Future<Map<String, dynamic>> getUpstreamSyncHealth() async {
    try {
      final pendingResult = await _repository.getPendingOperations();

      return await pendingResult.fold(
        (failure) async {
          // 🚨 Database access failed - critical issue
          return {
            'status': 'critical',
            'canAccessDatabase': false,
            'error': failure.message,
            'pendingCount': 0,
            'failedCount': 0,
            'oldestPendingAge': null,
            'timestamp': DateTime.now().toIso8601String(),
          };
        },
        (operations) async {
          // ✅ Database accessible - analyze operations
          final now = DateTime.now();
          final failed = operations.where((op) => !op.canRetry()).length;
          final pending = operations.length - failed;

          // Find oldest pending operation
          DateTime? oldestTimestamp;
          if (operations.isNotEmpty) {
            oldestTimestamp = operations
                .map((op) => op.timestamp)
                .reduce((a, b) => a.isBefore(b) ? a : b);
          }

          final oldestAge =
              oldestTimestamp != null
                  ? now.difference(oldestTimestamp).inMinutes
                  : null;

          // Determine health status
          String status;
          if (failed > 0 && pending == 0) {
            status = 'degraded'; // Only failed operations
          } else if (oldestAge != null && oldestAge > 60) {
            status = 'degraded'; // Operations stuck for > 1 hour
          } else if (pending > 50) {
            status = 'degraded'; // Too many pending operations
          } else {
            status = 'healthy';
          }

          return {
            'status': status,
            'canAccessDatabase': true,
            'pendingCount': pending,
            'failedCount': failed,
            'totalCount': operations.length,
            'oldestPendingAge': oldestAge,
            'networkConnected': await _networkStateManager.isConnected,
            'timestamp': DateTime.now().toIso8601String(),
          };
        },
      );
    } catch (e) {
      // 💥 Unexpected error
      return {
        'status': 'critical',
        'canAccessDatabase': false,
        'error': e.toString(),
        'pendingCount': 0,
        'failedCount': 0,
        'oldestPendingAge': null,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  // ============================================================================
  // 🧹 CLEANUP (Called by BackgroundSyncCoordinator)
  // ============================================================================
  // ============================================================================
  // 🧹 CLEANUP (Called by BackgroundSyncCoordinator)
  // ============================================================================

  /// 🗑️ Remove completed operations to keep queue manageable
  /// BackgroundSyncCoordinator calls this periodically
  Future<void> clearCompletedOperations() async {
    await _repository.clearCompletedOperations();
  }

  // ============================================================================
  // 🔧 HELPERS
  // ============================================================================
  // ============================================================================
  // 🔧 HELPERS
  // ============================================================================

  /// Parse priority string to enum
  SyncPriority _getPriorityEnum(String priority) {
    return SyncPriority.values.firstWhere(
      (p) => p.name == priority,
      orElse: () => SyncPriority.medium,
    );
  }
}
