import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_cache/track/domain/usecases/get_cached_track_path_usecase.dart';
import 'package:trackflow/features/audio_cache/track/domain/usecases/watch_cache_status.dart';
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

    // Get cached track path directly
    try {
      final result = await _getCachedTrackPathUseCase(event.trackId.value);
      result.fold((failure) => add(_TrackCacheFailed(failure.toString())), (
        filePath,
      ) {
        if (filePath != null) {
          add(_TrackPathLoaded(filePath));
        } else {
          add(_TrackCacheFailed('Track not cached'));
        }
      });
    } catch (e) {
      add(_TrackCacheFailed('Failed to get cached track: $e'));
    }
  }

  Future<void> _onTrackPathLoaded(
    _TrackPathLoaded event,
    Emitter<AudioWaveformState> emit,
  ) async {
    try {
      state.playerController?.dispose();

      final newController = PlayerController();

      emit(
        state.copyWith(
          status: WaveformStatus.loading,
          playerController: newController,
        ),
      );

      await newController.preparePlayer(
        path: event.path,
        shouldExtractWaveform: true,
        noOfSamples: 100,
        volume: 0.0, // The waveform is visual only
      );

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
  }

  Future<void> _onPlayerSessionUpdated(
    _PlayerSessionUpdated event,
    Emitter<AudioWaveformState> emit,
  ) async {
    final controller = state.playerController;
    if (state.status != WaveformStatus.ready || controller == null) {
      return;
    }

    // Sync position
    final sessionPosition = event.session.position.inMilliseconds;
    final controllerPosition =
        controller.playerState == PlayerState.playing
            ? await controller.getDuration(DurationType.current)
            : 0;

    if ((sessionPosition - controllerPosition).abs() > 500) {
      controller.seekTo(sessionPosition);
    }
  }

  Future<void> _onWaveformSeeked(
    WaveformSeeked event,
    Emitter<AudioWaveformState> emit,
  ) async {
    try {
      await _audioPlaybackService.seek(event.position);
    } catch (e) {
      // Handle error, maybe emit an error state or log it
      print('Error seeking from waveform: $e');
    }
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    _cacheSubscription?.cancel();
    state.playerController?.dispose();
    return super.close();
  }
}
