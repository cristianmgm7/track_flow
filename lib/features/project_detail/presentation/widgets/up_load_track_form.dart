import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_event.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/ui/forms/app_form_field.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/features/ui/buttons/secondary_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:just_audio/just_audio.dart';

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
  // Removed unused _isPicking
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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['m4a', 'mp3', 'wav', 'aac', 'aiff', 'caf'],
      allowMultiple: false,
      withData: true, // critical for iOS where path can be null
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _file = result.files.first;
      });
    }
  }

  Future<File?> _materializePlatformFile(PlatformFile pf) async {
    // If we already have a real path (Android, some iOS cases), use it
    if (pf.path != null && pf.path!.isNotEmpty) {
      final f = File(pf.path!);
      if (await f.exists()) return f;
    }

    // Otherwise, write bytes or stream to a temporary file (iOS Files/iCloud)
    final tempDir = await getTemporaryDirectory();
    final safeName =
        pf.name.isNotEmpty
            ? pf.name
            : 'audio_${DateTime.now().millisecondsSinceEpoch}';
    final ext = p.extension(safeName);
    final base = ext.isEmpty ? safeName : p.basenameWithoutExtension(safeName);
    final outPath = p.join(
      tempDir.path,
      '${base}_${DateTime.now().millisecondsSinceEpoch}$ext',
    );
    final outFile = File(outPath);

    if (pf.bytes != null) {
      await outFile.writeAsBytes(pf.bytes!);
      return outFile;
    }

    if (pf.readStream != null) {
      final sink = outFile.openWrite();
      await sink.addStream(pf.readStream!);
      await sink.flush();
      await sink.close();
      return outFile;
    }

    return null;
  }

  Future<Duration> _getAudioDuration(File file) async {
    try {
      final player = AudioPlayer();
      await player.setFilePath(file.path);
      final duration = player.duration ?? Duration.zero;
      await player.dispose();
      return duration;
    } catch (_) {
      return Duration.zero;
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _trackTitle = _titleController?.text;
      final selected = _file;
      if (selected != null) {
        setState(() => _isSubmitting = true);
        final file = await _materializePlatformFile(selected);
        if (file == null) {
          setState(() => _isSubmitting = false);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not access selected audio file.'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
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
