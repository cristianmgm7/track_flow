import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
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
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';
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

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // Try to get userId from session storage first
    final sessionStorage = sl<SessionStorage>();
    String? userId = await sessionStorage.getUserId();
    String? userEmail;

    AppLogger.info(
      'Profile creation: Getting user info - userId from storage: $userId',
      tag: 'PROFILE_CREATION',
    );

    // If session storage doesn't have userId, try to get it from auth state
    if (userId == null) {
      final authState = context.read<AuthBloc>().state;

      if (authState is AuthAuthenticated) {
        userId = authState.user.id.value;
        userEmail = authState.user.email;
        AppLogger.info(
          'Profile creation: Got user info from AuthBloc - userId: $userId, email: $userEmail',
          tag: 'PROFILE_CREATION',
        );
        // Save it to session storage for future use
        sessionStorage.saveUserId(userId);
      } else {
        AppLogger.warning(
          'Profile creation: AuthBloc state is not AuthAuthenticated: ${authState.runtimeType}',
          tag: 'PROFILE_CREATION',
        );
      }
    } else {
      // Get email from auth state even if we have userId
      final authState = context.read<AuthBloc>().state;

      if (authState is AuthAuthenticated) {
        userEmail = authState.user.email;
        AppLogger.info(
          'Profile creation: Got email from AuthBloc - email: $userEmail',
          tag: 'PROFILE_CREATION',
        );
      } else {
        AppLogger.warning(
          'Profile creation: AuthBloc state is not AuthAuthenticated: ${authState.runtimeType}',
          tag: 'PROFILE_CREATION',
        );
      }
    }

    // FALLBACK: If we still don't have email, try to get it from UserProfileBloc
    if (userEmail == null || userEmail.isEmpty) {
      AppLogger.info(
        'Profile creation: Email not available from AuthBloc, trying UserProfileBloc fallback',
        tag: 'PROFILE_CREATION',
      );

      // Use the BLoC to get user data (Clean Architecture approach)
      context.read<UserProfileBloc>().add(GetCurrentUserData());

      // Wait for the BLoC to emit the user data
      await for (final state in context.read<UserProfileBloc>().stream) {
        if (state is UserDataLoaded) {
          userEmail = state.email;
          userId ??= state.userId;
          AppLogger.info(
            'Profile creation: Got user data from UserProfileBloc - userId: $userId, email: $userEmail',
            tag: 'PROFILE_CREATION',
          );
          break;
        } else if (state is UserDataError) {
          AppLogger.error(
            'Profile creation: UserProfileBloc fallback failed: ${state.message}',
            tag: 'PROFILE_CREATION',
          );
          break;
        }
      }
    }

    if (userId == null) {
      setState(() => _isLoading = false);
      AppLogger.error(
        'Profile creation: No userId found',
        tag: 'PROFILE_CREATION',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User session not found. Please sign in again.'),
          backgroundColor: AppColors.error,
        ),
      );
      // Navigate back to auth screen
      context.go(AppRoutes.auth);
      return;
    }

    // Set default avatar if none selected
    if (_avatarUrl.isEmpty) {
      _avatarUrl =
          'https://via.placeholder.com/150/CCCCCC/FFFFFF?text=${_nameController.text.trim().substring(0, 1).toUpperCase()}';
    }

    final profile = UserProfile(
      id: UserId.fromUniqueString(userId),
      name: _nameController.text.trim(),
      email: userEmail ?? '',
      avatarUrl: _avatarUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      creativeRole: _selectedRole,
    );

    AppLogger.info(
      'Profile creation: Creating profile with - name: ${profile.name}, email: ${profile.email}, avatar: ${profile.avatarUrl}',
      tag: 'PROFILE_CREATION',
    );

    context.read<UserProfileBloc>().add(CreateUserProfile(profile));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        if (state is UserProfileSaved) {
          // Profile was created successfully, notify AppFlowBloc
          // This will trigger a re-evaluation of the app flow
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
        }
      },
      child: AppScaffold(
        body: AppSafeArea(
          child: AppPadding(
            all: Dimensions.space16,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: Dimensions.space32),

                          // Welcome Header
                          _buildWelcomeHeader(),
                          SizedBox(height: Dimensions.space32),

                          // Profile Form Card
                          BaseCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar Section
                                AvatarUploader(
                                  initialUrl: _avatarUrl,
                                  onAvatarChanged: (url) {
                                    setState(() => _avatarUrl = url);
                                  },
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
                          SizedBox(height: Dimensions.space24),

                          // Info Card
                          _buildInfoCard(),
                        ],
                      ),
                    ),
                  ),

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
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Complete Your Profile 🎵',
          style: AppTextStyle.headlineLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: Dimensions.space8),
        Text(
          'Great! You\'re almost ready to start collaborating. Let\'s personalize your profile so other musicians can connect with you.',
          style: AppTextStyle.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return BaseCard(
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: Dimensions.iconMedium,
          ),
          SizedBox(width: Dimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why This Matters',
                  style: AppTextStyle.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Dimensions.space4),
                Text(
                  'Your profile helps collaborators understand your role and expertise. This information will be visible to other musicians in the platform.',
                  style: AppTextStyle.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
