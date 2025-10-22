import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_event.dart';

class UploadTrackCoverArtForm extends StatefulWidget {
  final AudioTrack track;

  const UploadTrackCoverArtForm({
    super.key,
    required this.track,
  });

  @override
  State<UploadTrackCoverArtForm> createState() => _UploadTrackCoverArtFormState();
}

class _UploadTrackCoverArtFormState extends State<UploadTrackCoverArtForm> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _uploadCoverArt() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    context.read<AudioTrackBloc>().add(
      UploadTrackCoverArt(
        trackId: widget.track.id,
        imageFile: _selectedImage!,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Upload Cover Art',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: Dimensions.space24),
// 
          // Image Preview
          if (_selectedImage != null)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Icon(
                  Icons.music_note,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

          const SizedBox(height: Dimensions.space24),

          // Pick Image Button
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: Text(_selectedImage == null ? 'Pick Image' : 'Change Image'),
          ),

          const SizedBox(height: Dimensions.space16),

          // Upload Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedImage != null ? _uploadCoverArt : null,
              child: const Text('Upload'),
            ),
          ),

          // Cancel Button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
