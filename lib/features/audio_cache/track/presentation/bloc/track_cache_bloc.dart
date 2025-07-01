import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/cache_track_usecase.dart';
import '../../domain/usecases/get_track_cache_status_usecase.dart'
    as status_usecase;
import '../../domain/usecases/remove_track_cache_usecase.dart';
import 'track_cache_event.dart';
import 'track_cache_state.dart';

@injectable
class TrackCacheBloc extends Bloc<TrackCacheEvent, TrackCacheState> {
  TrackCacheBloc({
    required CacheTrackUseCase cacheTrackUseCase,
    required status_usecase.GetTrackCacheStatusUseCase
    getTrackCacheStatusUseCase,
    required RemoveTrackCacheUseCase removeTrackCacheUseCase,
  }) : _cacheTrackUseCase = cacheTrackUseCase,
       _getTrackCacheStatusUseCase = getTrackCacheStatusUseCase,
       _removeTrackCacheUseCase = removeTrackCacheUseCase,
       super(const TrackCacheInitial()) {
    on<CacheTrackRequested>(_onCacheTrackRequested);
    on<RemoveTrackCacheRequested>(_onRemoveTrackCacheRequested);
    on<GetTrackCacheStatusRequested>(_onGetTrackCacheStatusRequested);
  }

  final CacheTrackUseCase _cacheTrackUseCase;
  final status_usecase.GetTrackCacheStatusUseCase _getTrackCacheStatusUseCase;
  final RemoveTrackCacheUseCase _removeTrackCacheUseCase;

  Future<void> _onCacheTrackRequested(
    CacheTrackRequested event,
    Emitter<TrackCacheState> emit,
  ) async {
    emit(const TrackCacheLoading());

    final result = await _cacheTrackUseCase(
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

  Future<void> _onGetTrackCacheStatusRequested(
    GetTrackCacheStatusRequested event,
    Emitter<TrackCacheState> emit,
  ) async {
    emit(const TrackCacheLoading());

    final result = await _getTrackCacheStatusUseCase(event.trackId);

    emit(
      result.fold(
        (failure) => TrackCacheOperationFailure(
          trackId: event.trackId,
          error: failure.message,
        ),
        (status) =>
            TrackCacheStatusLoaded(trackId: event.trackId, status: status),
      ),
    );
  }
}
