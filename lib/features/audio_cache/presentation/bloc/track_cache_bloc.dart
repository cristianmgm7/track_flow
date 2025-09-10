import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';

import '../../domain/usecases/cache_track_usecase.dart';
import '../../domain/usecases/watch_cache_status.dart' as status_usecase;
import '../../domain/usecases/remove_track_cache_usecase.dart';
import '../../domain/usecases/get_cached_track_path_usecase.dart';
import 'track_cache_event.dart';
import 'track_cache_state.dart';

@injectable
class TrackCacheBloc extends Bloc<TrackCacheEvent, TrackCacheState> {
  TrackCacheBloc({
    required CacheTrackUseCase cacheTrackUseCase,
    required status_usecase.WatchTrackCacheStatusUseCase
    watchTrackCacheStatusUseCase,
    required RemoveTrackCacheUseCase removeTrackCacheUseCase,
    required GetCachedTrackPathUseCase getCachedTrackPathUseCase,
  }) : _cacheTrackUseCase = cacheTrackUseCase,
       _watchTrackCacheStatusUseCase = watchTrackCacheStatusUseCase,
       _removeTrackCacheUseCase = removeTrackCacheUseCase,
       _getCachedTrackPathUseCase = getCachedTrackPathUseCase,
       super(const TrackCacheInitial()) {
    on<CacheTrackRequested>(_onCacheTrackRequested);
    on<RemoveTrackCacheRequested>(_onRemoveTrackCacheRequested);
    on<GetCachedTrackPathRequested>(_onGetCachedTrackPathRequested);
    on<WatchTrackCacheStatusRequested>((event, emit) async {
      await emit.onEach(
        _watchTrackCacheStatusUseCase(
          event.trackId.value,
          versionId: event.versionId?.value,
        ),
        onData: (either) {
          either.fold(
            (failure) => emit(
              TrackCacheOperationFailure(
                trackId: event.trackId.value,
                error: failure.message,
              ),
            ),
            (status) => emit(
              TrackCacheStatusLoaded(
                trackId: event.trackId.value,
                status: status,
              ),
            ),
          );
        },
      );
    });
  }

  final CacheTrackUseCase _cacheTrackUseCase;
  final status_usecase.WatchTrackCacheStatusUseCase
  _watchTrackCacheStatusUseCase;
  final RemoveTrackCacheUseCase _removeTrackCacheUseCase;
  final GetCachedTrackPathUseCase _getCachedTrackPathUseCase;

  Future<void> _onCacheTrackRequested(
    CacheTrackRequested event,
    Emitter<TrackCacheState> emit,
  ) async {
    emit(const TrackCacheLoading());

    final result = await _cacheTrackUseCase.call(
      trackId: event.trackId,
      audioUrl: event.audioUrl,
    );

    emit(
      result.fold(
        (failure) => TrackCacheOperationFailure(
          trackId: event.trackId,
          error: failure.message,
        ),
        (_) => TrackCacheOperationSuccess(
          trackId: event.trackId,
          message: 'Track cached successfully',
        ),
      ),
    );
  }

  Future<void> _onRemoveTrackCacheRequested(
    RemoveTrackCacheRequested event,
    Emitter<TrackCacheState> emit,
  ) async {
    emit(const TrackCacheLoading());

    final result = await _removeTrackCacheUseCase(event.trackId);

    emit(
      result.fold(
        (failure) => TrackCacheOperationFailure(
          trackId: event.trackId,
          error: failure.message,
        ),
        (_) => TrackCacheOperationSuccess(
          trackId: event.trackId,
          message: 'Track cache removed successfully',
        ),
      ),
    );
  }

  Future<void> _onGetCachedTrackPathRequested(
    GetCachedTrackPathRequested event,
    Emitter<TrackCacheState> emit,
  ) async {
    final result = await _getCachedTrackPathUseCase(event.trackId);

    emit(
      result.fold(
        (failure) => TrackCacheOperationFailure(
          trackId: event.trackId,
          error: failure.message,
        ),
        (filePath) =>
            TrackCachePathLoaded(trackId: event.trackId, filePath: filePath),
      ),
    );
  }
}
