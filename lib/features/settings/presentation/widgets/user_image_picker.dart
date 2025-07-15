import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trackflow/core/utils/image_utils.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_text_style.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key});

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;

  void _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512, // Limit image size for better performance
        maxHeight: 512,
        imageQuality: 85, // Compress image to reduce file size
      );

      if (pickedFile != null) {
        // Copy the image to a permanent location
        final permanentPath = await ImageUtils.copyImageToPermanentLocation(
          pickedFile.path,
        );

        if (permanentPath != null) {
          setState(() {
            _pickedImage = File(permanentPath);
          });
        } else {
          // Fallback to original path if copying fails
          setState(() {
            _pickedImage = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      // Show a snackbar to inform the user about the error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error selecting image: ${e.toString()}',
              style: AppTextStyle.bodyMedium.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.grey600,
            backgroundImage:
                _pickedImage != null ? FileImage(_pickedImage!) : null,
            child:
                _pickedImage == null
                    ? Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.textSecondary,
                    )
                    : null,
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _pickImage,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
          icon: Icon(Icons.image, color: AppColors.primary),
          label: Text(
            'Add Image',
            style: AppTextStyle.button.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
