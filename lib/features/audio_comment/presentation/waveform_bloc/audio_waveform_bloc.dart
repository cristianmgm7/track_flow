import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_cached_track_path_usecase.dart';
import 'package:trackflow/features/audio_player/domain/entities/playback_session.dart';
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart';

part 'audio_waveform_event.dart';
part 'audio_waveform_state.dart';

@injectable
class AudioWaveformBloc extends Bloc<AudioWaveformEvent, AudioWaveformState> {
  final AudioPlaybackService _audioPlaybackService;
  final GetCachedTrackPathUseCase _getCachedTrackPathUseCase;

  StreamSubscription? _sessionSubscription;
  StreamSubscription? _cacheSubscription;
  AudioTrackId? _currentTrackId;
  bool _isSeekingFromWaveform = false;
  int? _lastRequestedSamples;

  AudioWaveformBloc({
    required AudioPlaybackService audioPlaybackService,
    required GetCachedTrackPathUseCase getCachedTrackPathUseCase,
  }) : _audioPlaybackService = audioPlaybackService,
       _getCachedTrackPathUseCase = getCachedTrackPathUseCase,
       super(const AudioWaveformState()) {
    on<LoadWaveform>(_onLoadWaveform);
    on<_PlayerSessionUpdated>(_onPlayerSessionUpdated);
    on<_TrackPathLoaded>(_onTrackPathLoaded);
    on<_TrackCacheFailed>(_onTrackCacheFailed);
    on<WaveformSeeked>(_onWaveformSeeked);

    _listenToAudioPlayer();
  }

  void _listenToAudioPlayer() {
    _sessionSubscription = _audioPlaybackService.sessionStream.listen((
      session,
    ) {
      add(_PlayerSessionUpdated(session));
    });
  }

  void _onLoadWaveform(
    LoadWaveform event,
    Emitter<AudioWaveformState> emit,
  ) async {
    if (_currentTrackId == event.trackId &&
        state.status == WaveformStatus.ready) {
      return; // Already loaded and ready
    }

    // Reset state for the new track
    emit(
      state.copyWith(status: WaveformStatus.loading, forceNullController: true),
    );
    _currentTrackId = event.trackId;
    _lastRequestedSamples = event.noOfSamples;

    // Get cached track path directly
    try {
      final result = await _getCachedTrackPathUseCase(event.trackId.value);
      result.fold((failure) => add(_TrackCacheFailed(failure.toString())), (
        filePath,
      ) {
        if (filePath != null) {
          // Pass noOfSamples to _TrackPathLoaded
          add(_TrackPathLoaded(filePath, noOfSamples: event.noOfSamples));
        } else {
          add(_TrackCacheFailed('Track not cached'));
          _startCachePolling();
        }
      });
    } catch (e) {
      add(_TrackCacheFailed('Failed to get cached track: $e'));
      _startCachePolling();
    }
  }

  Future<void> _onTrackPathLoaded(
    _TrackPathLoaded event,
    Emitter<AudioWaveformState> emit,
  ) async {
    try {
      // Ensure file exists before preparing controller
      final file = File(event.path);
      if (!await file.exists()) {
        emit(
          state.copyWith(
            status: WaveformStatus.error,
            errorMessage: 'Cached file not found on disk. Please re-cache.',
            forceNullController: true,
          ),
        );
        return;
      }
      state.playerController?.dispose();

      final newController = PlayerController();

      emit(
        state.copyWith(
          status: WaveformStatus.loading,
          playerController: newController,
        ),
      );

      // Crear PlayerWaveStyle para calcular muestras
      const waveStyle = PlayerWaveStyle(spacing: 4, waveThickness: 3);
      final noOfSamples =
          event.noOfSamples ?? waveStyle.getSamplesForWidth(400);

      await newController.preparePlayer(
        path: event.path,
        shouldExtractWaveform: true,
        noOfSamples: noOfSamples,
        volume: 0.0, // Sin volumen para que no se escuche
      );

      // NO iniciar el player - solo extraer datos
      // El PlayerController solo se usa para obtener waveformData
      // La reproducción real la maneja AudioPlayerBloc
      await newController.seekTo(0); // Posición inicial

      emit(
        state.copyWith(
          status: WaveformStatus.ready,
          playerController: newController,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WaveformStatus.error,
          errorMessage: 'Failed to prepare waveform: $e',
          forceNullController: true,
        ),
      );
    }
  }

  void _onTrackCacheFailed(
    _TrackCacheFailed event,
    Emitter<AudioWaveformState> emit,
  ) {
    emit(
      state.copyWith(status: WaveformStatus.error, errorMessage: event.error),
    );
    // If it's not cached yet, start polling for when it becomes available
    if (event.error.toLowerCase().contains('not cached')) {
      _startCachePolling();
    }
  }

  Future<void> _onPlayerSessionUpdated(
    _PlayerSessionUpdated event,
    Emitter<AudioWaveformState> emit,
  ) async {
    final controller = state.playerController;
    if (state.status != WaveformStatus.ready || controller == null) {
      return;
    }

    // Skip sync if we're in the middle of seeking from waveform
    if (_isSeekingFromWaveform) {
      return;
    }

    // Sync position always to show seek line correctly
    final sessionPosition = event.session.position.inMilliseconds;

    try {
      // Update the controller position to show the seek line
      await controller.seekTo(sessionPosition);
    } catch (e) {
      AppLogger.error('Error syncing waveform', error: e);
    }
  }

  Future<void> _onWaveformSeeked(
    WaveformSeeked event,
    Emitter<AudioWaveformState> emit,
  ) async {
    try {
      _isSeekingFromWaveform = true;
      await _audioPlaybackService.seek(event.position);
      // Reset flag after a delay to allow position sync
      Future.delayed(const Duration(milliseconds: 200), () {
        _isSeekingFromWaveform = false;
      });
    } catch (e) {
      _isSeekingFromWaveform = false;
      // Handle error, maybe emit an error state or log it
      // TODO: Replace with proper logging framework
    }
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    _cacheSubscription?.cancel();
    state.playerController?.dispose();
    return super.close();
  }

  void _startCachePolling() {
    // Avoid multiple subscriptions
    _cacheSubscription?.cancel();
    final trackId = _currentTrackId;
    if (trackId == null) return;
    _cacheSubscription = Stream.periodic(const Duration(seconds: 1)).listen((
      _,
    ) async {
      try {
        final result = await _getCachedTrackPathUseCase(trackId.value);
        result.fold((_) {}, (path) {
          if (path != null) {
            // Stop polling and prepare waveform
            _cacheSubscription?.cancel();
            add(_TrackPathLoaded(path, noOfSamples: _lastRequestedSamples));
          }
        });
      } catch (_) {}
    });
  }
}
