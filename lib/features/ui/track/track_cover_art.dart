import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_borders.dart';
import 'package:trackflow/core/theme/app_shadows.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_player/domain/entities/audio_track_metadata.dart';
import 'dart:io';
import 'dart:math' as math;

class TrackCoverArt extends StatelessWidget {
  final AudioTrack? track;
  final AudioTrackMetadata? metadata;
  final double size;
  final String? imageUrl;
  final bool showShadow;
  final BorderRadius? borderRadius;

  const TrackCoverArt({
    super.key,
    this.track,
    this.metadata,
    this.size = 48,
    this.imageUrl,
    this.showShadow = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Priority 1: Explicit imageUrl parameter (local or remote)
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (!imageUrl!.startsWith('http')) {
        return _buildLocalImageCover();
      }
      return _buildImageCover();
    }

    // Priority 2: Track's coverLocalPath
    if (track != null && track!.coverLocalPath != null && track!.coverLocalPath!.isNotEmpty) {
      return _buildTrackLocalImageCover();
    }

    // Priority 3: Track's coverUrl
    if (track != null && track!.coverUrl.isNotEmpty) {
      return _buildTrackImageCover();
    }

    // Priority 4: Metadata coverUrl (fallback to project cover art)
    if (metadata?.coverUrl != null && metadata!.coverUrl!.isNotEmpty) {
      return _buildMetadataImageCover();
    }

    // Priority 5: Generated placeholder
    return _buildGeneratedCover(context);
  }

  Widget _buildImageCover() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? AppBorders.medium,
        boxShadow: showShadow ? AppShadows.card : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? AppBorders.medium,
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildGeneratedCover(context);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingCover(context);
          },
        ),
      ),
    );
  }

  Widget _buildLocalImageCover() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? AppBorders.medium,
        boxShadow: showShadow ? AppShadows.card : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? AppBorders.medium,
        child: Image.file(
          File(imageUrl!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildGeneratedCover(context),
        ),
      ),
    );
  }

  Widget _buildTrackLocalImageCover() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? AppBorders.medium,
        boxShadow: showShadow ? AppShadows.card : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? AppBorders.medium,
        child: Image.file(
          File(track!.coverLocalPath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildGeneratedCover(context),
        ),
      ),
    );
  }

  Widget _buildTrackImageCover() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? AppBorders.medium,
        boxShadow: showShadow ? AppShadows.card : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? AppBorders.medium,
        child: Image.network(
          track!.coverUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildGeneratedCover(context),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingCover(context);
          },
        ),
      ),
    );
  }

  Widget _buildMetadataImageCover() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? AppBorders.medium,
        boxShadow: showShadow ? AppShadows.card : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? AppBorders.medium,
        child: Image.network(
          metadata!.coverUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildGeneratedCover(context),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingCover(context);
          },
        ),
      ),
    );
  }

  Widget _buildGeneratedCover(BuildContext context) {
    final String name = track?.name ?? metadata?.title ?? '';
    final iconData = _generateIconFromName(name);
    final backgroundColor = generateTrackCoverColorFromName(name, context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? AppBorders.medium,
        boxShadow: showShadow ? AppShadows.card : null,
      ),
      child: Center(
        child: Icon(
          iconData,
          size: size * 0.5,
          color: _getIconColor(backgroundColor),
        ),
      ),
    );
  }

  Widget _buildLoadingCover(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius ?? AppBorders.medium,
        boxShadow: showShadow ? AppShadows.card : null,
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.4,
          height: size * 0.4,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  IconData _generateIconFromName(String name) {
    final trackName = name.toLowerCase();
    final hash = name.hashCode;
    final random = math.Random(hash);
    if (trackName.contains('piano') || trackName.contains('key')) {
      return Icons.piano;
    } else if (trackName.contains('guitar') || trackName.contains('string')) {
      return Icons.music_note_rounded;
    } else if (trackName.contains('vocal') ||
        trackName.contains('sing') ||
        trackName.contains('voice')) {
      return Icons.mic_rounded;
    } else if (trackName.contains('drum') ||
        trackName.contains('beat') ||
        trackName.contains('rhythm')) {
      return Icons.circle_rounded;
    } else if (trackName.contains('bass') || trackName.contains('low')) {
      return Icons.speaker_rounded;
    } else if (trackName.contains('melody') || trackName.contains('lead')) {
      return Icons.music_video_rounded;
    } else if (trackName.contains('ambient') || trackName.contains('pad')) {
      return Icons.radio_rounded;
    } else if (trackName.contains('loop') || trackName.contains('sample')) {
      return Icons.queue_music_rounded;
    } else if (trackName.contains('mix') || trackName.contains('master')) {
      return Icons.album_rounded;
    } else {
      final availableIcons = [
        Icons.music_note_rounded,
        Icons.audiotrack_rounded,
        Icons.library_music_rounded,
        Icons.headphones_rounded,
        Icons.volume_up_rounded,
        Icons.piano,
        Icons.mic_rounded,
        Icons.speaker_rounded,
        Icons.radio_rounded,
      ];
      return availableIcons[random.nextInt(availableIcons.length)];
    }
  }

  Color _getIconColor(Color backgroundColor) {
    // Calculate appropriate icon color based on background
    final brightness = backgroundColor.computeLuminance();
    if (brightness > 0.5) {
      return AppColors.grey900;
    } else {
      return AppColors.grey200;
    }
  }
}

/// Utility to generate a consistent background color for a track, used for cover art and backgrounds.
Color generateTrackCoverColor(AudioTrack track, BuildContext context) {
  final hash = track.name.hashCode;
  final random = math.Random(hash);
  final colorOptions = [
    Theme.of(context).colorScheme.primaryContainer,
    Theme.of(context).colorScheme.secondaryContainer,
    Theme.of(context).colorScheme.tertiaryContainer,
    Theme.of(context).colorScheme.surfaceContainerHighest,
    AppColors.primary.withValues(alpha: 0.1),
    AppColors.accent.withValues(alpha: 0.1),
    AppColors.success.withValues(alpha: 0.1),
    AppColors.warning.withValues(alpha: 0.1),
    AppColors.info.withValues(alpha: 0.1),
  ];
  return colorOptions[random.nextInt(colorOptions.length)];
}

Color generateTrackCoverColorFromName(String name, BuildContext context) {
  final hash = name.hashCode;
  final random = math.Random(hash);
  final colorOptions = [
    Theme.of(context).colorScheme.primaryContainer,
    Theme.of(context).colorScheme.secondaryContainer,
    Theme.of(context).colorScheme.tertiaryContainer,
    Theme.of(context).colorScheme.surfaceContainerHighest,
    AppColors.primary.withValues(alpha: 0.1),
    AppColors.accent.withValues(alpha: 0.1),
    AppColors.success.withValues(alpha: 0.1),
    AppColors.warning.withValues(alpha: 0.1),
    AppColors.info.withValues(alpha: 0.1),
  ];
  return colorOptions[random.nextInt(colorOptions.length)];
}

// Factory methods for different sizes
class TrackCoverArtSizes {
  static TrackCoverArt small({
    required AudioTrack track,
    String? imageUrl,
    bool showShadow = false,
  }) {
    return TrackCoverArt(
      track: track,
      imageUrl: imageUrl,
      size: Dimensions.avatarMedium, // 32
      showShadow: showShadow,
      borderRadius: AppBorders.small,
    );
  }

  static TrackCoverArt medium({
    required AudioTrack track,
    String? imageUrl,
    bool showShadow = false,
  }) {
    return TrackCoverArt(
      track: track,
      imageUrl: imageUrl,
      size: Dimensions.avatarLarge, // 48
      showShadow: showShadow,
      borderRadius: AppBorders.medium,
    );
  }

  static TrackCoverArt large({
    required AudioTrack track,
    String? imageUrl,
    bool showShadow = false,
  }) {
    return TrackCoverArt(
      track: track,
      imageUrl: imageUrl,
      size: Dimensions.avatarXLarge, // 64
      showShadow: showShadow,
      borderRadius: AppBorders.medium,
    );
  }
}
