import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_bloc.dart';
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_event.dart';

class UploadVersionDialog extends StatefulWidget {
  final AudioTrackId trackId;
  final ProjectId projectId;

  const UploadVersionDialog({
    super.key,
    required this.trackId,
    required this.projectId,
  });

  @override
  State<UploadVersionDialog> createState() => _UploadVersionDialogState();
}

class _UploadVersionDialogState extends State<UploadVersionDialog> {
  File? _selectedFile;
  String? _versionLabel;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Upload New Version'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // File picker button
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: _isUploading ? null : _pickFile,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedFile != null
                        ? Icons.audio_file
                        : Icons.upload_file,
                    size: 48,
                    color:
                        _selectedFile != null
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _selectedFile != null
                        ? _selectedFile!.path.split('/').last
                        : 'Tap to select audio file',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          _selectedFile != null
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Version label input
          TextField(
            enabled: !_isUploading,
            decoration: InputDecoration(
              labelText: 'Version label (optional)',
              hintText: 'e.g., "v2 - Final Mix", "Remix"',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _versionLabel = value.isEmpty ? null : value,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canUpload() ? _uploadVersion : null,
          child:
              _isUploading
                  ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text('Upload'),
        ),
      ],
    );
  }

  bool _canUpload() {
    return _selectedFile != null && !_isUploading;
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = File(result.files.first.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadVersion() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Add new version to TrackVersionsBloc
      context.read<TrackVersionsBloc>().add(
        AddTrackVersionRequested(widget.trackId, label: _versionLabel),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Version uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Close dialog
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}
