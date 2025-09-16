import 'package:isar/isar.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';

/// Local data source for managing sync operations storage
abstract class PendingOperationsLocalDataSource {
  Future<void> insertOperation(SyncOperationDocument operation);
  Future<List<SyncOperationDocument>> getPendingOperations();
  Future<List<SyncOperationDocument>> getOperationsByPriority(String priority);
  Future<void> updateOperation(SyncOperationDocument operation);
  Future<void> deleteOperation(int operationId);
  Future<void> deleteCompletedOperations();
  Future<void> clearAllOperations();
  Future<int> getPendingOperationsCount();
  Stream<List<SyncOperationDocument>> watchPendingOperations();
}

@LazySingleton(as: PendingOperationsLocalDataSource)
class IsarPendingOperationsLocalDataSource
    implements PendingOperationsLocalDataSource {
  final Isar _isar;

  IsarPendingOperationsLocalDataSource(this._isar);

  @override
  Future<void> insertOperation(SyncOperationDocument operation) async {
    await _isar.writeTxn(() async {
      await _isar.syncOperationDocuments.put(operation);
    });
  }

  @override
  Future<List<SyncOperationDocument>> getPendingOperations() async {
    return await _isar.syncOperationDocuments
        .where()
        .isCompletedEqualTo(false)
        .sortByTimestamp()
        .findAll();
  }

  @override
  Future<List<SyncOperationDocument>> getOperationsByPriority(
    String priority,
  ) async {
    return await _isar.syncOperationDocuments
        .where()
        .isCompletedEqualTo(false)
        .filter()
        .priorityEqualTo(priority)
        .sortByTimestamp()
        .findAll();
  }

  @override
  Future<void> updateOperation(SyncOperationDocument operation) async {
    await _isar.writeTxn(() async {
      await _isar.syncOperationDocuments.put(operation);
    });
  }

  @override
  Future<void> deleteOperation(int operationId) async {
    await _isar.writeTxn(() async {
      await _isar.syncOperationDocuments.delete(operationId);
    });
  }

  @override
  Future<void> deleteCompletedOperations() async {
    await _isar.writeTxn(() async {
      final completedOperations =
          await _isar.syncOperationDocuments
              .where()
              .isCompletedEqualTo(true)
              .findAll();

      final ids = completedOperations.map((op) => op.id).toList();
      await _isar.syncOperationDocuments.deleteAll(ids);
    });
  }

  @override
  Future<void> clearAllOperations() async {
    await _isar.writeTxn(() async {
      await _isar.syncOperationDocuments.clear();
    });
  }

  @override
  Future<int> getPendingOperationsCount() async {
    return await _isar.syncOperationDocuments
        .where()
        .isCompletedEqualTo(false)
        .count();
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
