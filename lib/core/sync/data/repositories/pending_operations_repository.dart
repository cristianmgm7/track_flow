import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';

/// Repository for managing pending sync operations
abstract class PendingOperationsRepository {
  Future<Either<Failure, Unit>> addOperation(SyncOperationDocument operation);
  Future<Either<Failure, List<SyncOperationDocument>>> getPendingOperations();
  Future<Either<Failure, List<SyncOperationDocument>>> getOperationsByPriority(SyncPriority priority);
  Future<Either<Failure, Unit>> markOperationCompleted(int operationId);
  Future<Either<Failure, Unit>> markOperationFailed(int operationId, String error);
  Future<Either<Failure, Unit>> deleteOperation(int operationId);
  Future<Either<Failure, Unit>> clearCompletedOperations();
  Future<Either<Failure, int>> getPendingOperationsCount();
  Stream<List<SyncOperationDocument>> watchPendingOperations();
}

@LazySingleton(as: PendingOperationsRepository)
class PendingOperationsRepositoryImpl implements PendingOperationsRepository {
  final Isar _isar;

  PendingOperationsRepositoryImpl(this._isar);

  @override
  Future<Either<Failure, Unit>> addOperation(SyncOperationDocument operation) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.syncOperationDocuments.put(operation);
      });
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add sync operation: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SyncOperationDocument>>> getPendingOperations() async {
    try {
      final operations = await _isar.syncOperationDocuments
          .where()
          .isCompletedEqualTo(false)
          .sortByTimestamp()
          .findAll();
      
      return Right(operations);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get pending operations: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SyncOperationDocument>>> getOperationsByPriority(
    SyncPriority priority,
  ) async {
    try {
      final operations = await _isar.syncOperationDocuments
          .where()
          .isCompletedEqualTo(false)
          .filter()
          .priorityEqualTo(priority.name)
          .sortByTimestamp()
          .findAll();
      
      return Right(operations);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get operations by priority: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> markOperationCompleted(int operationId) async {
    try {
      await _isar.writeTxn(() async {
        final operation = await _isar.syncOperationDocuments.get(operationId);
        if (operation != null) {
          operation.markAsCompleted();
          await _isar.syncOperationDocuments.put(operation);
        }
      });
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to mark operation completed: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> markOperationFailed(int operationId, String error) async {
    try {
      await _isar.writeTxn(() async {
        final operation = await _isar.syncOperationDocuments.get(operationId);
        if (operation != null) {
          operation.markAsFailed(error);
          await _isar.syncOperationDocuments.put(operation);
        }
      });
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to mark operation failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteOperation(int operationId) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.syncOperationDocuments.delete(operationId);
      });
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete operation: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCompletedOperations() async {
    try {
      await _isar.writeTxn(() async {
        final completedOperations = await _isar.syncOperationDocuments
            .where()
            .isCompletedEqualTo(true)
            .findAll();
        
        final ids = completedOperations.map((op) => op.id).toList();
        await _isar.syncOperationDocuments.deleteAll(ids);
      });
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to clear completed operations: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getPendingOperationsCount() async {
    try {
      final count = await _isar.syncOperationDocuments
          .where()
          .isCompletedEqualTo(false)
          .count();
      
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get pending operations count: $e'));
    }
  }

  @override
  Stream<List<SyncOperationDocument>> watchPendingOperations() {
    return _isar.syncOperationDocuments
        .where()
        .isCompletedEqualTo(false)
        .sortByTimestamp()
        .watch(fireImmediately: true);
  }
}