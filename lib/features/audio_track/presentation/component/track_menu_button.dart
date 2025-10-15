import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart';
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_state.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/presentation/widgets/audio_track_actions.dart';
import 'package:trackflow/features/ui/modals/app_bottom_sheet.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';

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
    // Get project from ProjectDetailBloc if available
    final project = context.read<ProjectDetailBloc>().state.project;
    
    showAppActionSheet(
      context: context,
      title: track.name,
      initialChildSize: 0.6,
      maxChildSize: 0.8,
      actions: TrackActions.forTrack(context, projectId, track, project),
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
