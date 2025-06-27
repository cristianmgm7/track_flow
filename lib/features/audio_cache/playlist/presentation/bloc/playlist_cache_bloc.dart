import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/cache_playlist_usecase.dart';
import '../../domain/usecases/get_playlist_cache_status_usecase.dart';
import '../../domain/usecases/remove_playlist_cache_usecase.dart';
import 'playlist_cache_event.dart';
import 'playlist_cache_state.dart';

@injectable
class PlaylistCacheBloc extends Bloc<PlaylistCacheEvent, PlaylistCacheState> {
  final CachePlaylistUseCase _cachePlaylistUseCase;
  final GetPlaylistCacheStatusUseCase _getPlaylistCacheStatusUseCase;
  final RemovePlaylistCacheUseCase _removePlaylistCacheUseCase;

  PlaylistCacheBloc(
    this._cachePlaylistUseCase,
    this._getPlaylistCacheStatusUseCase,
    this._removePlaylistCacheUseCase,
  ) : super(const PlaylistCacheInitial()) {
    on<CachePlaylistRequested>(_onCachePlaylistRequested);
    on<CacheSelectedTracksRequested>(_onCacheSelectedTracksRequested);
    on<AddTrackToPlaylistCacheRequested>(_onAddTrackToPlaylistCacheRequested);
    on<RemovePlaylistCacheRequested>(_onRemovePlaylistCacheRequested);
    on<RemoveSelectedTracksRequested>(_onRemoveSelectedTracksRequested);
    on<RemoveTrackFromPlaylistRequested>(_onRemoveTrackFromPlaylistRequested);
    on<GetPlaylistCacheStatusRequested>(_onGetPlaylistCacheStatusRequested);
    on<GetPlaylistCacheStatsRequested>(_onGetPlaylistCacheStatsRequested);
    on<CheckPlaylistFullyCachedRequested>(_onCheckPlaylistFullyCachedRequested);
    on<GetCachedTrackIdsRequested>(_onGetCachedTrackIdsRequested);
    on<GetUncachedTrackIdsRequested>(_onGetUncachedTrackIdsRequested);
  }

  Future<void> _onCachePlaylistRequested(
    CachePlaylistRequested event,
    Emitter<PlaylistCacheState> emit,
  ) async {
    emit(const PlaylistCacheLoading());

    try {
      final result = await _cachePlaylistUseCase(
        playlistId: event.playlistId,
        trackUrlPairs: event.trackUrlPairs,
        policy: event.policy,
      );

      result.fold(
        (failure) => emit(PlaylistCacheOperationFailure(
          playlistId: event.playlistId,
          error: failure.message,
        )),
        (_) => emit(PlaylistCacheOperationSuccess(
          playlistId: event.playlistId,
          message: 'Playlist cached successfully',
          affectedTracksCount: event.trackUrlPairs.length,
        )),
      );
    } catch (e) {
      emit(PlaylistCacheOperationFailure(
        playlistId: event.playlistId,
        error: 'Unexpected error: $e',
      ));
    }
  }

  Future<void> _onCacheSelectedTracksRequested(
    CacheSelectedTracksRequested event,
    Emitter<PlaylistCacheState> emit,
  ) async {
    emit(const PlaylistCacheLoading());

    try {
      final result = await _cachePlaylistUseCase.cacheSelectedTracks(
        playlistId: event.playlistId,
        selectedTrackUrlPairs: event.selectedTrackUrlPairs,
        policy: event.policy,
      );

      result.fold(
        (failure) => emit(PlaylistCacheOperationFailure(
          playlistId: event.playlistId,
          error: failure.message,
        )),
        (_) => emit(PlaylistCacheOperationSuccess(
          playlistId: event.playlistId,
          message: 'Selected tracks cached successfully',
          affectedTracksCount: event.selectedTrackUrlPairs.length,
        )),
      );
    } catch (e) {
      emit(PlaylistCacheOperationFailure(
        playlistId: event.playlistId,
        error: 'Unexpected error: $e',
      ));
    }
  }

  Future<void> _onAddTrackToPlaylistCacheRequested(
    AddTrackToPlaylistCacheRequested event,
    Emitter<PlaylistCacheState> emit,
  ) async {
    emit(const PlaylistCacheLoading());

    try {
      final result = await _cachePlaylistUseCase.addTrackToPlaylist(
        playlistId: event.playlistId,
        trackId: event.trackId,
        audioUrl: event.audioUrl,
        policy: event.policy,
      );

      result.fold(
        (failure) => emit(PlaylistCacheOperationFailure(
          playlistId: event.playlistId,
          error: failure.message,
        )),
        (_) => emit(PlaylistCacheOperationSuccess(
          playlistId: event.playlistId,
          message: 'Track added to playlist cache successfully',
          affectedTracksCount: 1,
        )),
      );
    } catch (e) {
      emit(PlaylistCacheOperationFailure(
        playlistId: event.playlistId,
        error: 'Unexpected error: $e',
      ));
    }
  }

  Future<void> _onRemovePlaylistCacheRequested(
    RemovePlaylistCacheRequested event,
    Emitter<PlaylistCacheState> emit,
  ) async {
    emit(const PlaylistCacheLoading());

    try {
      final result = await _removePlaylistCacheUseCase(
        playlistId: event.playlistId,
        trackIds: event.trackIds,
      );

      result.fold(
        (failure) => emit(PlaylistCacheOperationFailure(
          playlistId: event.playlistId,
          error: failure.message,
        )),
        (_) => emit(PlaylistCacheOperationSuccess(
          playlistId: event.playlistId,
          message: 'Playlist cache removed successfully',
          affectedTracksCount: event.trackIds.length,
        )),
      );
    } catch (e) {
      emit(PlaylistCacheOperationFailure(
        playlistId: event.playlistId,
        error: 'Unexpected error: $e',
      ));
    }
  }

  Future<void> _onRemoveSelectedTracksRequested(
    RemoveSelectedTracksRequested event,
    Emitter<PlaylistCacheState> emit,
  ) async {
    emit(const PlaylistCacheLoading());

    try {
      final result = await _removePlaylistCacheUseCase.removeSelectedTracks(
        playlistId: event.playlistId,
        selectedTrackIds: event.selectedTrackIds,
      );

      result.fold(
        (failure) => emit(PlaylistCacheOperationFailure(
          playlistId: event.playlistId,
          error: failure.message,
        )),
        (_) => emit(PlaylistCacheOperationSuccess(
          playlistId: event.playlistId,
          message: 'Selected tracks removed successfully',
          affectedTracksCount: event.selectedTrackIds.length,
        )),
      );
    } catch (e) {
      emit(PlaylistCacheOperationFailure(
        playlistId: event.playlistId,
        error: 'Unexpected error: $e',
      ));
    }
  }

  Future<void> _onRemoveTrackFromPlaylistRequested(
    RemoveTrackFromPlaylistRequested event,
    Emitter<PlaylistCacheState> emit,
  ) async {
    emit(const PlaylistCacheLoading());

    try {
      final result = await _removePlaylistCacheUseCase.removeTrackFromPlaylist(
        playlistId: event.playlistId,
        trackId: event.trackId,
      );

      result.fold(
        (failure) => emit(PlaylistCacheOperationFailure(
          playlistId: event.playlistId,
          error: failure.message,
        )),
        (_) => emit(PlaylistCacheOperationSuccess(
          playlistId: event.playlistId,
          message: 'Track removed from playlist cache successfully',
          affectedTracksCount: 1,
        )),
      );
    } catch (e) {
      emit(PlaylistCacheOperationFailure(
        playlistId: event.playlistId,
        error: 'Unexpected error: $e',
      ));
    }
  }

  Future<void> _onGetPlaylistCacheStatusRequested(
    GetPlaylistCacheStatusRequested event,
    Emitter<PlaylistCacheState> emit,
  ) async {
    emit(const PlaylistCacheLoading());

    try {
      final result = await _getPlaylistCacheStatusUseCase(
        trackIds: event.trackIds,
      );

      result.fold(
        (failure) => emit(PlaylistCacheOperationFailure(
          playlistId: 'unknown',
          error: failure.message,
        )),
        (trackStatuses) => emit(PlaylistCacheStatusLoaded(
          trackStatuses: trackStatuses,
        )),
      );
    } catch (e) {
      emit(PlaylistCacheOperationFailure(
        playlistId: 'unknown',
        error: 'Unexpected error: $e',
      ));
    }
  }

  Future<void> _onGetPlaylistCacheStatsRequested(
    GetPlaylistCacheStatsRequested event,
    Emitter<PlaylistCacheState> emit,
  ) async {
    emit(const PlaylistCacheLoading());

    try {
      final result = await _getPlaylistCacheStatusUseCase.getPlaylistCacheStats(
        playlistId: event.playlistId,
        trackIds: event.trackIds,
      );

      result.fold(
        (failure) => emit(PlaylistCacheOperationFailure(
          playlistId: event.playlistId,
          error: failure.message,
        )),
        (stats) => emit(PlaylistCacheStatsLoaded(
          stats: stats,
        )),
      );
    } catch (e) {
      emit(PlaylistCacheOperationFailure(
        playlistId: event.playlistId,
        error: 'Unexpected error: $e',
      ));
    }
  }

  Future<void> _onCheckPlaylistFullyCachedRequested(
    CheckPlaylistFullyCachedRequested event,
    Emitter<PlaylistCacheState> emit,
  ) async {
    emit(const PlaylistCacheLoading());

    try {
      final result = await _getPlaylistCacheStatusUseCase.isPlaylistFullyCached(
        trackIds: event.trackIds,
      );

      result.fold(
        (failure) => emit(PlaylistCacheOperationFailure(
          playlistId: 'unknown',
          error: failure.message,
        )),
        (isFullyCached) => emit(PlaylistFullyCachedResult(
          isFullyCached: isFullyCached,
        )),
      );
    } catch (e) {
      emit(PlaylistCacheOperationFailure(
        playlistId: 'unknown',
        error: 'Unexpected error: $e',
      ));
    }
  }

  Future<void> _onGetCachedTrackIdsRequested(
    GetCachedTrackIdsRequested event,
    Emitter<PlaylistCacheState> emit,
  ) async {
    emit(const PlaylistCacheLoading());

    try {
      final result = await _getPlaylistCacheStatusUseCase.getCachedTrackIds(
        trackIds: event.trackIds,
      );

      result.fold(
        (failure) => emit(PlaylistCacheOperationFailure(
          playlistId: 'unknown',
          error: failure.message,
        )),
        (cachedTrackIds) => emit(CachedTrackIdsLoaded(
          cachedTrackIds: cachedTrackIds,
        )),
      );
    } catch (e) {
      emit(PlaylistCacheOperationFailure(
        playlistId: 'unknown',
        error: 'Unexpected error: $e',
      ));
    }
  }

  Future<void> _onGetUncachedTrackIdsRequested(
    GetUncachedTrackIdsRequested event,
    Emitter<PlaylistCacheState> emit,
  ) async {
    emit(const PlaylistCacheLoading());

    try {
      final result = await _getPlaylistCacheStatusUseCase.getUncachedTrackIds(
        trackIds: event.trackIds,
      );

      result.fold(
        (failure) => emit(PlaylistCacheOperationFailure(
          playlistId: 'unknown',
          error: failure.message,
        )),
        (uncachedTrackIds) => emit(UncachedTrackIdsLoaded(
          uncachedTrackIds: uncachedTrackIds,
        )),
      );
    } catch (e) {
      emit(PlaylistCacheOperationFailure(
        playlistId: 'unknown',
        error: 'Unexpected error: $e',
      ));
    }
  }
}