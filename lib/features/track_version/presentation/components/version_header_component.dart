import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../ui/modals/app_bottom_sheet.dart';
import '../../../ui/modals/app_form_sheet.dart';
import '../blocs/track_versions/track_versions_bloc.dart';
import '../blocs/track_versions/track_versions_state.dart';
import '../cubit/track_detail_cubit.dart';
import '../widgets/track_detail_actions_sheet.dart';
import '../widgets/rename_version_form.dart';
import '../widgets/delete_version_dialog.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';
import 'package:trackflow/core/theme/app_colors.dart';

/// Header component for displaying active version information and actions
class VersionHeaderComponent extends StatelessWidget {
  final AudioTrackId trackId;

  const VersionHeaderComponent({super.key, required this.trackId});

  void _openTrackDetailActionsSheet(
    BuildContext context,
    TrackVersionId activeVersionId,
  ) {
    showAppActionSheet(
      showHandle: true,
      useRootNavigator: true,
      title: 'Version Actions',
      context: context,
      actions: TrackDetailActions.forVersion(
        context,
        trackId,
        activeVersionId,
        () => _showRenameDialog(context, activeVersionId),
        () => _showDeleteConfirmation(context, activeVersionId),
      ),
      initialChildSize: 0.5,
    );
  }

  void _showRenameDialog(BuildContext context, TrackVersionId versionId) {
    // Get current version info from the state
    final blocState = context.read<TrackVersionsBloc>().state;

    if (blocState is TrackVersionsLoaded && blocState.versions.isNotEmpty) {
      final activeVersion = blocState.versions.firstWhere(
        (v) => v.id == versionId,
        orElse: () => blocState.versions.first,
      );

      showAppFormSheet(
        context: context,
        title: 'Rename Version',
        child: RenameVersionForm(
          versionId: versionId,
          currentLabel: activeVersion.label,
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, TrackVersionId versionId) {
    DeleteVersionDialog.show(context, versionId: versionId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<TrackDetailCubit, TrackDetailState>(
      builder: (context, cubitState) {
        return BlocBuilder<TrackVersionsBloc, TrackVersionsState>(
          builder: (context, blocState) {
            if (blocState is! TrackVersionsLoaded) {
              return const SizedBox.shrink();
            }
            final activeId =
                cubitState.activeVersionId ?? blocState.activeVersionId;
            if (blocState.versions.isEmpty) {
              return const SizedBox.shrink();
            }

            final active =
                activeId != null
                    ? blocState.versions.firstWhere(
                      (v) => v.id == activeId,
                      orElse: () => blocState.versions.first,
                    )
                    : blocState.versions.first;

            final label = active.label ?? 'v${active.versionNumber}';
            final isActive = activeId == active.id;

            return Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (isActive)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.check_circle,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 8),
                      // Upload status badge for the active version
                      if (active.status == TrackVersionStatus.processing)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else if (active.status == TrackVersionStatus.failed)
                        const Icon(
                          Icons.error_outline,
                          size: 18,
                          color: AppColors.error,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed:
                      () => _openTrackDetailActionsSheet(context, active.id),
                  tooltip: 'Version actions',
                ),
              ],
            );
          },
        );
      },
    );
  }
}
