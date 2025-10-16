import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/audio_player_bloc.dart';
import '../../bloc/audio_player_state.dart';
import '../../../../audio_context/presentation/bloc/audio_context_bloc.dart';
import '../../../../audio_context/presentation/bloc/audio_context_state.dart';
import '../../../../audio_context/presentation/bloc/audio_context_event.dart';
import '../../../../../core/entities/unique_id.dart';
import 'duration_formatter.dart';

/// Simple, focused widget for displaying track information in the mini player
class TrackInfoWidget extends StatefulWidget {
  const TrackInfoWidget({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<TrackInfoWidget> createState() => _TrackInfoWidgetState();
}

class _TrackInfoWidgetState extends State<TrackInfoWidget> {
  String? _currentTrackId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, playerState) {
        // Extract track info from player state
        String title = 'No track';
        String trackId = '';

        if (playerState is AudioPlayerSessionState) {
          final session = playerState.session;
          if (session.currentTrack != null) {
            title = session.currentTrack!.title;
            trackId = session.currentTrack!.id.value;
            _loadContextIfNeeded(trackId);
          }
        } else if (playerState is AudioPlayerReady) {
          title = 'Ready to play';
        }

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
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

                // Artist and duration from context
                BlocBuilder<AudioContextBloc, AudioContextState>(
                  builder: (context, contextState) {
                    if (contextState is AudioContextLoaded) {
                      final context = contextState.context;
                      final artist =
                          context.collaborator?.name ?? 'Unknown Artist';
                      final duration = context.activeVersionDuration;

                      final durationText =
                          duration != null && duration.inMilliseconds > 0
                              ? DurationFormatter.format(duration)
                              : '';

                      final hasSecondLine =
                          artist.isNotEmpty || durationText.isNotEmpty;

                      return hasSecondLine
                          ? Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Row(
                              children: [
                                if (artist.isNotEmpty) ...[
                                  Flexible(
                                    child: Text(
                                      artist,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .textTheme
                                                .bodySmall
                                                ?.color
                                                ?.withValues(alpha: 0.7),
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (durationText.isNotEmpty) ...[
                                    Text(
                                      ' • ',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .textTheme
                                                .bodySmall
                                                ?.color
                                                ?.withValues(alpha: 0.5),
                                          ),
                                    ),
                                  ],
                                ],
                                if (durationText.isNotEmpty)
                                  Text(
                                    durationText,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withValues(alpha: 0.7),
                                    ),
                                  ),
                              ],
                            ),
                          )
                          : const SizedBox.shrink();
                    } else if (contextState is AudioContextLoading) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          'Loading artist...',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    } else if (contextState is AudioContextError) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          'Tap to retry',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error.withValues(alpha: 0.7),
                          ),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Load track context when track changes
  void _loadContextIfNeeded(String trackId) {
    if (trackId != _currentTrackId && trackId.isNotEmpty) {
      _currentTrackId = trackId;

      // Trigger context loading using postframe callback to avoid build conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        context.read<AudioContextBloc>().add(
          LoadTrackContextRequested(AudioTrackId.fromUniqueString(trackId)),
        );
      });
    }
  }
}
