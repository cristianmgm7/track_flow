import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';

@LazySingleton()
class UserProfileCollaboratorIncrementalSyncService
    implements IncrementalSyncService<UserProfileDTO> {
  @override
  Future<Either<Failure, List<UserProfileDTO>>> getModifiedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, bool>> hasModifiedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, DateTime>> getServerTimestamp() async {
    return Right(DateTime.now().toUtc());
  }

  @override
  Future<Either<Failure, List<EntityMetadata>>> getMetadataSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<String>>> getDeletedSince(
    DateTime lastSyncTime,
    String userId,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, IncrementalSyncResult<UserProfileDTO>>>
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
  Future<Either<Failure, IncrementalSyncResult<UserProfileDTO>>>
  performFullSync(String userId) async {
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
      'totalCollaborators': 0,
      'syncStrategy': 'placeholder',
      'lastSync': DateTime.now().toIso8601String(),
    });
  }
}
