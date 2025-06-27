import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/audio_cache_event.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/audio_cache_state.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/download_track_usecase.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/download_track_managed_usecase.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/cancel_download_usecase.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/remove_from_cache_usecase.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/check_cache_status_usecase.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/get_download_progress_usecase.dart';
import 'package:trackflow/features/audio_cache/domain/services/download_management_service.dart';
import 'package:trackflow/features/audio_player/domain/models/audio_source_enum.dart';

@injectable
class AudioCacheBloc extends Bloc<AudioCacheEvent, AudioCacheState> {
  // Use Cases - Clean Architecture
  final DownloadTrackUseCase _downloadTrackUseCase;
  final DownloadTrackManagedUseCase _downloadTrackManagedUseCase;
  final CancelDownloadUseCase _cancelDownloadUseCase;
  final RemoveFromCacheUseCase _removeFromCacheUseCase;
  final CheckCacheStatusUseCase _checkCacheStatusUseCase;
  final GetDownloadProgressUseCase _getDownloadProgressUseCase;

  StreamSubscription? _progressSubscription;

  AudioCacheBloc(
    this._downloadTrackUseCase,
    this._downloadTrackManagedUseCase,
    this._cancelDownloadUseCase,
    this._removeFromCacheUseCase,
    this._checkCacheStatusUseCase,
    this._getDownloadProgressUseCase,
  ) : super(AudioCacheInitial()) {
    on<CheckCacheStatusRequested>(_onCheckCacheStatusRequested);
    on<DownloadTrackRequested>(_onDownloadTrackRequested);
    on<CancelDownloadRequested>(_onCancelDownloadRequested);
    on<RemoveFromCacheRequested>(_onRemoveFromCacheRequested);
    on<RetryDownloadRequested>(_onRetryDownloadRequested);
    on<LoadCacheRequested>(_onLoadCacheRequested); // Legacy support
  }

  Future<void> _onCheckCacheStatusRequested(
    CheckCacheStatusRequested event,
    Emitter<AudioCacheState> emit,
  ) async {
    emit(AudioCacheLoading());
    try {
      final cacheStatus = await _checkCacheStatusUseCase(event.trackUrl);
      if (cacheStatus == CacheStatus.cached) {
        emit(AudioCacheDownloaded('cached'));
      } else {
        emit(AudioCacheInitial());
      }
    } catch (e) {
      emit(AudioCacheInitial());
    }
  }

  Future<void> _onDownloadTrackRequested(
    DownloadTrackRequested event,
    Emitter<AudioCacheState> emit,
  ) async {
    emit(AudioCacheLoading());
    try {
      final result = await _downloadTrackManagedUseCase(
        trackId: event.trackId,
        trackUrl: event.trackUrl,
        trackName: event.trackName,
        priority: DownloadPriority.normal,
      );
      
      result.fold(
        (failure) => emit(AudioCacheFailure(failure.message)),
        (_) {
          // Cancel any existing subscription
          _progressSubscription?.cancel();
          
          // Listen to download progress using use case
          _progressSubscription = _getDownloadProgressUseCase(event.trackId)
              .listen((progressInfo) {
            if (progressInfo.status == DownloadStatus.downloading) {
              emit(AudioCacheProgress(progressInfo.progress));
            } else if (progressInfo.status == DownloadStatus.completed) {
              emit(AudioCacheDownloaded(event.trackName));
            } else if (progressInfo.status == DownloadStatus.failed) {
              emit(AudioCacheFailure(progressInfo.errorMessage ?? 'Download failed'));
            }
          });
        },
      );
    } catch (e) {
      emit(AudioCacheFailure(e.toString()));
    }
  }

  Future<void> _onCancelDownloadRequested(
    CancelDownloadRequested event,
    Emitter<AudioCacheState> emit,
  ) async {
    try {
      _progressSubscription?.cancel();
      
      final result = await _cancelDownloadUseCase(event.trackId);
      result.fold(
        (failure) => emit(AudioCacheFailure(failure.message)),
        (_) => emit(AudioCacheInitial()),
      );
    } catch (e) {
      emit(AudioCacheFailure(e.toString()));
    }
  }

  Future<void> _onRemoveFromCacheRequested(
    RemoveFromCacheRequested event,
    Emitter<AudioCacheState> emit,
  ) async {
    try {
      final result = await _removeFromCacheUseCase(event.trackUrl);
      result.fold(
        (failure) => emit(AudioCacheFailure(failure.message)),
        (_) => emit(AudioCacheInitial()),
      );
    } catch (e) {
      emit(AudioCacheFailure(e.toString()));
    }
  }

  Future<void> _onRetryDownloadRequested(
    RetryDownloadRequested event,
    Emitter<AudioCacheState> emit,
  ) async {
    // Retry is essentially the same as download
    add(DownloadTrackRequested(
      trackId: event.trackId,
      trackUrl: event.trackUrl,
      trackName: event.trackName,
    ));
  }

  // Legacy support for existing AudioCacheIcon usage
  Future<void> _onLoadCacheRequested(
    LoadCacheRequested event,
    Emitter<AudioCacheState> emit,
  ) async {
    emit(AudioCacheLoading());
    try {
      final result = await _downloadTrackUseCase(
        trackUrl: event.remoteUrl,
        trackName: 'Track',
        onProgress: (progress) {
          emit(AudioCacheProgress(progress));
        },
      );
      
      result.fold(
        (failure) => emit(AudioCacheFailure(failure.message)),
        (localPath) => emit(AudioCacheDownloaded(localPath)),
      );
    } catch (e) {
      emit(AudioCacheFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    return super.close();
  }
}