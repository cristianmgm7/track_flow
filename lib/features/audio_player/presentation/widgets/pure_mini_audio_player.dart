import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/widgets/pure_audio_player.dart';
import '../bloc/audio_player_bloc.dart';
import '../bloc/audio_player_state.dart';
import 'audio_controls.dart';
import 'playback_progress.dart';
import 'queue_controls.dart';
import '../../../audio_context/presentation/bloc/audio_context_bloc.dart';
import '../../../audio_context/presentation/bloc/audio_context_event.dart';
import '../../../audio_context/presentation/bloc/audio_context_state.dart';

/// Pure mini audio player widget
/// NO business logic - only audio playback controls
/// NO context dependency - works standalone
/// Can be used anywhere without collaboration context
class PureMiniAudioPlayer extends StatefulWidget {
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
  State<PureMiniAudioPlayer> createState() => _PureMiniAudioPlayerState();
}

class _PureMiniAudioPlayerState extends State<PureMiniAudioPlayer> {
  String? _currentTrackId;

  Widget _buildTrackInfo(
    BuildContext context,
    AudioPlayerState state,
    ThemeData theme,
  ) {
    String title = 'No track';
    String artist = '';
    String duration = '';
    String trackId = '';

    if (state is AudioPlayerSessionState) {
      final session = state.session;
      if (session.currentTrack != null) {
        title = session.currentTrack!.title;
        artist = session.currentTrack!.artist;
        trackId = session.currentTrack!.id.toString();

        // Load track context if track changed
        if (trackId != _currentTrackId) {
          _currentTrackId = trackId;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AudioContextBloc>().add(
              LoadTrackContextRequested(trackId),
            );
          });
        }

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
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder:
              (context) => Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: const PureAudioPlayer(),
                      ),
                    ),
                  ],
                ),
              ),
        );
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

            // Artist and duration - with context integration
            BlocBuilder<AudioContextBloc, AudioContextState>(
              builder: (context, contextState) {
                String displayArtist = artist;

                // Use collaborator name if available, otherwise fallback to artist ID
                if (contextState is AudioContextLoaded &&
                    contextState.context.collaborator != null) {
                  displayArtist = contextState.context.collaborator!.name;
                } else if (contextState is AudioContextLoading) {
                  displayArtist = 'Loading artist...';
                }

                return (displayArtist.isNotEmpty || duration.isNotEmpty)
                    ? Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Row(
                        children: [
                          if (displayArtist.isNotEmpty) ...[
                            Flexible(
                              child: Text(
                                displayArtist,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          if (displayArtist.isNotEmpty &&
                              duration.isNotEmpty) ...[
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
                    )
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: widget.padding,
        child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress bar (if enabled)
                if (widget.showProgress) ...[
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
                      if (widget.showTrackInfo)
                        Expanded(child: _buildTrackInfo(context, state, theme)),

                      // Audio controls
                      const AudioControls(size: 20.0, showStop: false),
                      const SizedBox(width: 8),

                      // Queue controls (if enabled)
                      if (widget.showQueueControls)
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

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    } else {
      return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
  }
}
