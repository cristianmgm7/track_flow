import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/audio_player/domain/entities/audio_track_metadata.dart';

class AudioCommentFloatingControls extends StatelessWidget {
  final AudioTrackMetadata track;
  final bool isPlaying;
  final bool isPaused;

  const AudioCommentFloatingControls({
    super.key,
    required this.track,
    required this.isPlaying,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título del track
          Text(
            track.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Control de play/pause
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 32,
                color: Colors.black,
              ),
              onPressed: () {
                final audioPlayerBloc = context.read<AudioPlayerBloc>();
                if (isPlaying) {
                  audioPlayerBloc.add(const PauseAudioRequested());
                } else {
                  audioPlayerBloc.add(const ResumeAudioRequested());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}