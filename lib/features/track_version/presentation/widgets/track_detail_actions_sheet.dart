import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/features/track_version/presentation/widgets/delete_version_dialog.dart';
import 'package:trackflow/features/track_version/presentation/widgets/rename_version_form.dart';
import 'package:trackflow/features/ui/modals/app_bottom_sheet.dart';
import 'package:trackflow/features/ui/modals/app_form_sheet.dart';
import '../../../../core/entities/unique_id.dart';
import '../blocs/track_versions/track_versions_bloc.dart';
import '../blocs/track_versions/track_versions_event.dart';

class TrackDetailActions {
  static List<AppBottomSheetAction> forVersion(
    BuildContext context,
    AudioTrackId trackId,
    TrackVersionId versionId,
  ) => [
    AppBottomSheetAction(
      icon: Icons.check_circle,
      title: 'Set as Active',
      subtitle: 'Make this version the active one',
      onTap: () {
        context.read<TrackVersionsBloc>().add(
          SetActiveTrackVersionRequested(trackId, versionId),
        );
      },
    ),
    AppBottomSheetAction(
      icon: Icons.edit,
      title: 'Rename Label',
      subtitle: 'Change the version label',
      onTap: () {
        showAppFormSheet(
          minChildSize: 0.7,
          initialChildSize: 0.7,
          maxChildSize: 0.7,
          useRootNavigator: true,
          context: context,
          title: 'Rename Version',
          child: BlocProvider.value(
            value: context.read<TrackVersionsBloc>(),
            child: RenameVersionForm(versionId: versionId),
          ),
        );
      },
    ),
    AppBottomSheetAction(
      icon: Icons.delete,
      title: 'Delete Version',
      subtitle: 'Remove this version permanently',
      onTap: () {
        showDialog(
          context: context,
          useRootNavigator: false,
          builder:
              (dialogContext) => BlocProvider.value(
                value: context.read<TrackVersionsBloc>(),
                child: DeleteVersionDialog(versionId: versionId),
              ),
        );
      },
    ),
  ];
}
