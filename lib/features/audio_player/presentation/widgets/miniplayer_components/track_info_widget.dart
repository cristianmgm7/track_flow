import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

abstract class ITrackInfoBuilder {
  TrackDisplayInfo buildFromState(AudioPlayerState state);
}

class TrackInfoBuilder implements ITrackInfoBuilder {
  @override
  TrackDisplayInfo buildFromState(AudioPlayerState state) {
    String title = 'No track';
    String duration = '';
    String trackId = '';

    if (state is AudioPlayerSessionState) {
      final session = state.session;
      if (session.currentTrack != null) {
        title = session.currentTrack!.title;
        trackId = session.currentTrack!.id.toString();

        if (session.duration != null) {
          duration = DurationFormatter.format(session.duration!);
        }
      }
    } else if (state is AudioPlayerReady) {
      title = 'Ready to play';
    } else if (state is AudioPlayerLoading) {
      title = 'Loading...';
    } else if (state is AudioPlayerError) {
      title = 'Error';
    }

    return TrackDisplayInfo(
      title: title,
      duration: duration,
      trackId: trackId,
    );
  }
}

class TrackInfoWidget extends StatefulWidget {
  const TrackInfoWidget({
    super.key,
    required this.state,
    required this.onTap,
    this.trackContextService,
    this.trackInfoBuilder,
  });

  final AudioPlayerState state;
  final VoidCallback onTap;
  final ITrackContextService? trackContextService;
  final ITrackInfoBuilder? trackInfoBuilder;

  @override
  State<TrackInfoWidget> createState() => _TrackInfoWidgetState();
}

class _TrackInfoWidgetState extends State<TrackInfoWidget> {
  String? _currentTrackId;
  late final ITrackContextService _contextService;
  late final ITrackInfoBuilder _infoBuilder;

  @override
  void initState() {
    super.initState();
    _contextService = widget.trackContextService ?? TrackContextService();
    _infoBuilder = widget.trackInfoBuilder ?? TrackInfoBuilder();
  }

  void _handleTrackChange(String trackId) {
    if (trackId != _currentTrackId && trackId.isNotEmpty) {
      _currentTrackId = trackId;
      _contextService.loadTrackContext(context, trackId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trackInfo = _infoBuilder.buildFromState(widget.state);

    // Solo cargar contexto si el track cambió - usando postFrameCallback para evitar builds durante builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleTrackChange(trackInfo.trackId);
    });

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
                String displayArtist = '';

                if (contextState is AudioContextLoaded &&
                    contextState.context.collaborator != null) {
                  displayArtist = contextState.context.collaborator!.name;
                } else if (contextState is AudioContextLoading) {
                  displayArtist = 'Loading artist...';
                } else if (contextState is AudioContextError) {
                  displayArtist = 'Tap to retry';
                }

                return (displayArtist.isNotEmpty ||
                        trackInfo.duration.isNotEmpty)
                    ? Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
                              trackInfo.duration.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                '•',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ],
                          if (trackInfo.duration.isNotEmpty)
                            Text(
                              trackInfo.duration,
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
}
