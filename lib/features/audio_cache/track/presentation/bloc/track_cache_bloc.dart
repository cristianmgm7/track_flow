import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../shared/domain/entities/cached_audio.dart';
import '../../../shared/domain/entities/download_progress.dart';
import '../../../shared/domain/entities/track_cache_info.dart';
import '../../../shared/domain/failures/cache_failure.dart';
import '../../domain/usecases/cache_track_usecase.dart';
import '../../domain/usecases/get_track_cache_status_usecase.dart';
import '../../domain/usecases/remove_track_cache_usecase.dart';
import 'track_cache_event.dart';
import 'track_cache_state.dart';

@injectable
class TrackCacheBloc extends Bloc<TrackCacheEvent, TrackCacheState> {
  final CacheTrackUseCase _cacheTrackUseCase;
  final GetTrackCacheStatusUseCase _getTrackCacheStatusUseCase;
  final RemoveTrackCacheUseCase _removeTrackCacheUseCase;

  StreamSubscription<TrackCacheInfo>? _trackInfoSubscription;

  TrackCacheBloc(
    this._cacheTrackUseCase,
    this._getTrackCacheStatusUseCase,
    this._removeTrackCacheUseCase,
  ) : super(const TrackCacheInitial()) {
    on<CacheTrackRequested>(_onCacheTrackRequested);
    on<CacheTrackWithReferenceRequested>(_onCacheTrackWithReferenceRequested);
    on<RemoveTrackCacheRequested>(_onRemoveTrackCacheRequested);
    on<GetTrackCacheStatusRequested>(_onGetTrackCacheStatusRequested);
    on<GetCachedTrackPathRequested>(_onGetCachedTrackPathRequested);
    on<WatchTrackCacheInfoRequested>(_onWatchTrackCacheInfoRequested);
    on<StopWatchingTrackCacheInfo>(_onStopWatchingTrackCacheInfo);
  }

  /// Helper method to handle operation results consistently
  void _handleOperationResult<T>(
    Either<CacheFailure, T> result,
    String trackId,
    Emitter<TrackCacheState> emit, {
    required void Function(T) onSuccess,
    String? successMessage,
  }) {
    result.fold(
      (failure) => emit(
        TrackCacheOperationFailure(trackId: trackId, error: failure.message),
      ),
      (data) {
        onSuccess(data);
        if (successMessage != null) {
          emit(
            TrackCacheOperationSuccess(
              trackId: trackId,
              message: successMessage,
            ),
          );
        }
      },
    );
  }

  Future<void> _onCacheTrackRequested(
    CacheTrackRequested event,
    Emitter<TrackCacheState> emit,
  ) async {
    emit(const TrackCacheLoading());

    try {
      final result = await _cacheTrackUseCase(
        trackId: event.trackId,
        audioUrl: event.audioUrl,
        policy: event.policy,
      );

      _handleOperationResult(
        result,
        event.trackId,
        emit,
        onSuccess: (_) {},
        successMessage: 'Track cached successfully',
      );
    } catch (e) {
      emit(
        TrackCacheOperationFailure(
          trackId: event.trackId,
          error: 'Unexpected error: $e',
        ),
      );
    }
  }

  Future<void> _onCacheTrackWithReferenceRequested(
    CacheTrackWithReferenceRequested event,
    Emitter<TrackCacheState> emit,
  ) async {
    emit(const TrackCacheLoading());

    try {
      final result = await _cacheTrackUseCase.cacheWithReference(
        trackId: event.trackId,
        audioUrl: event.audioUrl,
        referenceId: event.referenceId,
        policy: event.policy,
      );

      _handleOperationResult(
        result,
        event.trackId,
        emit,
        onSuccess: (_) {},
        successMessage: 'Track cached with reference successfully',
      );
    } catch (e) {
      emit(
        TrackCacheOperationFailure(
          trackId: event.trackId,
          error: 'Unexpected error: $e',
        ),
      );
    }
  }

  Future<void> _onRemoveTrackCacheRequested(
    RemoveTrackCacheRequested event,
    Emitter<TrackCacheState> emit,
  ) async {
    emit(const TrackCacheLoading());
    try {
      final result = await _removeTrackCacheUseCase(
        trackId: event.trackId,
        referenceId: event.referenceId,
      );

      _handleOperationResult(
        result,
        event.trackId,
        emit,
        onSuccess: (_) {
          add(GetTrackCacheStatusRequested(event.trackId));
        },
        successMessage: 'Track removed from cache successfully',
      );
    } catch (e) {
      emit(
        TrackCacheOperationFailure(
          trackId: event.trackId,
          error: 'Unexpected error: $e',
        ),
      );
    }
  }

  Future<void> _onGetTrackCacheStatusRequested(
    GetTrackCacheStatusRequested event,
    Emitter<TrackCacheState> emit,
  ) async {
    emit(const TrackCacheLoading());

    try {
      final result = await _getTrackCacheStatusUseCase(trackId: event.trackId);

      _handleOperationResult(
        result,
        event.trackId,
        emit,
        onSuccess: (status) {
          emit(TrackCacheStatusLoaded(trackId: event.trackId, status: status));
        },
      );
    } catch (e) {
      emit(
        TrackCacheOperationFailure(
          trackId: event.trackId,
          error: 'Unexpected error: $e',
        ),
      );
    }
  }

  Future<void> _onGetCachedTrackPathRequested(
    GetCachedTrackPathRequested event,
    Emitter<TrackCacheState> emit,
  ) async {
    emit(const TrackCacheLoading());

    try {
      final result = await _getTrackCacheStatusUseCase.getCachedAudioPath(
        trackId: event.trackId,
      );

      _handleOperationResult(
        result,
        event.trackId,
        emit,
        onSuccess: (filePath) {
          emit(
            TrackCachePathLoaded(trackId: event.trackId, filePath: filePath),
          );
        },
      );
    } catch (e) {
      emit(
        TrackCacheOperationFailure(
          trackId: event.trackId,
          error: 'Unexpected error: $e',
        ),
      );
    }
  }

  Future<void> _onWatchTrackCacheInfoRequested(
    WatchTrackCacheInfoRequested event,
    Emitter<TrackCacheState> emit,
  ) async {
    await _trackInfoSubscription?.cancel();

    try {
      _trackInfoSubscription = _getTrackCacheStatusUseCase
          .watchTrackCacheInfo(trackId: event.trackId)
          .listen(
            (trackInfo) {
              emit(
                TrackCacheInfoWatching(
                  trackId: trackInfo.trackId,
                  status: trackInfo.status,
                  progress: trackInfo.progress,
                ),
              );
            },
            onError: (error) {
              emit(
                TrackCacheOperationFailure(
                  trackId: event.trackId,
                  error: 'Track info watch error: $error',
                ),
              );
            },
          );

      // Emit initial watching state
      emit(
        TrackCacheInfoWatching(
          trackId: event.trackId,
          status: CacheStatus.notCached,
          progress: DownloadProgress.notStarted(event.trackId),
        ),
      );
    } catch (e) {
      emit(
        TrackCacheOperationFailure(
          trackId: event.trackId,
          error: 'Failed to start watching: $e',
        ),
      );
    }
  }

  Future<void> _onStopWatchingTrackCacheInfo(
    StopWatchingTrackCacheInfo event,
    Emitter<TrackCacheState> emit,
  ) async {
    await _trackInfoSubscription?.cancel();
    _trackInfoSubscription = null;
    emit(const TrackCacheInitial());
  }

  @override
  Future<void> close() {
    _trackInfoSubscription?.cancel();
    return super.close();
  }
}
