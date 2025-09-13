import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../ui/forms/app_form_field.dart';
import '../../../ui/buttons/primary_button.dart';
import '../blocs/track_versions/track_versions_bloc.dart';
import '../blocs/track_versions/track_versions_state.dart';
import '../blocs/track_versions/track_versions_event.dart';

/// Form for renaming a track version (used in modal)
class RenameVersionForm extends StatefulWidget {
  final TrackVersionId versionId;
  final String? currentLabel;

  const RenameVersionForm({
    super.key,
    required this.versionId,
    this.currentLabel,
  });

  @override
  State<RenameVersionForm> createState() => _RenameVersionFormState();
}

class _RenameVersionFormState extends State<RenameVersionForm> {
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

  Future<void> _submit() async {
    final newLabel =
        controller.text.trim().isEmpty ? null : controller.text.trim();
    context.read<TrackVersionsBloc>().add(
      RenameTrackVersionRequested(
        versionId: widget.versionId,
        newLabel: newLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TrackVersionsBloc, TrackVersionsState>(
      listener: (context, state) {
        if (state is TrackVersionsLoaded) {
          // Close modal when operation completes successfully
          Navigator.of(context).pop();
        } else if (state is TrackVersionsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error renaming version: ${state.message}')),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppFormField(
            label: 'Version Label',
            controller: controller,
            hint: 'Version label',
          ),
          const SizedBox(height: 24),
          PrimaryButton(text: 'Save', onPressed: _submit),
        ],
      ),
    );
  }
}
