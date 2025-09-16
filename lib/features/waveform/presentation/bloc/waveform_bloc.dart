import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/waveform/domain/entities/audio_waveform.dart';
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart';
import 'package:trackflow/features/waveform/domain/usecases/get_waveform_by_version.dart';
import 'package:trackflow/features/audio_player/domain/services/audio_playback_service.dart';

part 'waveform_event.dart';
part 'waveform_state.dart';

@injectable
class WaveformBloc extends Bloc<WaveformEvent, WaveformState> {
  final GetWaveformByVersion _getWaveformByVersion;
  final AudioPlaybackService _audioPlaybackService;

  StreamSubscription? _sessionSubscription;

  WaveformBloc({
    required WaveformRepository waveformRepository,
    required AudioPlaybackService audioPlaybackService,
  }) : _getWaveformByVersion = GetWaveformByVersion(waveformRepository),
       _audioPlaybackService = audioPlaybackService,
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
      AppLogger.debug(
        'WaveformBloc: Waveform already loaded for version ${event.versionId.value}, skipping',
        tag: 'WAVEFORM_BLOC',
      );
      return; // Already loaded for this version
    }

    AppLogger.info(
      'WaveformBloc: Loading waveform for version ${event.versionId.value}',
      tag: 'WAVEFORM_BLOC',
    );
    AppLogger.debug(
      'WaveformBloc: audioSourceHash: ${event.audioSourceHash}, audioFilePath: ${event.audioFilePath}',
      tag: 'WAVEFORM_BLOC',
    );

    emit(
      state.copyWith(
        status: WaveformStatus.loading,
        versionId: event.versionId,
        errorMessage: null,
      ),
    );

    // No stream subscription: single fetch only

    // Only attempt to load existing waveform by version
    AppLogger.debug(
      'WaveformBloc: Loading waveform by versionId ${event.versionId.value}',
      tag: 'WAVEFORM_BLOC',
    );
    final result = await _getWaveformByVersion.call(event.versionId);

    result.fold(
      (failure) => {
        AppLogger.warning(
          'WaveformBloc: getWaveformByVersionId failed for version ${event.versionId.value}: ${failure.message}',
          tag: 'WAVEFORM_BLOC',
        ),
        emit(
          state.copyWith(
            status: WaveformStatus.error,
            errorMessage: failure.message,
          ),
        ),
      },
      (waveform) => {
        AppLogger.info(
          'WaveformBloc: getWaveformByVersionId succeeded for version ${event.versionId.value}',
          tag: 'WAVEFORM_BLOC',
        ),
        add(_WaveformDataReceived(waveform)),
      },
    );
  }

  void _onWaveformDataReceived(
    _WaveformDataReceived event,
    Emitter<WaveformState> emit,
  ) {
    if (event.waveform == null) {
      emit(
        state.copyWith(
          status: WaveformStatus.error,
          errorMessage: 'Waveform not found',
        ),
      );
    } else {
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
    return super.close();
  }
}
