import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_event.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/features/ui/buttons/secondary_button.dart';

class UploadCoverArtForm extends StatefulWidget {
  final Project project;
  const UploadCoverArtForm({super.key, required this.project});

  @override
  State<UploadCoverArtForm> createState() => _UploadCoverArtFormState();
}

class _UploadCoverArtFormState extends State<UploadCoverArtForm> {
  PlatformFile? _file;
  bool _isSubmitting = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _file = result.files.first;
      });
    }
  }

  Future<void> _submit() async {
    final selected = _file;
    if (selected != null) {
      setState(() => _isSubmitting = true);

      // Get the file
      File? file;
      if (selected.path != null && selected.path!.isNotEmpty) {
        file = File(selected.path!);
      } else if (selected.bytes != null) {
        // Create temporary file from bytes
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/${selected.name}');
        await tempFile.writeAsBytes(selected.bytes!);
        file = tempFile;
      }

      if (file == null) {
        setState(() => _isSubmitting = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not access selected image file.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (!mounted) return;
      context.read<ProjectsBloc>().add(
        UploadProjectCoverArt(
          projectId: widget.project.id,
          imageFile: file,
        ),
      );
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image file.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SecondaryButton(
          text: _file == null ? 'Select Image' : 'Change Image',
          icon: Icons.image,
          onPressed: _isSubmitting ? null : _pickFile,
          isDisabled: _isSubmitting,
        ),
        if (_file != null) ...[
          const SizedBox(height: Dimensions.space16),
          if (_file!.bytes != null)
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                image: DecorationImage(
                  image: MemoryImage(_file!.bytes!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else if (_file!.path != null)
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                image: DecorationImage(
                  image: FileImage(File(_file!.path!)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: Dimensions.space8),
            child: Text(
              'Selected: ${_file!.name}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
        const SizedBox(height: Dimensions.space32),
        PrimaryButton(
          text: 'Upload Cover Art',
          onPressed: _isSubmitting ? null : _submit,
          isLoading: _isSubmitting,
        ),
      ],
    );
  }
}
