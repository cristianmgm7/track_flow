import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/ui/navigation/app_scaffold.dart';
import 'package:trackflow/features/ui/forms/app_form_field.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/features/ui/cards/base_card.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';
import 'package:trackflow/features/user_profile/presentation/components/creative_role_selector.dart';
import 'package:trackflow/features/user_profile/presentation/components/avatar_uploader.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_events.dart';
import 'package:trackflow/core/utils/app_logger.dart';

class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();

  CreativeRole _selectedRole = CreativeRole.other;
  String _avatarUrl = '';
  bool _isLoading = false;
  bool _isGoogleUser = false; // ✅ NUEVO: Flag para usuarios de Google

  // User data for profile creation (loaded via BLoC)
  String? _userId;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadGoogleData(); // ✅ NUEVO: Cargar datos de Google
    // Request current user data through BLoC
    context.read<UserProfileBloc>().add(GetCurrentUserData());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  /// ✅ NUEVO: Cargar datos de Google si están disponibles
  Future<void> _loadGoogleData() async {
    try {
      final sessionStorage = sl<SessionStorage>();
      final isNewGoogleUser =
          await sessionStorage.getBool('is_new_google_user') ?? false;

      if (isNewGoogleUser) {
        AppLogger.info(
          'Loading Google data for profile creation',
          tag: 'PROFILE_CREATION',
        );

        final googleDisplayName = await sessionStorage.getString(
          'google_display_name',
        );
        final googlePhotoUrl = await sessionStorage.getString(
          'google_photo_url',
        );

        setState(() {
          _isGoogleUser = true;

          if (googleDisplayName != null && googleDisplayName.isNotEmpty) {
            _nameController.text = googleDisplayName;
            AppLogger.info(
              'Pre-filled name with Google data: $googleDisplayName',
              tag: 'PROFILE_CREATION',
            );
          }

          if (googlePhotoUrl != null && googlePhotoUrl.isNotEmpty) {
            _avatarUrl = googlePhotoUrl;
            AppLogger.info(
              'Pre-filled avatar with Google photo: $googlePhotoUrl',
              tag: 'PROFILE_CREATION',
            );
          }
        });

        // Limpiar datos temporales de Google
        await sessionStorage.remove('google_display_name');
        await sessionStorage.remove('google_photo_url');
        await sessionStorage.setBool('is_new_google_user', false);

        AppLogger.info(
          'Google data loaded and cleaned up',
          tag: 'PROFILE_CREATION',
        );
      }
    } catch (e) {
      AppLogger.error(
        'Error loading Google data: $e',
        tag: 'PROFILE_CREATION',
        error: e,
      );
    }
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

    // Check if we have user data from BLoC
    if (_userId == null || _userEmail == null) {
      AppLogger.error(
        'Profile creation: User data not loaded - userId: $_userId, email: $_userEmail',
        tag: 'PROFILE_CREATION',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User session not found. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );

      // Request user data again through BLoC
      context.read<UserProfileBloc>().add(GetCurrentUserData());
      return;
    }

    setState(() => _isLoading = true);

    // ✅ NUEVO: Set default avatar if none selected (Google or placeholder)
    if (_avatarUrl.isEmpty) {
      if (_isGoogleUser) {
        // Para usuarios de Google, usar inicial del nombre
        _avatarUrl =
            'https://via.placeholder.com/150/4285F4/FFFFFF?text=${_nameController.text.trim().substring(0, 1).toUpperCase()}';
      } else {
        // Para usuarios normales, usar placeholder genérico
        _avatarUrl =
            'https://via.placeholder.com/150/CCCCCC/FFFFFF?text=${_nameController.text.trim().substring(0, 1).toUpperCase()}';
      }
    }

    final profile = UserProfile(
      id: UserId.fromUniqueString(_userId!),
      name: _nameController.text.trim(),
      email: _userEmail!,
      avatarUrl: _avatarUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      creativeRole: _selectedRole,
    );

    AppLogger.info(
      'Profile creation: Creating profile with - name: ${profile.name}, email: ${profile.email}, avatar: ${profile.avatarUrl}, isGoogleUser: $_isGoogleUser',
      tag: 'PROFILE_CREATION',
    );

    context.read<UserProfileBloc>().add(CreateUserProfile(profile));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        if (state is UserDataLoaded) {
          // Handle current user data loaded for profile creation
          setState(() {
            _userId = state.userId;
            _userEmail = state.email;
          });
          AppLogger.info(
            'Profile creation: User data loaded - userId: $_userId, email: $_userEmail',
            tag: 'PROFILE_CREATION',
          );
        } else if (state is UserDataError) {
          AppLogger.error(
            'Profile creation: Failed to load user data: ${state.message}',
            tag: 'PROFILE_CREATION',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load user session: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is UserProfileSaved) {
          // Profile was created successfully, reset loading state
          setState(() => _isLoading = false);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile created successfully!'),
              backgroundColor: AppColors.success,
            ),
          );

          // Notify AppFlowBloc to trigger a re-evaluation of the app flow
          AppLogger.info(
            'Profile created successfully, triggering AppFlowBloc.checkAppFlow()',
            tag: 'PROFILE_CREATION',
          );
          context.read<AppFlowBloc>().add(CheckAppFlow());
        } else if (state is UserProfileError) {
          setState(() => _isLoading = false);
          AppLogger.error('Profile creation failed', tag: 'PROFILE_CREATION');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create profile. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is UserProfileLoading) {
          AppLogger.info(
            'Profile creation in progress...',
            tag: 'PROFILE_CREATION',
          );
        } else if (state is UserProfileLoaded) {
          // Profile was loaded after creation, this means the profile exists
          // We can navigate away or show a success state
          AppLogger.info(
            'Profile loaded after creation: ${state.profile.name}',
            tag: 'PROFILE_CREATION',
          );

          // Show success message and trigger app flow check
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome ${state.profile.name}! Your profile is ready.',
              ),
              backgroundColor: AppColors.success,
            ),
          );

          // Trigger AppFlowBloc to navigate to main app
          context.read<AppFlowBloc>().add(CheckAppFlow());
        }
      },
      child: AppScaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Message
              _buildWelcomeMessage(),
              SizedBox(height: Dimensions.space24),

              // Profile Form
              _buildProfileForm(),

              // Continue Button
              SizedBox(height: Dimensions.space16),
              PrimaryButton(
                text: 'Complete Setup',
                onPressed: _handleSubmit,
                isLoading: _isLoading,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Column(
      children: [
        Text(
          _isGoogleUser ? 'Welcome to TrackFlow!' : 'Complete Your Profile',
          style: AppTextStyle.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: Dimensions.space8),
        Text(
          _isGoogleUser
              ? 'We\'ve pre-filled your profile with your Google information. Please review and complete any missing details.'
              : 'Tell us a bit about yourself to get started',
          style: AppTextStyle.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
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
                    isGoogleUser:
                        _isGoogleUser, // ✅ NUEVO: Pasar flag de Google
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
          SizedBox(height: Dimensions.space24),

          // Info Card
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return BaseCard(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.space16),
        child: Column(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary, size: 24),
            SizedBox(height: Dimensions.space8),
            Text(
              'This information helps us personalize your experience and connect you with the right collaborators.',
              style: AppTextStyle.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
