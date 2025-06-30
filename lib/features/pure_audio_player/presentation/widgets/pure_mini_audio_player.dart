import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_player_bloc.dart';
import '../bloc/audio_player_state.dart';
import 'audio_controls.dart';
import 'playback_progress.dart';
import 'queue_controls.dart';

/// Pure mini audio player widget
/// NO business logic - only audio playback controls
/// NO context dependency - works standalone
/// Can be used anywhere without collaboration context
class PureMiniAudioPlayer extends StatelessWidget {
  const PureMiniAudioPlayer({
    super.key,
    this.height = 80.0,
    this.padding = const EdgeInsets.all(12.0),
    this.backgroundColor,
    this.showQueueControls = true,
    this.showProgress = true,
    this.showTrackInfo = true,
  });

  final double height;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final bool showQueueControls;
  final bool showProgress;
  final bool showTrackInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress bar (if enabled)
                if (showProgress) ...[
                  const PlaybackProgress(
                    height: 2.0,
                    thumbRadius: 6.0,
                    showTimeLabels: false,
                  ),
                  const SizedBox(height: 8),
                ],

                // Main controls row
                Expanded(
                  child: Row(
                    children: [
                      // Track info section
                      if (showTrackInfo)
                        Expanded(
                          child: _buildTrackInfo(context, state, theme),
                        ),

                      // Audio controls
                      const AudioControls(
                        size: 20.0,
                        showStop: false,
                      ),
                      const SizedBox(width: 8),

                      // Queue controls (if enabled)
                      if (showQueueControls)
                        const QueueControls(
                          size: 18.0,
                          showRepeatMode: false,
                          showShuffleMode: false,
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrackInfo(
    BuildContext context,
    AudioPlayerState state,
    ThemeData theme,
  ) {
    String title = 'No track';
    String artist = '';
    String duration = '';

    if (state is AudioPlayerSessionState) {
      final session = state.session;
      if (session.currentTrack != null) {
        title = session.currentTrack!.title;
        artist = session.currentTrack!.artist;
        
        if (session.duration != null) {
          duration = _formatDuration(session.duration!);
        }
      }
    } else if (state is AudioPlayerReady) {
      title = 'Ready to play';
    } else if (state is AudioPlayerLoading) {
      title = 'Loading...';
    } else if (state is AudioPlayerError) {
      title = 'Error';
      artist = 'Tap to retry';
    }

    return GestureDetector(
      onTap: () {
        // Could expand to full player or show track details
        // For now, just provide basic interaction
      },
      child: Container(
        padding: const EdgeInsets.only(right: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Track title
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Artist and duration
            if (artist.isNotEmpty || duration.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Row(
                  children: [
                    if (artist.isNotEmpty) ...[
                      Flexible(
                        child: Text(
                          artist,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (artist.isNotEmpty && duration.isNotEmpty) ...[
                      Text(
                        ' • ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                    if (duration.isNotEmpty)
                      Text(
                        duration,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    } else {
      return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
  }
}