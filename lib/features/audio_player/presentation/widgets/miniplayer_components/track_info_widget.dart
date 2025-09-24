import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/audio_player_bloc.dart';
import '../../bloc/audio_player_state.dart';
import '../../../../audio_context/presentation/bloc/audio_context_bloc.dart';
import '../../../../audio_context/presentation/bloc/audio_context_state.dart';
import 'duration_formatter.dart';
import 'track_context_service.dart';

class TrackDisplayInfo {
  final String title;
  final String duration;
  final String trackId;

  const TrackDisplayInfo({
    required this.title,
    required this.duration,
    required this.trackId,
  });
}

class TrackContextInfo {
  final String artistName;
  final Duration? duration;

  const TrackContextInfo({required this.artistName, this.duration});
}

abstract class ITrackInfoBuilder {
  TrackDisplayInfo buildFromState(AudioPlayerState state);
}

class TrackInfoBuilder implements ITrackInfoBuilder {
  @override
  TrackDisplayInfo buildFromState(AudioPlayerState state) {
    String title = 'No track';
    String duration =
        ''; // Duration will come from AudioContext, not AudioPlayer
    String trackId = '';

    if (state is AudioPlayerSessionState) {
      final session = state.session;
      if (session.currentTrack != null) {
        title = session.currentTrack!.title;
        trackId = session.currentTrack!.id.value;
      }
    } else if (state is AudioPlayerReady) {
      title = 'Ready to play';
    } else if (state is AudioPlayerLoading) {
      title = 'Loading...';
    } else if (state is AudioPlayerError) {
      title = 'Error';
    }

    return TrackDisplayInfo(title: title, duration: duration, trackId: trackId);
  }
}

abstract class ITrackContextInfoBuilder {
  TrackContextInfo buildFromState(AudioContextState state);
}

class TrackContextInfoBuilder implements ITrackContextInfoBuilder {
  @override
  TrackContextInfo buildFromState(AudioContextState state) {
    String artistName = '';
    Duration? duration;

    if (state is AudioContextLoaded) {
      final context = state.context;
      artistName = context.collaborator?.name ?? 'Unknown Artist';
      duration = context.activeVersionDuration;

      print('🎯 CONTEXT INFO: Artist: $artistName, Duration: $duration');
    } else if (state is AudioContextLoading) {
      artistName = 'Loading artist...';
    } else if (state is AudioContextError) {
      artistName = 'Tap to retry';
    }

    return TrackContextInfo(artistName: artistName, duration: duration);
  }
}

class TrackInfoWidget extends StatefulWidget {
  const TrackInfoWidget({
    super.key,
    this.state, // Make optional for backwards compatibility
    required this.onTap,
    this.trackContextService,
    this.trackInfoBuilder,
    this.contextInfoBuilder,
  });

  final AudioPlayerState? state; // Optional, will use BlocBuilder if null
  final VoidCallback onTap;
  final ITrackContextService? trackContextService;
  final ITrackInfoBuilder? trackInfoBuilder;
  final ITrackContextInfoBuilder? contextInfoBuilder;

  @override
  State<TrackInfoWidget> createState() => _TrackInfoWidgetState();
}

class _TrackInfoWidgetState extends State<TrackInfoWidget> {
  String? _currentTrackId;
  late final ITrackContextService _contextService;
  late final ITrackInfoBuilder _infoBuilder;
  late final ITrackContextInfoBuilder _contextInfoBuilder;

  @override
  void initState() {
    super.initState();
    _contextService = widget.trackContextService ?? TrackContextService();
    _infoBuilder = widget.trackInfoBuilder ?? TrackInfoBuilder();
    _contextInfoBuilder =
        widget.contextInfoBuilder ?? TrackContextInfoBuilder();
  }

  void _handleTrackChange(String trackId) {
    if (trackId != _currentTrackId && trackId.isNotEmpty) {
      _currentTrackId = trackId;
      if (!mounted) return;
      // Load context for the new track
      _contextService.loadTrackContext(context, trackId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use BlocBuilder if no state provided, otherwise use provided state
    if (widget.state != null) {
      return _buildTrackInfo(context, theme, widget.state!);
    } else {
      return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
        builder: (context, state) {
          return _buildTrackInfo(context, theme, state);
        },
      );
    }
  }

  Widget _buildTrackInfo(
    BuildContext context,
    ThemeData theme,
    AudioPlayerState state,
  ) {
    final trackInfo = _infoBuilder.buildFromState(state);

    // Trigger only when props change; avoid scheduling after unmount
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _handleTrackChange(trackInfo.trackId);
      });
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.only(right: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              trackInfo.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            BlocBuilder<AudioContextBloc, AudioContextState>(
              builder: (context, contextState) {
                final contextInfo = _contextInfoBuilder.buildFromState(
                  contextState,
                );
                final displayArtist = contextInfo.artistName;
                final durationFromContext =
                    contextInfo.duration != null
                        ? DurationFormatter.format(contextInfo.duration!)
                        : '';

                return (displayArtist.isNotEmpty ||
                        durationFromContext.isNotEmpty)
                    ? Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: SizedBox(
                        width: double.infinity,
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
                                durationFromContext.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: Text(
                                  '•',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ],
                            if (durationFromContext.isNotEmpty)
                              Text(
                                durationFromContext,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.7),
                                ),
                              ),
                          ],
                        ),
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
}
