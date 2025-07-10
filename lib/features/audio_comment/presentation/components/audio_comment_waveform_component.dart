import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_state.dart';
import 'package:trackflow/features/audio_cache/track/presentation/bloc/track_cache_event.dart';

class AudioCommentWaveform extends StatefulWidget {
  const AudioCommentWaveform({super.key});

  @override
  State<AudioCommentWaveform> createState() => _AudioCommentWaveformState();
}

class _AudioCommentWaveformState extends State<AudioCommentWaveform> {
  final PlayerController _playerController = PlayerController();
  StreamSubscription? _playerStateSubscription;
  int _currentPosition = 0;
  String? _currentTrackId;

  @override
  void initState() {
    super.initState();
    _playerStateSubscription = _playerController.onPlayerStateChanged.listen((
      state,
    ) {
      if (state == PlayerState.stopped) {
        // Handle visual reset if needed
      }
    });
    _playerController.onCurrentDurationChanged.listen((pos) {
      setState(() {
        _currentPosition = pos;
      });
    });
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AudioPlayerBloc, AudioPlayerState>(
      listener: (context, state) {
        if (state is AudioPlayerSessionState) {
          final sessionPosition = state.session.position.inMilliseconds;
          final controllerPosition =
              _playerController.playerState == PlayerState.playing
                  ? _currentPosition
                  : 0;

          if ((sessionPosition - controllerPosition).abs() > 500) {
            _playerController.seekTo(sessionPosition);
          }
        }
      },
      builder: (context, state) {
        if (state is AudioPlayerSessionState &&
            (state is AudioPlayerPlaying || state is AudioPlayerPaused)) {
          final track = state.session.currentTrack;
          if (track == null) return const SizedBox.shrink();

          // Dispatch event when track changes
          if (_currentTrackId != track.id.value) {
            _currentTrackId = track.id.value;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<TrackCacheBloc>().add(
                GetCachedTrackPathRequested(track.id.value),
              );
            });
          }

          return BlocBuilder<TrackCacheBloc, TrackCacheState>(
            builder: (context, cacheState) {
              if (cacheState is TrackCacheLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (cacheState is TrackCachePathLoaded &&
                  cacheState.filePath != null) {
                final localPath = cacheState.filePath!;
                Future.microtask(() {
                  if (_playerController.playerState == PlayerState.stopped) {
                    _playerController.preparePlayer(
                      path: localPath,
                      shouldExtractWaveform: true,
                      noOfSamples: 100,
                      volume: 0.0,
                    );
                  }
                });

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
                      AudioFileWaveforms(
                        size: const Size(double.infinity, 60),
                        playerController: _playerController,
                        enableSeekGesture: true,
                        waveformType: WaveformType.fitWidth,
                        playerWaveStyle: PlayerWaveStyle(
                          fixedWaveColor: Colors.blueAccent[100]!,
                          liveWaveColor: Colors.blueAccent,
                          spacing: 4,
                          waveThickness: 2,
                          showSeekLine: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              state is AudioPlayerPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              size: 48,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {
                              if (state is AudioPlayerPlaying) {
                                context.read<AudioPlayerBloc>().add(
                                  const PauseAudioRequested(),
                                );
                              } else {
                                context.read<AudioPlayerBloc>().add(
                                  const ResumeAudioRequested(),
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
                return const Center(child: Text('Preparing waveform...'));
              }
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
