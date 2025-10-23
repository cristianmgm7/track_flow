import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/audio_player_state.dart';
import '../../../audio_context/presentation/bloc/audio_context_bloc.dart';
import '../../../audio_context/presentation/bloc/audio_context_state.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget for displaying expanded track information with album art and metadata
class ExpandedTrackInfo extends StatelessWidget {
  const ExpandedTrackInfo({
    super.key,
    required this.state,
  });

  final AudioPlayerState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    String title = 'No track selected';
    String artist = '';
    String? albumArt;

    if (state is AudioPlayerSessionState) {
      final sessionState = state as AudioPlayerSessionState;
      if (sessionState.session.currentTrack != null) {
        title = sessionState.session.currentTrack!.title;
        artist = sessionState.session.currentTrack!.artist; // Fallback to metadata artist
        albumArt = sessionState.session.currentTrack!.coverUrl;
      }
    } else if (state is AudioPlayerReady) {
      title = 'Ready to play';
      artist = 'Select a track to begin';
    } else if (state is AudioPlayerLoading) {
      title = 'Loading...';
      artist = 'Preparing audio player';
    } else if (state is AudioPlayerError) {
      title = 'Playback Error';
      artist = 'Please try again';
    }

    final albumArtSize = screenSize.width * 0.6;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Large album art
        Container(
          width: albumArtSize,
          height: albumArtSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.primaryColor.withValues(alpha: 0.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child:
              albumArt != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: albumArt,
                      width: albumArtSize,
                      height: albumArtSize,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: albumArtSize,
                        height: albumArtSize,
                        color: AppColors.grey800,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.music_note,
                        color: AppColors.primary,
                        size: albumArtSize * 0.3,
                      ),
                    ),
                  )
                  : Icon(
                    Icons.music_note,
                    color: AppColors.primary,
                    size: albumArtSize * 0.3,
                  ),
        ),

        const SizedBox(height: 32),

        // Track title - larger and centered
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),

        if (artist.isNotEmpty) ...[
          const SizedBox(height: 8),
          // Use both audio context and audio player state for artist info
          BlocBuilder<AudioContextBloc, AudioContextState>(
            builder: (context, contextState) {
              String displayArtist = artist; // Fallback from audio metadata

              // Override with context if available (more accurate user name)
              if (contextState is AudioContextLoaded &&
                  contextState.collaborator != null) {
                displayArtist = contextState.collaborator!.name;
              }

              return Text(
                displayArtist,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
        ],
      ],
    );
  }
}
