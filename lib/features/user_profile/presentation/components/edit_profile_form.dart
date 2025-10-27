import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/ui/cards/base_card.dart';
import 'package:trackflow/features/ui/forms/app_form_field.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/constants/profile_field_options.dart';
import 'package:trackflow/features/user_profile/presentation/components/creative_role_selector.dart';
import 'package:trackflow/features/user_profile/presentation/components/avatar_uploader.dart';
import 'package:trackflow/features/user_profile/presentation/components/profile_completeness_widget.dart';
import 'package:trackflow/features/user_profile/presentation/widgets/social_links_editor.dart';
import 'package:trackflow/features/user_profile/presentation/widgets/multi_select_chips.dart';

class EditProfileForm extends StatefulWidget {
  final UserProfile initialProfile;
  final Function(UserProfile profile) onSubmit;
  final bool isLoading;

  const EditProfileForm({
    super.key,
    required this.initialProfile,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<EditProfileForm> createState() => EditProfileFormState();
}

class EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _linktreeController = TextEditingController();
  final _phoneController = TextEditingController();

  // State
  CreativeRole? _selectedRole;
  String _avatarUrl = '';
  List<String> _selectedRoles = [];
  List<String> _selectedGenres = [];
  List<String> _selectedSkills = [];
  List<SocialLink> _socialLinks = [];

  // Expose submit method for parent component
  void submit() => _handleSubmit();

  // Expose method to get updated profile for preview
  UserProfile? getUpdatedProfile() {
    return _buildProfile();
  }

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final profile = widget.initialProfile;

    _nameController.text = profile.name;
    _descriptionController.text = profile.description ?? '';
    _locationController.text = profile.location ?? '';
    _websiteController.text = profile.websiteUrl ?? '';
    _linktreeController.text = profile.linktreeUrl ?? '';
    _phoneController.text = profile.contactInfo?.phone ?? '';

    _avatarUrl = profile.avatarUrl;
    _selectedRole = profile.creativeRole;
    _selectedRoles = List.from(profile.roles ?? []);
    _selectedGenres = List.from(profile.genres ?? []);
    _selectedSkills = List.from(profile.skills ?? []);
    _socialLinks = List.from(profile.socialLinks ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _linktreeController.dispose();
    _phoneController.dispose();
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

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) return null;

    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.host.contains('.')) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profile = _buildProfile();
    if (profile != null) {
      widget.onSubmit(profile);
    }
  }

  UserProfile? _buildProfile() {
    if (!(_formKey.currentState?.validate() ?? false)) return null;

    return widget.initialProfile.copyWith(
      name: _nameController.text.trim(),
      avatarUrl: _avatarUrl,
      creativeRole: _selectedRole,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      roles: _selectedRoles.isEmpty ? null : _selectedRoles,
      genres: _selectedGenres.isEmpty ? null : _selectedGenres,
      skills: _selectedSkills.isEmpty ? null : _selectedSkills,
      socialLinks: _socialLinks.isEmpty ? null : _socialLinks,
      websiteUrl: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      linktreeUrl: _linktreeController.text.trim().isEmpty
          ? null
          : _linktreeController.text.trim(),
      contactInfo: _phoneController.text.trim().isEmpty
          ? null
          : ContactInfo(phone: _phoneController.text.trim()),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: Dimensions.space8),
          // Profile Completeness Indicator
          ProfileCompletenessWidget(
            description: _descriptionController.text,
            location: _locationController.text,
            socialLinks: _socialLinks,
            roles: _selectedRoles,
            genres: _selectedGenres,
            skills: _selectedSkills,
          ),
          SizedBox(height: Dimensions.space8),

          // Basic Info Card
          _buildSectionCard(
            title: 'Basic Information',
            children: [
              // Avatar Section
              Center(
                child: AvatarUploader(
                  initialUrl: _avatarUrl,
                  onAvatarChanged: (url) {
                    setState(() => _avatarUrl = url);
                  },
                  isGoogleUser: false,
                ),
              ),
              SizedBox(height: Dimensions.space24),

              // Name Field
              AppFormField(
                label: 'Name',
                hint: 'Your full name',
                controller: _nameController,
                isRequired: true,
                validator: _validateName,
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: Dimensions.space16),

              // Email Field (read-only)
              AppFormField(
                label: 'Email',
                hint: widget.initialProfile.email,
                isReadOnly: true,
                isEnabled: false,
                controller: TextEditingController(text: widget.initialProfile.email),
              ),
              SizedBox(height: Dimensions.space16),

              // Creative Role Selector
              CreativeRoleSelector(
                selectedRole: _selectedRole ?? CreativeRole.other,
                onRoleChanged: (role) {
                  setState(() => _selectedRole = role);
                },
              ),
            ],
          ),

          SizedBox(height: Dimensions.space16),

          // About Card
          _buildSectionCard(
            title: 'About',
            children: [
              AppFormField(
                label: 'Bio',
                hint: 'Tell collaborators about yourself...',
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 500,
                keyboardType: TextInputType.multiline,
              ),
              SizedBox(height: Dimensions.space16),

              AppFormField(
                label: 'Location',
                hint: 'City, Country',
                controller: _locationController,
                prefixIcon: const Icon(Icons.location_on),
              ),
            ],
          ),

          SizedBox(height: Dimensions.space16),

          // Professional Card
          _buildSectionCard(
            title: 'Professional',
            children: [
              _buildChipSection(
                label: 'Roles',
                items: _selectedRoles,
                predefinedOptions: kPredefinedRoles,
                onChanged: (values) {
                  setState(() => _selectedRoles = values);
                },
              ),
              SizedBox(height: Dimensions.space16),

              _buildChipSection(
                label: 'Genres',
                items: _selectedGenres,
                predefinedOptions: kPredefinedGenres,
                onChanged: (values) {
                  setState(() => _selectedGenres = values);
                },
              ),
              SizedBox(height: Dimensions.space16),

              _buildChipSection(
                label: 'Skills',
                items: _selectedSkills,
                predefinedOptions: kPredefinedSkills,
                onChanged: (values) {
                  setState(() => _selectedSkills = values);
                },
              ),
            ],
          ),

          SizedBox(height: Dimensions.space16),

          // Links Card
          _buildSectionCard(
            title: 'Links',
            children: [
              SocialLinksEditor(
                initialLinks: _socialLinks,
                onChanged: (links) {
                  setState(() => _socialLinks = links);
                },
              ),
              SizedBox(height: Dimensions.space16),

              AppFormField(
                label: 'Website',
                hint: 'https://yourwebsite.com',
                controller: _websiteController,
                keyboardType: TextInputType.url,
                validator: _validateUrl,
                prefixIcon: const Icon(Icons.language),
              ),
              SizedBox(height: Dimensions.space16),

              AppFormField(
                label: 'Linktree',
                hint: 'https://linktr.ee/yourname',
                controller: _linktreeController,
                keyboardType: TextInputType.url,
                validator: _validateUrl,
                prefixIcon: const Icon(Icons.link),
              ),
            ],
          ),

          SizedBox(height: Dimensions.space16),

          // Contact Card
          _buildSectionCard(
            title: 'Contact',
            children: [
              AppFormField(
                label: 'Phone (Optional)',
                hint: '+1 234 567 8900',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return BaseCard(
      backgroundColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
            title,
            style: AppTextStyle.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
            ),
          ),
          SizedBox(height: Dimensions.space16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildChipSection({
    required String label,
    required List<String> items,
    required List<String> predefinedOptions,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: Dimensions.space8),
        MultiSelectChips(
          predefinedOptions: predefinedOptions,
          selectedValues: items,
          onChanged: onChanged,
          allowCustom: true,
          customPlaceholder: 'Add custom $label',
        ),
      ],
    );
  }
}
