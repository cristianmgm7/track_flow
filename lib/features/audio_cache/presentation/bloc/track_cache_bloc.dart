import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';

import '../../domain/usecases/cache_track_usecase.dart';
import '../../domain/usecases/watch_cache_status.dart' as status_usecase;
import '../../domain/usecases/remove_track_cache_usecase.dart';
import '../../domain/usecases/get_cached_track_path_usecase.dart';
import '../../../audio_track/domain/usecases/download_track_usecase.dart';
import 'track_cache_event.dart';
import 'track_cache_state.dart';
import '../../../projects/domain/exceptions/project_exceptions.dart';

@injectable
class TrackCacheBloc extends Bloc<TrackCacheEvent, TrackCacheState> {
  TrackCacheBloc({
    required CacheTrackUseCase cacheTrackUseCase,
    required status_usecase.WatchTrackCacheStatusUseCase
    watchTrackCacheStatusUseCase,
    required RemoveTrackCacheUseCase removeTrackCacheUseCase,
    required GetCachedTrackPathUseCase getCachedTrackPathUseCase,
    required DownloadTrackUseCase downloadTrackUseCase,
  }) : _cacheTrackUseCase = cacheTrackUseCase,
       _watchTrackCacheStatusUseCase = watchTrackCacheStatusUseCase,
       _removeTrackCacheUseCase = removeTrackCacheUseCase,
       _getCachedTrackPathUseCase = getCachedTrackPathUseCase,
       _downloadTrackUseCase = downloadTrackUseCase,
       super(const TrackCacheInitial()) {
    on<CacheTrackRequested>(_onCacheTrackRequested);
    on<RemoveTrackCacheRequested>(_onRemoveTrackCacheRequested);
    on<GetCachedTrackPathRequested>(_onGetCachedTrackPathRequested);
    on<DownloadTrackRequested>(_onDownloadTrackRequested);
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
  final DownloadTrackUseCase _downloadTrackUseCase;

  Future<void> _onCacheTrackRequested(
    CacheTrackRequested event,
    Emitter<TrackCacheState> emit,
  ) async {
    emit(const TrackCacheLoading());

    final result = await _cacheTrackUseCase.call(
      trackId: event.trackId,
      audioUrl: event.audioUrl,
      versionId: event.versionId,
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

    final result = await _removeTrackCacheUseCase(
      trackId: event.trackId,
      versionId: event.versionId,
    );

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
    final result = await _getCachedTrackPathUseCase(
      trackId: event.trackId,
      versionId: event.versionId,
    );

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

  Future<void> _onDownloadTrackRequested(
    DownloadTrackRequested event,
    Emitter<TrackCacheState> emit,
  ) async {
    emit(TrackCacheOperationInProgress(trackId: event.trackId));

    final result = await _downloadTrackUseCase(
      trackId: event.trackId,
      versionId: event.versionId,
    );

    emit(
      result.fold(
        (failure) {
          final isPermissionError = failure is ProjectPermissionException;
          return TrackDownloadFailure(
            trackId: event.trackId,
            error: failure.message,
            isPermissionError: isPermissionError,
          );
        },
        (filePath) => TrackDownloadReady(
          trackId: event.trackId,
          filePath: filePath,
        ),
      ),
    );
  }
}
