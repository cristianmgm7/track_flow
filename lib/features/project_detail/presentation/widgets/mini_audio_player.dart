import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/project_detail/aplication/audioplayer_bloc.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_state.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_event.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';

class MiniAudioPlayer extends StatefulWidget {
  final AudioPlayerState state;
  const MiniAudioPlayer({super.key, required this.state});

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
    print('[MiniAudioPlayer] build: estado actual = \\${state.runtimeType}');
    if (state is AudioPlayerLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: const Color.fromRGBO(175, 99, 99, 0.867),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (state is AudioPlayerPlaying || state is AudioPlayerPaused) {
      final trackName = state.source.track.name;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: const Color.fromRGBO(175, 99, 99, 0.867),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        trackName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        state is AudioPlayerPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Slider(
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
                activeColor: Colors.greenAccent,
                inactiveColor: Colors.white24,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
