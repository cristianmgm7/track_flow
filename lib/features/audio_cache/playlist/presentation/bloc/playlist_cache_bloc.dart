import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/cache_playlist_usecase.dart';
import '../../domain/usecases/get_playlist_cache_status_usecase.dart';
import '../../domain/usecases/remove_playlist_cache_usecase.dart';
import '../../domain/entities/playlist_cache_stats.dart';
import 'playlist_cache_event.dart';
import 'playlist_cache_state.dart';

@injectable
class PlaylistCacheBloc extends Bloc<PlaylistCacheEvent, PlaylistCacheState> {
  PlaylistCacheBloc({
    required CachePlaylistUseCase cachePlaylistUseCase,
    required GetPlaylistCacheStatusUseCase getPlaylistCacheStatusUseCase,
    required RemovePlaylistCacheUseCase removePlaylistCacheUseCase,
  }) : _cachePlaylistUseCase = cachePlaylistUseCase,
       _getPlaylistCacheStatusUseCase = getPlaylistCacheStatusUseCase,
       _removePlaylistCacheUseCase = removePlaylistCacheUseCase,
       super(const PlaylistCacheInitial()) {
    on<CachePlaylistRequested>(_onCachePlaylistRequested);
    on<GetPlaylistCacheStatusRequested>(_onGetPlaylistCacheStatusRequested);
    on<GetPlaylistCacheStatsRequested>(_onGetPlaylistCacheStatsRequested);
    on<GetDetailedProgressRequested>(_onGetDetailedProgressRequested);
    on<RemovePlaylistCacheRequested>(_onRemovePlaylistCacheRequested);
  }

  final CachePlaylistUseCase _cachePlaylistUseCase;
  final GetPlaylistCacheStatusUseCase _getPlaylistCacheStatusUseCase;
  final RemovePlaylistCacheUseCase _removePlaylistCacheUseCase;

  Future<void> _onCachePlaylistRequested(
    CachePlaylistRequested event,
    Emitter<PlaylistCacheState> emit,
  ) async {
    emit(const PlaylistCacheLoading());

    final result = await _cachePlaylistUseCase(
      playlistId: event.playlistId,
      trackUrlPairs: event.trackUrlPairs,
    );

    emit(
      result.fold(
        (failure) => PlaylistCacheOperationFailure(
          playlistId: event.playlistId,
          error: failure.message,
        ),
        (_) => PlaylistCacheOperationSuccess(
          playlistId: event.playlistId,
          message: 'Playlist cached successfully',
          affectedTracksCount: event.trackUrlPairs.length,
        ),
      ),
    );
  }

  Future<void> _onGetPlaylistCacheStatusRequested(
    GetPlaylistCacheStatusRequested event,
    Emitter<PlaylistCacheState> emit,
  ) async {
    emit(const PlaylistCacheLoading());

    final result = await _getPlaylistCacheStatusUseCase(event.trackIds);

    emit(
      result.fold(
        (failure) => PlaylistCacheOperationFailure(
          playlistId: 'unknown',
          error: failure.message,
        ),
        (statusMap) => PlaylistCacheStatusLoaded(trackStatuses: statusMap),
      ),
    );
  }

  Future<void> _onGetPlaylistCacheStatsRequested(
    GetPlaylistCacheStatsRequested event,
    Emitter<PlaylistCacheState> emit,
  ) async {
    emit(const PlaylistCacheLoading());

    final result = await _getPlaylistCacheStatusUseCase.getPlaylistCacheStats(
      playlistId: event.playlistId,
      trackIds: event.trackIds,
    );

    emit(
      result.fold(
        (failure) => PlaylistCacheOperationFailure(
          playlistId: event.playlistId,
          error: failure.message,
        ),
        (stats) => PlaylistCacheStatsLoaded(
          stats: stats,
          detailedProgress: {
            'statusDescription': stats.statusDescription,
            'progressDescription': stats.progressDescription,
            'canCache': !stats.isFullyCached,
            'canRemove': stats.cachedTracks > 0,
            'showProgress': stats.hasDownloading,
            'status': stats.status,
          },
        ),
      ),
    );
  }

  Future<void> _onGetDetailedProgressRequested(
    GetDetailedProgressRequested event,
    Emitter<PlaylistCacheState> emit,
  ) async {
    emit(const PlaylistCacheLoading());

    final result = await _getPlaylistCacheStatusUseCase.getDetailedProgress(
      playlistId: event.playlistId,
      trackIds: event.trackIds,
    );

    emit(
      result.fold(
        (failure) => PlaylistCacheOperationFailure(
          playlistId: event.playlistId,
          error: failure.message,
        ),
        (detailedProgress) {
          final stats = detailedProgress['stats'] as PlaylistCacheStats;
          return PlaylistCacheStatsLoaded(
            stats: stats,
            detailedProgress: detailedProgress,
          );
        },
      ),
    );
  }

  Future<void> _onRemovePlaylistCacheRequested(
    RemovePlaylistCacheRequested event,
    Emitter<PlaylistCacheState> emit,
  ) async {
    emit(const PlaylistCacheLoading());

    final result = await _removePlaylistCacheUseCase(event.trackIds);

    emit(
      result.fold(
        (failure) => PlaylistCacheOperationFailure(
          playlistId: event.playlistId,
          error: failure.message,
        ),
        (_) => PlaylistCacheOperationSuccess(
          playlistId: event.playlistId,
          message: 'Playlist cache removed successfully',
          affectedTracksCount: event.trackIds.length,
        ),
      ),
    );
  }
}
