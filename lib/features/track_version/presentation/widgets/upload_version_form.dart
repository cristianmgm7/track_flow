import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/features/ui/buttons/secondary_button.dart';
import 'package:trackflow/features/ui/forms/app_form_field.dart';

/// Styled upload version form aligned with TrackFlow UI/Theme
class UploadVersionForm extends StatefulWidget {
  final ProjectId projectId;
  final AudioTrackId trackId;

  const UploadVersionForm({
    super.key,
    required this.projectId,
    required this.trackId,
  });

  @override
  State<UploadVersionForm> createState() => _UploadVersionFormState();
}

class _UploadVersionFormState extends State<UploadVersionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _labelController = TextEditingController();

  PlatformFile? _pickedFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['m4a', 'mp3', 'wav', 'aac', 'aiff', 'caf'],
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  Future<File?> _materializePlatformFile(PlatformFile pf) async {
    if (pf.path != null && pf.path!.isNotEmpty) {
      final f = File(pf.path!);
      if (await f.exists()) return f;
    }

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedFile == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an audio file.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final file = await _materializePlatformFile(_pickedFile!);
    setState(() => _isSubmitting = false);

    if (!mounted) return;
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not access selected audio file.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Return the selection to the caller. The screen will dispatch BLoC event.
    Navigator.of(context).pop(
      UploadVersionResult(
        file: file,
        label: _labelController.text.isEmpty ? null : _labelController.text,
      ),
    );
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
            label: 'Version label (optional)',
            hint: 'e.g., v2 - Final Mix, Remix',
            controller: _labelController,
          ),
          const SizedBox(height: Dimensions.space24),
          SecondaryButton(
            text:
                _pickedFile == null ? 'Select Audio File' : 'Change Audio File',
            icon: Icons.music_note,
            onPressed: _isSubmitting ? null : _pickFile,
            isDisabled: _isSubmitting,
          ),
          if (_pickedFile != null)
            Padding(
              padding: const EdgeInsets.only(top: Dimensions.space8),
              child: Text(
                'Selected: ${_pickedFile!.name}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: Dimensions.space32),
          PrimaryButton(
            text: 'Upload Version',
            onPressed: _isSubmitting ? null : _submit,
            isLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }
}

class UploadVersionResult {
  final File file;
  final String? label;

  UploadVersionResult({required this.file, this.label});
}
