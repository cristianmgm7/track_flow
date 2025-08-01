import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/core/utils/app_logger.dart';

import '../../domain/entities/playlist.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../datasources/playlist_local_data_source.dart';
import '../models/playlist_dto.dart';

@LazySingleton(as: PlaylistRepository)
class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistLocalDataSource _localDataSource;
  final BackgroundSyncCoordinator _backgroundSyncCoordinator;
  final PendingOperationsManager _pendingOperationsManager;

  PlaylistRepositoryImpl({
    required PlaylistLocalDataSource localDataSource,
    required BackgroundSyncCoordinator backgroundSyncCoordinator,
    required PendingOperationsManager pendingOperationsManager,
  }) : _localDataSource = localDataSource,
       _backgroundSyncCoordinator = backgroundSyncCoordinator,
       _pendingOperationsManager = pendingOperationsManager;

  @override
  Future<Either<Failure, Unit>> addPlaylist(Playlist playlist) async {
    try {
      final dto = PlaylistDto.fromDomain(playlist);

      // 1. ALWAYS save locally first
      final cacheResult = await _localDataSource.addPlaylist(dto);
      if (cacheResult.isLeft()) {
        final failure = cacheResult.fold((l) => l, (r) => null);
        return Left(failure!);
      }

      // 2. Try to queue for background sync
      final queueResult = await _pendingOperationsManager.addCreateOperation(
        entityType: 'playlist',
        entityId: playlist.id.value,
        data: {
          'name': playlist.name,
          'trackIds': playlist.trackIds,
          'playlistSource': playlist.playlistSource.name,
        },
        priority: SyncPriority.medium,
      );

      // 3. Handle queue failure
      if (queueResult.isLeft()) {
        final failure = queueResult.fold((l) => l, (r) => null);
        return Left(
          DatabaseFailure(
            'Failed to queue sync operation: ${failure?.message}',
          ),
        );
      }

      // 4. Trigger background sync
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'playlists_create',
        ),
      );

      // 5. Return success only after successful queue
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Critical storage error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Playlist>>> getAllPlaylists() async {
    try {
      // 1. ALWAYS try local cache first
      final either = await _localDataSource.getAllPlaylists();

      // 2. Trigger background sync for fresh data (non-blocking)
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'playlists_refresh',
        ),
      );

      // 3. Return local data immediately
      return either.fold(
        (failure) => Left(failure),
        (dtos) => Right(dtos.map((dto) => dto.toDomain()).toList()),
      );
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to access local cache: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Playlist?>> getPlaylistById(PlaylistId id) async {
    try {
      // 1. ALWAYS try local cache first
      final either = await _localDataSource.getPlaylistById(id.value);

      // 2. Trigger background sync for fresh data (non-blocking)
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'playlist_${id.value}',
        ),
      );

      // 3. Return local data immediately
      return either.fold(
        (failure) => Left(failure),
        (dto) => Right(dto?.toDomain()),
      );
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to access local cache: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePlaylist(Playlist playlist) async {
    try {
      final dto = PlaylistDto.fromDomain(playlist);

      // 1. ALWAYS update locally first
      final cacheResult = await _localDataSource.updatePlaylist(dto);
      if (cacheResult.isLeft()) {
        final failure = cacheResult.fold((l) => l, (r) => null);
        return Left(failure!);
      }

      // 2. Try to queue for background sync
      final queueResult = await _pendingOperationsManager.addUpdateOperation(
        entityType: 'playlist',
        entityId: playlist.id.value,
        data: {
          'name': playlist.name,
          'trackIds': playlist.trackIds,
          'playlistSource': playlist.playlistSource.name,
        },
        priority: SyncPriority.medium,
      );

      // 3. Handle queue failure
      if (queueResult.isLeft()) {
        final failure = queueResult.fold((l) => l, (r) => null);
        return Left(
          DatabaseFailure(
            'Failed to queue sync operation: ${failure?.message}',
          ),
        );
      }

      // 4. Trigger background sync
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'playlists_update',
        ),
      );

      // 5. Return success only after successful queue
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Critical storage error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePlaylist(PlaylistId id) async {
    try {
      // 1. ALWAYS soft delete locally first
      final cacheResult = await _localDataSource.deletePlaylist(id.value);
      if (cacheResult.isLeft()) {
        final failure = cacheResult.fold((l) => l, (r) => null);
        return Left(failure!);
      }

      // 2. Try to queue for background sync
      final queueResult = await _pendingOperationsManager.addDeleteOperation(
        entityType: 'playlist',
        entityId: id.value,
        priority: SyncPriority.medium,
      );

      // 3. Handle queue failure
      if (queueResult.isLeft()) {
        final failure = queueResult.fold((l) => l, (r) => null);
        return Left(
          DatabaseFailure(
            'Failed to queue sync operation: ${failure?.message}',
          ),
        );
      }

      // 4. Trigger background sync
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: 'playlists_delete',
        ),
      );

      // 5. Return success only after successful queue
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Critical storage error: ${e.toString()}'));
    }
  }

  // Helper method for fire-and-forget background operations
  void unawaited(Future future) {
    future.catchError((error) {
      // Log error but don't propagate - this is background operation
      AppLogger.warning('Background sync trigger failed: $error', tag: 'PlaylistRepositoryImpl');
    });
  }
}
