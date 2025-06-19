import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/services/audio_player/audioplayer_bloc.dart';
import 'package:trackflow/core/services/audio_player/audio_player_state.dart';
import 'package:trackflow/core/services/audio_player/audio_player_event.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:trackflow/features/audio_cache/audio_cache_cubit.dart';
import 'package:trackflow/features/audio_cache/audio_cache_state.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_audio_path.dart';

class AudioCommentWaveform extends StatefulWidget {
  const AudioCommentWaveform({super.key});

  @override
  State<AudioCommentWaveform> createState() => _AudioCommentWaveformState();
}

class _AudioCommentWaveformState extends State<AudioCommentWaveform> {
  final PlayerController _playerController = PlayerController();

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if ((state is AudioPlayerPlaying || state is AudioPlayerPaused) &&
            state is AudioPlayerActiveState &&
            state.visualContext == PlayerVisualContext.commentPlayer) {
          final track = state.track;
          return BlocProvider<AudioCacheCubit>(
            create:
                (context) =>
                    AudioCacheCubit(sl<GetCachedAudioPath>())..load(track.url),
            child: BlocBuilder<AudioCacheCubit, AudioCacheState>(
              builder: (context, cacheState) {
                if (cacheState is AudioCacheLoading ||
                    cacheState is AudioCacheProgress) {
                  return const Center(child: CircularProgressIndicator());
                } else if (cacheState is AudioCacheDownloaded) {
                  final localPath = cacheState.localPath;
                  Future.microtask(
                    () => _playerController.preparePlayer(path: localPath),
                  );
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          track.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            AudioFileWaveforms(
                              size: const Size(double.infinity, 60),
                              playerController: _playerController,
                              enableSeekGesture: false,
                              waveformType: WaveformType.fitWidth,
                              playerWaveStyle: PlayerWaveStyle(
                                fixedWaveColor: Colors.blueAccent,
                                liveWaveColor: Colors.blue,
                                spacing: 2,
                                showSeekLine: true,
                              ),
                            ),
                            Positioned(
                              right: 8,
                              child: FloatingActionButton(
                                mini: true,
                                heroTag: 'add-comment',
                                child: const Icon(Icons.add),
                                onPressed: () {
                                  final bloc = context.read<AudioPlayerBloc>();
                                  final currentState = bloc.state;
                                  if (currentState is AudioPlayerPlaying ||
                                      currentState is AudioPlayerPaused) {
                                    final currentPosition = getCurrentPosition(
                                      bloc,
                                    );
                                    // dispatch an event or show a comment input dialog
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                state is AudioPlayerPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                              onPressed: () {
                                if (state is AudioPlayerPlaying) {
                                  context.read<AudioPlayerBloc>().add(
                                    PauseAudioRequested(),
                                  );
                                } else {
                                  context.read<AudioPlayerBloc>().add(
                                    ResumeAudioRequested(),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else if (cacheState is AudioCacheFailure) {
                  return Center(child: Text('Error: ${cacheState.error}'));
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
