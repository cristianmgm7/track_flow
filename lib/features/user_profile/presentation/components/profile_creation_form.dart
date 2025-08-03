import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/ui/cards/base_card.dart';
import 'package:trackflow/features/ui/forms/app_form_field.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/presentation/components/creative_role_selector.dart';
import 'package:trackflow/features/user_profile/presentation/components/avatar_uploader.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class ProfileCreationForm extends StatefulWidget {
  final String? initialName;
  final String? initialAvatarUrl;
  final bool isGoogleUser;
  final Function(UserProfile profile) onSubmit;
  final bool isLoading;

  const ProfileCreationForm({
    super.key,
    this.initialName,
    this.initialAvatarUrl,
    required this.isGoogleUser,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<ProfileCreationForm> createState() => ProfileCreationFormState();
}

class ProfileCreationFormState extends State<ProfileCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();

  CreativeRole _selectedRole = CreativeRole.other;
  String _avatarUrl = '';

  // Expose submit method for parent component
  void submit() => _handleSubmit();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
    if (widget.initialAvatarUrl != null) {
      _avatarUrl = widget.initialAvatarUrl!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profile = getFormData();
    if (profile != null) {
      widget.onSubmit(profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Profile Card
          BaseCard(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.space24),
              child: Column(
                children: [
                  // Avatar Section
                  AvatarUploader(
                    initialUrl: _avatarUrl,
                    onAvatarChanged: (url) {
                      setState(() => _avatarUrl = url);
                    },
                    isGoogleUser: widget.isGoogleUser,
                  ),
                  SizedBox(height: Dimensions.space24),

                  // Name Field
                  AppFormField(
                    label: 'Your Name',
                    hint: 'Enter your full name',
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    isRequired: true,
                    validator: _validateName,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: Dimensions.space24),

                  // Creative Role Selector
                  CreativeRoleSelector(
                    selectedRole: _selectedRole,
                    onRoleChanged: (role) {
                      setState(() => _selectedRole = role);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Expose form validation for parent component
  bool get isValid => _formKey.currentState?.validate() ?? false;

  // Expose form data for parent component
  UserProfile? getFormData() {
    if (!isValid) return null;

    final avatarUrl =
        _avatarUrl.isEmpty
            ? (widget.isGoogleUser
                ? 'https://via.placeholder.com/150/4285F4/FFFFFF?text=${_nameController.text.trim().substring(0, 1).toUpperCase()}'
                : 'https://via.placeholder.com/150/CCCCCC/FFFFFF?text=${_nameController.text.trim().substring(0, 1).toUpperCase()}')
            : _avatarUrl;

    return UserProfile(
      id: UserId.fromUniqueString('temp'),
      name: _nameController.text.trim(),
      email: '', // Will be set by parent
      avatarUrl: avatarUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      creativeRole: _selectedRole,
    );
  }
}
