import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/audio_track/presentation/models/audio_track_ui_model.dart';
import 'package:trackflow/features/ui/cards/base_card.dart';
import 'package:trackflow/features/ui/track/track_cover_art.dart';

class TrackListItem extends StatelessWidget {
  final AudioTrackUiModel track;
  final VoidCallback? onTap;

  const TrackListItem({
    super.key,
    required this.track,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      margin: EdgeInsets.zero,
      borderRadius: BorderRadius.zero,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.space16,
        vertical: Dimensions.space0,
      ),
      onTap: onTap,
      child: Row(
        children: [
          // Cover art
          TrackCoverArt(track: track.track, size: Dimensions.avatarLarge),
          SizedBox(width: Dimensions.space12),
          // Track info
          Expanded(child: Text(
                  track.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

