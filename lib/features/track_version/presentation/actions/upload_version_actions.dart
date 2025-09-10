import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../ui/modals/app_form_sheet.dart';
import '../blocs/track_versions/track_versions_bloc.dart';
import '../blocs/track_versions/track_versions_event.dart';
import '../widgets/upload_version_form.dart';

/// Action handlers for upload version functionality
class UploadVersionActions {
  /// Shows the upload version dialog and handles the result
  static Future<void> showUploadVersionDialog({
    required BuildContext context,
    required AudioTrackId trackId,
    required ProjectId projectId,
  }) async {
    final result = await showAppFormSheet(
      context: context,
      title: 'Upload Version',
      child: UploadVersionForm(trackId: trackId, projectId: projectId),
      // Keep BLoCs available inside the sheet
      reprovideBlocs: [context.read<TrackVersionsBloc>()],
    );

    if (result is UploadVersionResult) {
      context.read<TrackVersionsBloc>().add(
        AddTrackVersionRequested(
          trackId: trackId,
          file: result.file,
          label: result.label,
        ),
      );
    }
  }
}
