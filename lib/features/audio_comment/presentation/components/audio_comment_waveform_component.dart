import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_state.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_event.dart';
import 'package:trackflow/features/audio_cache/shared/domain/entities/cached_audio.dart';
import 'package:trackflow/core/di/injection.dart';

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
        if (state is AudioPlayerSessionState &&
            (state is AudioPlayerPlaying || state is AudioPlayerPaused)) {
          final track = state.session.currentTrack;
          if (track == null) return const SizedBox.shrink();
          return BlocProvider<TrackCacheBloc>(
            create: (context) {
              final bloc = sl<TrackCacheBloc>();
              bloc.add(GetTrackCacheStatusRequested(track.id.value));
              bloc.add(GetCachedTrackPathRequested(track.id.value));
              return bloc;
            },
            child: BlocBuilder<TrackCacheBloc, TrackCacheState>(
              builder: (context, cacheState) {
                if (cacheState is TrackCacheLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (cacheState is TrackCachePathLoaded &&
                    cacheState.filePath != null) {
                  final localPath = cacheState.filePath!;
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
                          track.title,
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
                                spacing: 4,
                                waveThickness: 2,
                                showSeekLine: true,
                              ),
                            ),
                            Positioned(
                              right: 8,
                              child: FloatingActionButton(
                                mini: true,
                                heroTag: 'add-comment',
                                child: const Icon(Icons.add),
                                onPressed: () async {
                                  final bloc = context.read<AudioPlayerBloc>();
                                  final currentState = bloc.state;
                                  if (currentState is AudioPlayerPlaying ||
                                      currentState is AudioPlayerPaused) {
                                    // Get current position from player controller
                                    final currentPosition =
                                        await _playerController.getDuration(
                                          DurationType.current,
                                        );
                                    // TODO: dispatch an event or show a comment input dialog
                                    print(
                                      'Add comment at position: $currentPosition',
                                    );
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
                } else if (cacheState is TrackCacheOperationFailure) {
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
