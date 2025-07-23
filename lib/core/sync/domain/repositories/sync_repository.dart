import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/entities/sync_state.dart';

/// Repository interface for data synchronization
///
/// This interface is responsible ONLY for sync operations.
/// It does NOT handle any user session functionality.
abstract class SyncRepository {
  /// Get the current sync state
  Future<Either<Failure, SyncState>> getCurrentSyncState();

  /// Watch for sync state changes
  Stream<SyncState> watchSyncState();

  /// Trigger background synchronization
  Future<Either<Failure, Unit>> triggerBackgroundSync();

  /// Force a full synchronization
  Future<Either<Failure, Unit>> forceSync();

  /// Initialize sync if needed
  Future<Either<Failure, Unit>> initializeIfNeeded();

  /// Reset sync state (useful for testing or logout)
  Future<Either<Failure, Unit>> resetSync();

  /// Check if sync is currently in progress
  Future<Either<Failure, bool>> isSyncing();

  /// Check if sync is complete
  Future<Either<Failure, bool>> isSyncComplete();
}
