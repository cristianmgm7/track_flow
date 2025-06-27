import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../shared/domain/entities/cached_audio.dart';
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

  StreamSubscription<CacheStatus>? _statusSubscription;

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
    on<WatchTrackCacheStatusRequested>(_onWatchTrackCacheStatusRequested);
    on<StopWatchingTrackCacheStatus>(_onStopWatchingTrackCacheStatus);
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

      result.fold(
        (failure) => emit(TrackCacheOperationFailure(
          trackId: event.trackId,
          error: failure.message,
        )),
        (_) => emit(TrackCacheOperationSuccess(
          trackId: event.trackId,
          message: 'Track cached successfully',
        )),
      );
    } catch (e) {
      emit(TrackCacheOperationFailure(
        trackId: event.trackId,
        error: 'Unexpected error: $e',
      ));
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

      result.fold(
        (failure) => emit(TrackCacheOperationFailure(
          trackId: event.trackId,
          error: failure.message,
        )),
        (_) => emit(TrackCacheOperationSuccess(
          trackId: event.trackId,
          message: 'Track cached with reference successfully',
        )),
      );
    } catch (e) {
      emit(TrackCacheOperationFailure(
        trackId: event.trackId,
        error: 'Unexpected error: $e',
      ));
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

      result.fold(
        (failure) => emit(TrackCacheOperationFailure(
          trackId: event.trackId,
          error: failure.message,
        )),
        (_) => emit(TrackCacheOperationSuccess(
          trackId: event.trackId,
          message: 'Track removed from cache successfully',
        )),
      );
    } catch (e) {
      emit(TrackCacheOperationFailure(
        trackId: event.trackId,
        error: 'Unexpected error: $e',
      ));
    }
  }

  Future<void> _onGetTrackCacheStatusRequested(
    GetTrackCacheStatusRequested event,
    Emitter<TrackCacheState> emit,
  ) async {
    emit(const TrackCacheLoading());

    try {
      final result = await _getTrackCacheStatusUseCase(
        trackId: event.trackId,
      );

      result.fold(
        (failure) => emit(TrackCacheOperationFailure(
          trackId: event.trackId,
          error: failure.message,
        )),
        (status) => emit(TrackCacheStatusLoaded(
          trackId: event.trackId,
          status: status,
        )),
      );
    } catch (e) {
      emit(TrackCacheOperationFailure(
        trackId: event.trackId,
        error: 'Unexpected error: $e',
      ));
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

      result.fold(
        (failure) => emit(TrackCacheOperationFailure(
          trackId: event.trackId,
          error: failure.message,
        )),
        (filePath) => emit(TrackCachePathLoaded(
          trackId: event.trackId,
          filePath: filePath,
        )),
      );
    } catch (e) {
      emit(TrackCacheOperationFailure(
        trackId: event.trackId,
        error: 'Unexpected error: $e',
      ));
    }
  }

  Future<void> _onWatchTrackCacheStatusRequested(
    WatchTrackCacheStatusRequested event,
    Emitter<TrackCacheState> emit,
  ) async {
    // Cancel any existing subscription
    await _statusSubscription?.cancel();

    try {
      // Start watching cache status changes
      _statusSubscription = _getTrackCacheStatusUseCase
          .watchCacheStatus(trackId: event.trackId)
          .listen(
        (status) {
          emit(TrackCacheWatching(
            trackId: event.trackId,
            currentStatus: status,
          ));
        },
        onError: (error) {
          emit(TrackCacheOperationFailure(
            trackId: event.trackId,
            error: 'Status watch error: $error',
          ));
        },
      );

      // Emit initial watching state
      emit(TrackCacheWatching(
        trackId: event.trackId,
        currentStatus: CacheStatus.notCached, // Will be updated by stream
      ));
    } catch (e) {
      emit(TrackCacheOperationFailure(
        trackId: event.trackId,
        error: 'Failed to start watching: $e',
      ));
    }
  }

  Future<void> _onStopWatchingTrackCacheStatus(
    StopWatchingTrackCacheStatus event,
    Emitter<TrackCacheState> emit,
  ) async {
    await _statusSubscription?.cancel();
    _statusSubscription = null;
    emit(const TrackCacheInitial());
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    return super.close();
  }
}