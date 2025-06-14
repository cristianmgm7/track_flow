import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/audio_player_cubit.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';

class MiniAudioPlayer extends StatefulWidget {
  const MiniAudioPlayer({super.key});

  @override
  State<MiniAudioPlayer> createState() => _MiniAudioPlayerState();
}

class _MiniAudioPlayerState extends State<MiniAudioPlayer> {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  late AudioPlayer _player;
  late Stream<Duration> _positionStream;
  late Stream<Duration?> _durationStream;
  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<Duration?> _durationSubscription;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AudioPlayerCubit>();
    _player = cubit.player;
    _positionStream = _player.positionStream;
    _durationStream = _player.durationStream;

    _positionSubscription = _positionStream.listen((pos) {
      setState(() {
        _position = pos;
      });
    });

    _durationSubscription = _durationStream.listen((dur) {
      if (dur != null) {
        setState(() {
          _duration = dur;
        });
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        if (state is AudioPlayerPlaying || state is AudioPlayerPaused) {
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
                            state.track.name,
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
                              context.read<AudioPlayerCubit>().pause();
                            } else {
                              context.read<AudioPlayerCubit>().resume();
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
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
                      _player.seek(Duration(milliseconds: value.toInt()));
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
      },
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
