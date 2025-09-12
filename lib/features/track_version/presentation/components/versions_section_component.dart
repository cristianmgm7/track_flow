import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../audio_player/presentation/bloc/audio_player_event.dart';
import '../cubit/track_detail_cubit.dart';
import 'version_header_component.dart';
import '../widgets/versions_list.dart';

class VersionsSectionComponent extends StatelessWidget {
  final AudioTrackId trackId;
  final VoidCallback onRenamePressed;
  final VoidCallback onDeletePressed;

  const VersionsSectionComponent({
    super.key,
    required this.trackId,
    required this.onRenamePressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.screenMarginSmall,
        vertical: Dimensions.space8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: VersionsList(
                    trackId: trackId,
                    onVersionSelected: (versionId) {
                      // Play the new version directly (seamless transition)
                      context.read<AudioPlayerBloc>().add(
                        PlayVersionRequested(versionId),
                      );
                      // Update cubit immediately for UI responsiveness
                      context.read<TrackDetailCubit>().setActiveVersion(
                        versionId,
                      );
                      // Do not persist active version here. That happens via header menu.
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.space8),
          VersionHeaderComponent(
            trackId: trackId,
            onRenamePressed: onRenamePressed,
            onDeletePressed: onDeletePressed,
          ),
        ],
      ),
    );
  }
}
