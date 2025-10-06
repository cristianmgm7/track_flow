import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/ui/dialogs/app_dialog.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trackflow/core/utils/image_utils.dart';
import 'package:trackflow/core/widgets/user_avatar.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'dart:io';
import 'package:trackflow/features/ui/forms/app_form_field.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/features/ui/buttons/secondary_button.dart';
import 'package:path/path.dart' as p;

class EditProfileDialog extends StatefulWidget {
  final UserProfile profile;

  const EditProfileDialog({super.key, required this.profile});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _avatarUrl;
  CreativeRole? _creativeRole;
  File? _avatarFile;
  bool _isSubmitting = false;
  TextEditingController? _nameController;
  TextEditingController? _emailController;

  @override
  void initState() {
    super.initState();
    _name = widget.profile.name;
    _email = widget.profile.email;
    _avatarUrl = widget.profile.avatarUrl;
    _creativeRole = widget.profile.creativeRole;
    if (_avatarUrl.isNotEmpty && Uri.tryParse(_avatarUrl)?.isAbsolute == true) {
      // No cargar File si es URL remota
      _avatarFile = null;
    }
    _nameController = TextEditingController(text: _name);
    _emailController = TextEditingController(text: _email);
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _emailController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
        final permanentPath = await ImageUtils.saveLocalImage(
          pickedFile.path,
        );

        if (permanentPath != null) {
          setState(() {
            _avatarFile = File(permanentPath);
            // Persist only the filename key, not an absolute sandbox path
            _avatarUrl = p.basename(permanentPath);
          });
        } else {
          // Fallback to original path if copying fails
          setState(() {
            _avatarFile = File(pickedFile.path);
            _avatarUrl = p.basename(pickedFile.path);
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      // Show a snackbar or dialog to inform the user about the error
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

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController?.text;
      final email = _emailController?.text;
      setState(() => _isSubmitting = true);
      final updatedProfile = UserProfile(
        id: widget.profile.id,
        name: name ?? '',
        email: email ?? '',
        avatarUrl: _avatarFile?.path ?? _avatarUrl,
        creativeRole: _creativeRole,
        createdAt: DateTime.now(),
      );
      context.read<UserProfileBloc>().add(SaveUserProfile(updatedProfile));
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Edit Profile',
      content: '',
      customContent: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<UserProfileBloc, UserProfileState>(
                builder: (context, state) {
                  String? localPath;
                  String? remoteUrl;
                  if (state is UserProfileLoaded) {
                    localPath = state.profile.avatarLocalPath;
                    remoteUrl = state.profile.avatarUrl;
                  } else if (state is ProfileComplete) {
                    localPath = state.profile.avatarLocalPath;
                    remoteUrl = state.profile.avatarUrl;
                  } else if (state is ProfileIncomplete &&
                      state.profile != null) {
                    localPath = state.profile!.avatarLocalPath;
                    remoteUrl = state.profile!.avatarUrl;
                  } else if (state is ProfileCreationDataLoaded) {
                    remoteUrl = state.photoUrl;
                  }

                  final chosenLocal = _avatarFile?.path ?? localPath;

                  return GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: (chosenLocal != null && chosenLocal.isNotEmpty)
                          ? UserAvatar(
                            imageUrl: chosenLocal,
                            size: 80,
                            fallback: Icon(
                              Icons.person,
                              size: 40,
                              color: AppColors.textSecondary,
                            ),
                          )
                          : UserAvatar(
                            imageUrl: remoteUrl ?? _avatarUrl,
                            size: 80,
                            fallback: Icon(
                              Icons.person,
                              size: 40,
                              color: AppColors.textSecondary,
                            ),
                          ),
                    ),
                  );
                },
              ),
              SizedBox(height: Dimensions.space12),
              AppFormField(
                label: 'Name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: Dimensions.space16),
              AppFormField(
                label: 'Email',
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // Add more email validation if needed
                  return null;
                },
              ),
              SizedBox(height: Dimensions.space16),
              DropdownButtonFormField<CreativeRole>(
                initialValue: _creativeRole,
                decoration: InputDecoration(
                  labelText: 'Creative Role',
                  labelStyle: AppTextStyle.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.grey700,
                ),
                dropdownColor: AppColors.surface,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                items:
                    CreativeRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(
                          role.toString().split('.').last,
                          style: AppTextStyle.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _creativeRole = value),
                onSaved: (value) => _creativeRole = value,
              ),
              SizedBox(height: Dimensions.space24),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'Cancel',
                      onPressed:
                          _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                      isDisabled: _isSubmitting,
                    ),
                  ),
                  const SizedBox(width: Dimensions.space16),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Save',
                      onPressed: _isSubmitting ? null : _submit,
                      isLoading: _isSubmitting,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
