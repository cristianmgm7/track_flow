import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_event.dart';

class RenameTrackForm extends StatefulWidget {
  final AudioTrack track;

  const RenameTrackForm({super.key, required this.track});

  @override
  State<RenameTrackForm> createState() => _RenameTrackFormState();
}

class _RenameTrackFormState extends State<RenameTrackForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.track.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AudioTrackBloc>().add(
        EditAudioTrackEvent(
          trackId: widget.track.id,
          projectId: widget.track.projectId,
          newName: _nameController.text,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Track Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _submit, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
