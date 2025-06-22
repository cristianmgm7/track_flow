import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_event.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

class UploadTrackForm extends StatefulWidget {
  final Project project;
  const UploadTrackForm({super.key, required this.project});

  @override
  State<UploadTrackForm> createState() => _UploadTrackFormState();
}

class _UploadTrackFormState extends State<UploadTrackForm> {
  final _formKey = GlobalKey<FormState>();
  String? _trackTitle;
  PlatformFile? _file;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _file = result.files.first;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final filePath = _file?.path;
      if (filePath != null) {
        context.read<AudioTrackBloc>().add(
          UploadAudioTrackEvent(
            name: _trackTitle!,
            file: File(filePath),
            duration: const Duration(seconds: 0),
            projectId: widget.project.id,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an audio file.'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Track Title',
              hintText: 'Enter the title of your track',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a track title';
              }
              return null;
            },
            onSaved: (value) {
              _trackTitle = value;
            },
          ),
          const SizedBox(height: Dimensions.space24),
          OutlinedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.music_note),
            label: Text(
              _file == null ? 'Select Audio File' : 'Change Audio File',
            ),
          ),
          if (_file != null)
            Padding(
              padding: const EdgeInsets.only(top: Dimensions.space8),
              child: Text(
                'Selected: ${_file!.name}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: Dimensions.space32),
          ElevatedButton(onPressed: _submit, child: const Text('Upload Track')),
        ],
      ),
    );
  }
}
