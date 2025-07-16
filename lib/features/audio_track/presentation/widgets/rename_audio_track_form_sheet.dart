import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_event.dart';
import 'package:trackflow/features/ui/forms/app_form_field.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/features/ui/buttons/secondary_button.dart';

class RenameTrackForm extends StatefulWidget {
  final AudioTrack track;

  const RenameTrackForm({super.key, required this.track});

  @override
  State<RenameTrackForm> createState() => _RenameTrackFormState();
}

class _RenameTrackFormState extends State<RenameTrackForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  TextEditingController? _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.track.name);
  }

  @override
  void dispose() {
    _nameController?.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final newName = _nameController?.text;
      setState(() => _isSubmitting = true);
      context.read<AudioTrackBloc>().add(
        EditAudioTrackEvent(
          trackId: widget.track.id,
          projectId: widget.track.projectId,
          newName: newName!,
        ),
      );
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppFormField(
            label: 'New Track Name',
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a new track name';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: 'Cancel',
                  onPressed:
                      _isSubmitting ? null : () => Navigator.of(context).pop(),
                  isDisabled: _isSubmitting,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PrimaryButton(
                  text: 'Rename',
                  onPressed: _isSubmitting ? null : _submit,
                  isLoading: _isSubmitting,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
