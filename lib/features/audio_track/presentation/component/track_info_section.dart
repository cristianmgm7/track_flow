import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/ui/animations/soundbar_animation.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart';
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_state.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

/// Configuration for track info section display
class TrackInfoConfig {
  final TextStyle? trackNameStyle;
  final TextStyle? uploaderNameStyle;
  final double spacing;
  final int maxLines;
  final bool showStatusBadge;

  const TrackInfoConfig({
    this.trackNameStyle,
    this.uploaderNameStyle,
    this.spacing = 4.0,
    this.maxLines = 1,
    this.showStatusBadge = true,
  });
}

/// Widget responsible only for displaying track information (name and uploader)
class TrackInfoSection extends StatelessWidget {
  final AudioTrack track;
  final Widget? statusBadge;
  final TrackInfoConfig config;
  final VoidCallback? onTap;
  final UserProfile? uploader;

  const TrackInfoSection({
    super.key,
    required this.track,
    this.statusBadge,
    this.config = const TrackInfoConfig(),
    this.onTap,
    this.uploader,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, playerState) {
        final isCurrentTrack =
            playerState is AudioPlayerSessionState &&
            playerState.session.currentTrack?.id.value == track.id.value;
        final isPlaying = playerState is AudioPlayerPlaying && isCurrentTrack;
        final isPausedOrStopped =
            (playerState is AudioPlayerPaused ||
                playerState is AudioPlayerStopped) &&
            isCurrentTrack;
        final shouldShowSoundbar = isPlaying || isPausedOrStopped;
        final shouldHighlight =
            isCurrentTrack &&
            (playerState is AudioPlayerPlaying ||
                playerState is AudioPlayerPaused ||
                playerState is AudioPlayerStopped);

        return BlocBuilder<AudioContextBloc, AudioContextState>(
          builder: (context, contextState) {
            final uploaderName = _getUploaderNameFromState(contextState);
            return _buildTrackInfo(
              context,
              shouldShowSoundbar,
              isPlaying,
              shouldHighlight,
              uploaderName,
            );
          },
        );
      },
    );
  }

  Widget _buildTrackInfo(
    BuildContext context,
    bool showSoundbar,
    bool isPlaying,
    bool shouldHighlight,
    String uploaderNameToUse,
  ) {
    final defaultTrackStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    final defaultUploaderStyle = const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
    );

    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // Soundbar animation when playing, static when paused/stopped
            if (showSoundbar) ...[
              SoundbarAnimation(
                isPlaying: isPlaying,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
            ],
            // Track name
            Expanded(
              child: Text(
                track.name,
                style: (config.trackNameStyle ?? defaultTrackStyle).copyWith(
                  color: shouldHighlight ? AppColors.primary : null,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: config.maxLines,
              ),
            ),
          ],
        ),
        SizedBox(height: config.spacing),
        Row(
          children: [
            // Status badge (placeholder or actual widget)
            if (config.showStatusBadge) ...[
              statusBadge ?? Container(), // Placeholder when no badge provided
              
            ],
            Expanded(
              child: Text(
                uploaderNameToUse,
                style: config.uploaderNameStyle ?? defaultUploaderStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: config.maxLines,
              ),
            ),
          ],
        ),
      ],
    );

    return Expanded(
      flex: 3,
      child:
          onTap != null
              ? InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: child,
                ),
              )
              : child,
    );
  }

  String _getUploaderNameFromState(AudioContextState contextState) {
    if (contextState is AudioContextLoaded) {
      return contextState.context.collaborator?.name ?? 'Unknown User';
    } else if (contextState is AudioContextLoading) {
      return 'Loading...';
    } else if (contextState is AudioContextError) {
      return 'Error';
    }
    return 'Unknown User';
  }
}
