import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:trackflow/features/dashboard/presentation/widgets/dashboard_track_card.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';

class DashboardTracksSection extends StatelessWidget {
  final List<AudioTrack> tracks;

  const DashboardTracksSection({
    super.key,
    required this.tracks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          title: 'Tracks',
          onSeeAll: tracks.isEmpty
              ? null
              : () => context.go(AppRoutes.trackList), // New route
        ),
        SizedBox(height: Dimensions.space12),
        if (tracks.isEmpty)
          _buildEmptyState(context)
        else
          _buildTracksGrid(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Dimensions.space24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.music_note_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: Dimensions.space12),
            Text(
              'No tracks yet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTracksGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        childAspectRatio: 3,
      ),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        return DashboardTrackCard(track: track);
      },
    );
  }
}


