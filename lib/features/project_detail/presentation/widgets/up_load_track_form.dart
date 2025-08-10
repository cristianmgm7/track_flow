import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_event.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:just_audio/just_audio.dart';
import 'package:trackflow/features/ui/forms/app_form_field.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/features/ui/buttons/secondary_button.dart';

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
  bool _isSubmitting = false;
  final bool _isPicking = false;
  TextEditingController? _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController?.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _file = result.files.first;
      });
    }
  }

  Future<Duration> _getAudioDuration(File file) async {
    final player = AudioPlayer();
    try {
      await player.setFilePath(file.path);
      return player.duration ?? Duration.zero;
    } finally {
      await player.dispose();
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _trackTitle = _titleController?.text;
      final filePath = _file?.path;
      if (filePath != null) {
        setState(() => _isSubmitting = true);
        final file = File(filePath);
        final duration = await _getAudioDuration(file);

        if (!mounted) return;
        context.read<AudioTrackBloc>().add(
          UploadAudioTrackEvent(
            name: _trackTitle!,
            file: file,
            duration: duration,
            projectId: widget.project.id,
          ),
        );
        setState(() => _isSubmitting = false);
        if (!mounted) return;
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an audio file.'),
            backgroundColor: AppColors.error,
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
          AppFormField(
            label: 'Track Title',
            hint: 'Enter the title of your track',
            controller: _titleController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a track title';
              }
              return null;
            },
          ),
          const SizedBox(height: Dimensions.space24),
          SecondaryButton(
            text: _file == null ? 'Select Audio File' : 'Change Audio File',
            icon: Icons.music_note,
            onPressed: _isSubmitting ? null : _pickFile,
            isDisabled: _isSubmitting,
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
          PrimaryButton(
            text: 'Upload Track',
            onPressed: _isSubmitting ? null : _submit,
            isLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }
}
