import 'package:flutter/material.dart';
import 'package:trackflow/features/audio_context/domain/entities/track_context.dart';

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
  final String trackName;
  final String uploaderName;
  final Widget? statusBadge;
  final TrackInfoConfig config;
  final VoidCallback? onTap;
  final UserProfile? uploader;

  const TrackInfoSection({
    super.key,
    required this.trackName,
    required this.uploaderName,
    this.statusBadge,
    this.config = const TrackInfoConfig(),
    this.onTap,
    this.uploader,
  });

  @override
  Widget build(BuildContext context) {
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
        Text(
          trackName,
          style: config.trackNameStyle ?? defaultTrackStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: config.maxLines,
        ),
        SizedBox(height: config.spacing),
        Row(
          children: [
            // Status badge (placeholder or actual widget)
            if (config.showStatusBadge) ...[
              statusBadge ?? Container(), // Placeholder when no badge provided
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                uploaderName,
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
}
