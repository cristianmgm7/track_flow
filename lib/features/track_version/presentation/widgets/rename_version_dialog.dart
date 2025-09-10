import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../ui/dialogs/app_dialog.dart';
import '../../../ui/forms/app_form_field.dart';
import '../blocs/track_versions/track_versions_bloc.dart';
import '../blocs/track_versions/track_versions_event.dart';

/// Dialog for renaming a track version
class RenameVersionDialog extends StatefulWidget {
  final TrackVersionId versionId;
  final String? currentLabel;

  const RenameVersionDialog({
    super.key,
    required this.versionId,
    this.currentLabel,
  });

  static Future<void> show(
    BuildContext context, {
    required TrackVersionId versionId,
    String? currentLabel,
  }) {
    return showDialog(
      context: context,
      builder:
          (context) => RenameVersionDialog(
            versionId: versionId,
            currentLabel: currentLabel,
          ),
    );
  }

  @override
  State<RenameVersionDialog> createState() => _RenameVersionDialogState();
}

class _RenameVersionDialogState extends State<RenameVersionDialog> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.currentLabel);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Rename Version',
      content: 'Enter a new label for this version',
      customContent: AppFormField(
        label: 'Version Label',
        controller: controller,
        hint: 'Version label',
      ),
      primaryButtonText: 'Save',
      secondaryButtonText: 'Cancel',
      onPrimaryPressed: () {
        final newLabel =
            controller.text.trim().isEmpty ? null : controller.text.trim();
        context.read<TrackVersionsBloc>().add(
          RenameTrackVersionRequested(
            versionId: widget.versionId,
            newLabel: newLabel,
          ),
        );
        Navigator.of(context).pop();
      },
    );
  }
}
