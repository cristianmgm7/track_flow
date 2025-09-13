import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../audio_player/presentation/bloc/audio_player_event.dart';
import '../cubit/track_detail_cubit.dart';
import '../widgets/versions_list.dart';

class VersionsSectionComponent extends StatelessWidget {
  final AudioTrackId trackId;

  const VersionsSectionComponent({super.key, required this.trackId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Dimensions.space4),
      child: Row(
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
                  context.read<TrackDetailCubit>().setActiveVersion(versionId);
                  // Do not persist active version here. That happens via header menu.
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
