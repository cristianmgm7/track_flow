import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/waveform/audio_waveform_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';

/// Componente que muestra el waveform con el PlayerController de la librería
class AudioCommentWaveformDisplay extends StatefulWidget {
  final AudioTrackId trackId;

  const AudioCommentWaveformDisplay({super.key, required this.trackId});

  @override
  State<AudioCommentWaveformDisplay> createState() =>
      _AudioCommentWaveformDisplayState();
}

class _AudioCommentWaveformDisplayState
    extends State<AudioCommentWaveformDisplay> {
  bool _isDragging = false;
  bool _wasPlayingBeforeDrag = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioWaveformBloc>().add(LoadWaveform(widget.trackId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      AudioWaveformBloc,
      AudioWaveformState,
      AudioWaveformState
    >(
      selector: (state) => state,
      builder: (context, waveformState) {
        return _buildWaveformBody(context, waveformState);
      },
    );
  }

  Widget _buildWaveformBody(
    BuildContext context,
    AudioWaveformState waveformState,
  ) {
    switch (waveformState.status) {
      case WaveformStatus.loading:
        return const Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Cargando forma de onda...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      case WaveformStatus.error:
        return Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error: ${waveformState.errorMessage ?? "Desconocido"}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      case WaveformStatus.ready:
        if (waveformState.playerController != null) {
          return Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: AudioFileWaveforms(
                      size: Size(
                        constraints.maxWidth,
                        constraints.maxHeight *
                            0.8, // 80% de la altura disponible
                      ),
                      playerController: waveformState.playerController!,
                      enableSeekGesture: true,
                      waveformType: WaveformType.fitWidth,
                      playerWaveStyle: PlayerWaveStyle(
                        fixedWaveColor: Colors.grey[400]!,
                        liveWaveColor: Colors.blue,
                        spacing: 10,
                        waveThickness: 5, // Definitivamente menor que spacing
                        showSeekLine: true,
                        seekLineColor: Colors.red,
                        seekLineThickness: 4,
                        waveCap: StrokeCap.round,
                      ),
                      // 🎵 Gestos sincronizados con AudioPlayerBloc
                      onDragStart:
                          (details) => _handleDragStart(
                            context,
                            details,
                            waveformState.playerController!,
                          ),
                      onDragEnd:
                          (details) => _handleDragEnd(
                            context,
                            details,
                            waveformState.playerController!,
                          ),
                      dragUpdateDetails:
                          (details) => _handleDragUpdate(
                            context,
                            details,
                            waveformState.playerController!,
                          ),
                      tapUpUpdateDetails:
                          (details) => _handleTapUp(
                            context,
                            details,
                            waveformState.playerController!,
                          ),
                    ),
                  );
                },
              ),
            ),
          );
        }
        return const Expanded(
          child: Center(
            child: Text(
              'Preparando forma de onda...',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      default:
        return const Expanded(
          child: Center(
            child: Text(
              'Inicializando...',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
    }
  }

  /// Synchronizes the waveform seek position with the AudioPlayerBloc when the user taps the waveform.
  Future<void> _syncSeekWithAudioPlayer(
    BuildContext context,
    Offset tapPosition,
    PlayerController controller,
  ) async {
    try {
      final totalDuration = await controller.getDuration(DurationType.max);
      if (totalDuration == 0) return;
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;
      final waveformWidth = renderBox.size.width;
      final tapRatio = (tapPosition.dx / waveformWidth).clamp(0.0, 1.0);
      final seekPosition = Duration(
        milliseconds: (totalDuration * tapRatio).round(),
      );
      final audioPlayerBloc = context.read<AudioPlayerBloc>();
      audioPlayerBloc.add(SeekToPositionRequested(seekPosition));
    } catch (e) {}
  }

  /// Handles the start of a drag gesture on the waveform, pausing playback if necessary.
  void _handleDragStart(
    BuildContext context,
    DragStartDetails details,
    PlayerController controller,
  ) {
    setState(() {
      _isDragging = true;
    });
    final audioPlayerBloc = context.read<AudioPlayerBloc>();
    final currentState = audioPlayerBloc.state;
    _wasPlayingBeforeDrag = currentState is AudioPlayerPlaying;
    if (_wasPlayingBeforeDrag) {
      audioPlayerBloc.add(const PauseAudioRequested());
    }
  }

  /// Handles the end of a drag gesture, synchronizing the final position and resuming playback if needed.
  void _handleDragEnd(
    BuildContext context,
    DragEndDetails details,
    PlayerController controller,
  ) async {
    setState(() {
      _isDragging = false;
    });
    try {
      final currentPosition = await controller.getDuration(
        DurationType.current,
      );
      final seekPosition = Duration(milliseconds: currentPosition);
      final audioPlayerBloc = context.read<AudioPlayerBloc>();
      audioPlayerBloc.add(SeekToPositionRequested(seekPosition));
      if (_wasPlayingBeforeDrag) {
        await Future.delayed(const Duration(milliseconds: 100));
        audioPlayerBloc.add(const ResumeAudioRequested());
      }
    } catch (e) {
      if (_wasPlayingBeforeDrag) {
        final audioPlayerBloc = context.read<AudioPlayerBloc>();
        audioPlayerBloc.add(const ResumeAudioRequested());
      }
    }
  }

  /// Handles drag updates on the waveform during a drag gesture.
  void _handleDragUpdate(
    BuildContext context,
    DragUpdateDetails details,
    PlayerController controller,
  ) {
    if (_isDragging) {}
  }

  /// Handles tap gestures on the waveform, triggering a seek if not dragging.
  void _handleTapUp(
    BuildContext context,
    TapUpDetails details,
    PlayerController controller,
  ) {
    if (!_isDragging) {
      _syncSeekWithAudioPlayer(context, details.localPosition, controller);
    }
  }
}
