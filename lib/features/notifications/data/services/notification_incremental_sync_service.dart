import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart';
import 'package:trackflow/core/notifications/domain/entities/notification.dart';
import 'package:trackflow/core/sync/domain/value_objects/Incremental_sync_result.dart';

@LazySingleton()
class NotificationIncrementalSyncService
    implements IncrementalSyncService<Notification> {
  @override
  Future<Either<Failure, List<Notification>>> getModifiedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, DateTime>> getServerTimestamp() async {
    return Right(DateTime.now().toUtc());
  }

  @override
  Future<Either<Failure, IncrementalSyncResult<Notification>>>
  performIncrementalSync(DateTime lastSyncTime, String userId) async {
    return Right(
      IncrementalSyncResult(
        modifiedItems: [],
        deletedItemIds: [],
        serverTimestamp: DateTime.now().toUtc(),
        totalProcessed: 0,
      ),
    );
  }

  @override
  Future<Either<Failure, IncrementalSyncResult<Notification>>> performFullSync(
    String userId,
  ) async {
    return performIncrementalSync(
      DateTime.fromMillisecondsSinceEpoch(0),
      userId,
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSyncStatistics(
    String userId,
  ) async {
    return Right({
      'userId': userId,
      'totalNotifications': 0,
      'syncStrategy': 'placeholder',
      'lastSync': DateTime.now().toIso8601String(),
    });
  }
}
