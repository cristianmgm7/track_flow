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
  bool _isGoogleUser = false; // ✅ NUEVO: Flag para usuarios de Google

  @override
  void initState() {
    super.initState();
    _loadGoogleData(); // ✅ NUEVO: Cargar datos de Google
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
      if (!mounted) return;
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
      if (!mounted) return;
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
      if (!mounted) return;
      context.read<UserProfileBloc>().add(GetCurrentUserData());

      // Wait for the BLoC to emit the user data
      if (!mounted) return;
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User session not found. Please sign in again.'),
          backgroundColor: AppColors.error,
        ),
      );
      // Navigate back to auth screen
      if (!mounted) return;
      context.go(AppRoutes.auth);
      return;
    }

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
      id: UserId.fromUniqueString(userId),
      name: _nameController.text.trim(),
      email: userEmail ?? '',
      avatarUrl: _avatarUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      creativeRole: _selectedRole,
    );

    AppLogger.info(
      'Profile creation: Creating profile with - name: ${profile.name}, email: ${profile.email}, avatar: ${profile.avatarUrl}, isGoogleUser: $_isGoogleUser',
      tag: 'PROFILE_CREATION',
    );

    if (!mounted) return;
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
