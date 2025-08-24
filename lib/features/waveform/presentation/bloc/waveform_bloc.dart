import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart';
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart';

part 'waveform_event.dart';
part 'waveform_state.dart';

@injectable
class WaveformBloc extends Bloc<WaveformEvent, WaveformState> {
  final WaveformRepository _waveformRepository;
  final AudioPlaybackService _audioPlaybackService;
  
  StreamSubscription? _sessionSubscription;
  StreamSubscription? _waveformSubscription;

  WaveformBloc({
    required WaveformRepository waveformRepository,
    required AudioPlaybackService audioPlaybackService,
  }) : _waveformRepository = waveformRepository,
       _audioPlaybackService = audioPlaybackService,
       super(const WaveformState()) {
    
    on<LoadWaveform>(_onLoadWaveform);
    on<WaveformSeekRequested>(_onWaveformSeekRequested);
    on<_WaveformDataReceived>(_onWaveformDataReceived);
    on<_PlaybackPositionUpdated>(_onPlaybackPositionUpdated);
    
    _listenToAudioPlayer();
  }

  void _listenToAudioPlayer() {
    _sessionSubscription = _audioPlaybackService.sessionStream.listen((session) {
      add(_PlaybackPositionUpdated(session.position));
    });
  }

  Future<void> _onLoadWaveform(
    LoadWaveform event,
    Emitter<WaveformState> emit,
  ) async {
    if (state.trackId == event.trackId && state.status == WaveformStatus.ready) {
      return; // Already loaded for this track
    }

    emit(state.copyWith(
      status: WaveformStatus.loading,
      trackId: event.trackId,
      errorMessage: null,
    ));

    // Cancel previous waveform subscription
    await _waveformSubscription?.cancel();

    // Listen to waveform changes
    _waveformSubscription = _waveformRepository
        .watchWaveformChanges(event.trackId)
        .listen(
          (waveform) => add(_WaveformDataReceived(waveform)),
          onError: (error) => add(_WaveformDataReceived(null, error.toString())),
        );

    // Try to get existing waveform
    final result = await _waveformRepository.getWaveformByTrackId(event.trackId);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: WaveformStatus.error,
        errorMessage: failure.message,
      )),
      (waveform) => add(_WaveformDataReceived(waveform)),
    );
  }

  void _onWaveformDataReceived(
    _WaveformDataReceived event,
    Emitter<WaveformState> emit,
  ) {
    if (event.error != null) {
      emit(state.copyWith(
        status: WaveformStatus.error,
        errorMessage: event.error,
      ));
    } else if (event.waveform != null) {
      emit(state.copyWith(
        status: WaveformStatus.ready,
        waveform: event.waveform,
        errorMessage: null,
      ));
    }
  }

  Future<void> _onWaveformSeekRequested(
    WaveformSeekRequested event,
    Emitter<WaveformState> emit,
  ) async {
    try {
      await _audioPlaybackService.seek(event.position);
    } catch (e) {
      // Handle seek error silently
    }
  }

  void _onPlaybackPositionUpdated(
    _PlaybackPositionUpdated event,
    Emitter<WaveformState> emit,
  ) {
    if (state.status == WaveformStatus.ready) {
      emit(state.copyWith(currentPosition: event.position));
    }
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    _waveformSubscription?.cancel();
    return super.close();
  }
}