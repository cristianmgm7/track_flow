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
    final isLoading = state is AudioPlayerLoading;
    final background = Theme.of(context).colorScheme.surface.withOpacity(0.88);

    if (state is AudioPlayerPlaying ||
        state is AudioPlayerPaused ||
        state is AudioPlayerLoading) {
      return Card(
        color: background,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  // Collaborator Avatar
                  CircleAvatar(
                    radius: 22,
                    backgroundImage:
                        collaborator.avatarUrl.isNotEmpty
                            ? NetworkImage(collaborator.avatarUrl)
                            : null,
                    child:
                        collaborator.avatarUrl.isEmpty
                            ? Text(
                              collaborator.name.isNotEmpty
                                  ? collaborator.name.substring(0, 1)
                                  : '?',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(width: 16),
                  // Track and Collaborator info
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
                        const SizedBox(height: 4),
                        Text(
                          collaborator.name.isNotEmpty
                              ? collaborator.name
                              : 'Unknown',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Play/Pause button
                  Material(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap:
                          isLoading
                              ? null
                              : () {
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
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 28,
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Slider at the bottom
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                trackShape: CustomTrackShape(),
              ),
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
                activeColor: Colors.blueAccent,
                inactiveColor: Colors.white24,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 2;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
