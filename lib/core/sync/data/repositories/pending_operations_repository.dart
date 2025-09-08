import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/core/sync/data/datasources/pending_operations_local_datasource.dart';

/// Repository for managing pending sync operations
abstract class PendingOperationsRepository {
  Future<Either<Failure, Unit>> addOperation(SyncOperationDocument operation);
  Future<Either<Failure, List<SyncOperationDocument>>> getPendingOperations();
  Future<Either<Failure, List<SyncOperationDocument>>> getOperationsByPriority(
    SyncPriority priority,
  );
  Future<Either<Failure, Unit>> markOperationCompleted(int operationId);
  Future<Either<Failure, Unit>> markOperationFailed(
    int operationId,
    String error,
  );
  Future<Either<Failure, Unit>> deleteOperation(int operationId);
  Future<Either<Failure, Unit>> clearCompletedOperations();
  Future<Either<Failure, Unit>> clearAllOperations();
  Future<Either<Failure, int>> getPendingOperationsCount();
  Stream<List<SyncOperationDocument>> watchPendingOperations();
}

@LazySingleton(as: PendingOperationsRepository)
class PendingOperationsRepositoryImpl implements PendingOperationsRepository {
  final PendingOperationsLocalDataSource _localDataSource;

  PendingOperationsRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, Unit>> addOperation(
    SyncOperationDocument operation,
  ) async {
    try {
      await _localDataSource.insertOperation(operation);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add sync operation: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SyncOperationDocument>>>
  getPendingOperations() async {
    try {
      final operations = await _localDataSource.getPendingOperations();
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
      final operations = await _localDataSource.getOperationsByPriority(
        priority.name,
      );
      return Right(operations);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get operations by priority: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> markOperationCompleted(int operationId) async {
    try {
      final operations = await _localDataSource.getPendingOperations();
      final operation = operations.firstWhere((op) => op.id == operationId);
      operation.markAsCompleted();
      await _localDataSource.updateOperation(operation);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to mark operation completed: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> markOperationFailed(
    int operationId,
    String error,
  ) async {
    try {
      final operations = await _localDataSource.getPendingOperations();
      final operation = operations.firstWhere((op) => op.id == operationId);
      operation.markAsFailed(error);
      await _localDataSource.updateOperation(operation);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to mark operation failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteOperation(int operationId) async {
    try {
      await _localDataSource.deleteOperation(operationId);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete operation: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCompletedOperations() async {
    try {
      await _localDataSource.deleteCompletedOperations();
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to clear completed operations: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearAllOperations() async {
    try {
      await _localDataSource.clearAllOperations();
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to clear all operations: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getPendingOperationsCount() async {
    try {
      final count = await _localDataSource.getPendingOperationsCount();
      return Right(count);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to get pending operations count: $e'),
      );
    }
  }

  @override
  Stream<List<SyncOperationDocument>> watchPendingOperations() {
    return _localDataSource.watchPendingOperations();
  }
}
