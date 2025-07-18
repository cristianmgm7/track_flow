import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart';
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_state.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/presentation/widgets/audio_track_actions.dart';
import 'package:trackflow/features/ui/modals/trackflow_action_sheet.dart';

class TrackMenuButton extends StatelessWidget {
  final AudioTrack track;
  final ProjectId projectId;
  final double size;
  final Color? color;

  const TrackMenuButton({
    super.key,
    required this.track,
    required this.projectId,
    this.size = 24.0,
    this.color,
  });

  /// Open the track actions sheet
  void _openTrackActionsSheet(
    BuildContext context,
    AudioContextState contextState,
  ) {
    showTrackFlowActionSheet(
      context: context,
      title: track.name,
      actions: TrackActions.forTrack(context, projectId, track),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioContextBloc, AudioContextState>(
      builder: (context, contextState) {
        return IconButton(
          icon: Icon(
            Icons.more_horiz,
            size: size,
            color: color ?? AppColors.textSecondary,
          ),
          onPressed: () => _openTrackActionsSheet(context, contextState),
          constraints: BoxConstraints(minWidth: size + 8, minHeight: size + 8),
          padding: EdgeInsets.zero,
          tooltip: 'Track actions',
        );
      },
    );
  }
}
