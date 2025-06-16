import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/project_detail/aplication/audioplayer_bloc.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_state.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_event.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class MiniAudioPlayer extends StatefulWidget {
  final AudioPlayerState state;
  final AudioTrack track;
  final UserProfile collaborator;
  const MiniAudioPlayer({
    super.key,
    required this.state,
    required this.track,
    required this.collaborator,
  });

  @override
  State<MiniAudioPlayer> createState() => _MiniAudioPlayerState();
}

class _MiniAudioPlayerState extends State<MiniAudioPlayer> {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  AudioPlayer? _player;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<AudioPlayerBloc>();
    _player = bloc.player;
    _positionSubscription = _player!.positionStream.listen((pos) {
      setState(() {
        _position = pos;
      });
    });
    _durationSubscription = _player!.durationStream.listen((dur) {
      if (dur != null) {
        setState(() {
          _duration = dur;
        });
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final track = widget.track;
    final collaborator = widget.collaborator;
    final isPlaying = state is AudioPlayerPlaying;
    final background = Theme.of(context).colorScheme.surface.withOpacity(0.88);

    if (state is AudioPlayerLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Card(
          color: background,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const SizedBox(
            height: 90,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }
    if (state is AudioPlayerPlaying || state is AudioPlayerPaused) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Card(
          color: background,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Play/Pause button
                    Material(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          if (isPlaying) {
                            context.read<AudioPlayerBloc>().add(
                              PauseAudioRequested(),
                            );
                          } else {
                            context.read<AudioPlayerBloc>().add(
                              ResumeAudioRequested(),
                            );
                          }
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Track info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundImage:
                                    collaborator.avatarUrl.isNotEmpty
                                        ? NetworkImage(collaborator.avatarUrl)
                                        : null,
                                child:
                                    collaborator.avatarUrl.isEmpty
                                        ? Text(
                                          collaborator.name.isNotEmpty
                                              ? collaborator.name.substring(
                                                0,
                                                1,
                                              )
                                              : '?',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                        : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  collaborator.name.isNotEmpty
                                      ? collaborator.name
                                      : 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Slider
                Slider(
                  value: _position.inMilliseconds.toDouble().clamp(
                    0.0,
                    _duration.inMilliseconds.toDouble(),
                  ),
                  max:
                      _duration.inMilliseconds.toDouble() > 0
                          ? _duration.inMilliseconds.toDouble()
                          : 1,
                  onChanged: (value) {
                    _player?.seek(Duration(milliseconds: value.toInt()));
                  },
                  activeColor: Colors.blueAccent,
                  inactiveColor: Colors.white24,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
