import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart';
import 'package:trackflow/features/waveform/domain/usecases/get_or_generate_waveform.dart';
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart';

part 'waveform_event.dart';
part 'waveform_state.dart';

@injectable
class WaveformBloc extends Bloc<WaveformEvent, WaveformState> {
  final WaveformRepository _waveformRepository;
  final GetOrGenerateWaveform _getOrGenerate;
  final AudioPlaybackService _audioPlaybackService;

  StreamSubscription? _sessionSubscription;
  StreamSubscription? _waveformSubscription;

  WaveformBloc({
    required WaveformRepository waveformRepository,
    required AudioPlaybackService audioPlaybackService,
    required GetOrGenerateWaveform getOrGenerate,
  }) : _waveformRepository = waveformRepository,
       _audioPlaybackService = audioPlaybackService,
       _getOrGenerate = getOrGenerate,
       super(const WaveformState()) {
    on<LoadWaveform>(_onLoadWaveform);
    on<WaveformSeekRequested>(_onWaveformSeekRequested);
    on<_WaveformDataReceived>(_onWaveformDataReceived);
    on<_PlaybackPositionUpdated>(_onPlaybackPositionUpdated);

    _listenToAudioPlayer();
  }

  void _listenToAudioPlayer() {
    _sessionSubscription = _audioPlaybackService.sessionStream.listen((
      session,
    ) {
      add(_PlaybackPositionUpdated(session.position));
    });
  }

  Future<void> _onLoadWaveform(
    LoadWaveform event,
    Emitter<WaveformState> emit,
  ) async {
    if (state.versionId == event.versionId &&
        state.status == WaveformStatus.ready) {
      return; // Already loaded for this version
    }

    emit(
      state.copyWith(
        status: WaveformStatus.loading,
        versionId: event.versionId,
        errorMessage: null,
      ),
    );

    // Cancel previous waveform subscription
    await _waveformSubscription?.cancel();

    // Listen to waveform changes
    _waveformSubscription = _waveformRepository
        .watchWaveformChanges(event.versionId)
        .listen(
          (waveform) => add(_WaveformDataReceived(waveform)),
          onError:
              (error) => add(_WaveformDataReceived(null, error.toString())),
        );

    // Try local first, then remote, then generate if possible
    if (event.audioSourceHash != null) {
      String? localPath = event.audioFilePath;
      if (localPath != null &&
          (localPath.startsWith('http://') ||
              localPath.startsWith('https://'))) {
        // Since we don't have trackId anymore, we can't use the cache use case
        // The audioFilePath should already be the correct path
      }
      final result = await _getOrGenerate.call(
        GetOrGenerateWaveformParams(
          versionId: event.versionId,
          audioFilePath: localPath!,
          audioSourceHash: event.audioSourceHash!,
          algorithmVersion: 1, // bump when algorithm changes
          targetSampleCount: event.targetSampleCount,
          forceRefresh: event.forceRefresh,
        ),
      );
      result.fold(
        (failure) => emit(
          state.copyWith(
            status: WaveformStatus.error,
            errorMessage: failure.message,
          ),
        ),
        (waveform) => add(_WaveformDataReceived(waveform)),
      );
    } else {
      // Try to find existing waveform by version
      final result = await _waveformRepository.getWaveformByVersionId(
        event.versionId,
      );

      result.fold(
        (failure) => emit(
          state.copyWith(
            status: WaveformStatus.error,
            errorMessage: failure.message,
          ),
        ),
        (waveform) => add(_WaveformDataReceived(waveform)),
      );
    }
  }

  void _onWaveformDataReceived(
    _WaveformDataReceived event,
    Emitter<WaveformState> emit,
  ) {
    if (event.error != null) {
      emit(
        state.copyWith(status: WaveformStatus.error, errorMessage: event.error),
      );
    } else if (event.waveform != null) {
      emit(
        state.copyWith(
          status: WaveformStatus.ready,
          waveform: event.waveform,
          errorMessage: null,
        ),
      );
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
