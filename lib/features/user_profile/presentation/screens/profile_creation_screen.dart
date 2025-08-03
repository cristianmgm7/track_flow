import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/ui/navigation/app_scaffold.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';
import 'package:trackflow/features/user_profile/presentation/components/profile_welcome_message.dart';
import 'package:trackflow/features/user_profile/presentation/components/profile_creation_form.dart';
import 'package:trackflow/features/user_profile/presentation/components/profile_info_card.dart';

import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_events.dart';
import 'package:trackflow/core/utils/app_logger.dart';

class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final GlobalKey<ProfileCreationFormState> _formKey =
      GlobalKey<ProfileCreationFormState>();

  bool _isLoading = false;
  bool _isGoogleUser = false;
  String? _userId;
  String? _userEmail;
  String? _initialName;
  String? _initialAvatarUrl;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    _requestProfileCreationData();
  }

  void _requestProfileCreationData() {
    context.read<UserProfileBloc>().add(GetProfileCreationData());
  }

  void _handleProfileSubmit(UserProfile profile) {
    if (_userId == null || _userEmail == null) {
      _showError('User session not found. Please try again.');
      _requestProfileCreationData();
      return;
    }

    setState(() => _isLoading = true);

    final completeProfile = profile.copyWith(
      id: UserId.fromUniqueString(_userId!),
      email: _userEmail!,
    );

    AppLogger.info(
      'Profile creation: Creating profile with - name: ${completeProfile.name}, email: ${completeProfile.email}, avatar: ${completeProfile.avatarUrl}, isGoogleUser: $_isGoogleUser',
      tag: 'PROFILE_CREATION',
    );

    context.read<UserProfileBloc>().add(CreateUserProfile(completeProfile));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  void _handleAppFlowCheck() {
    AppLogger.info(
      'Profile created successfully, triggering AppFlowBloc.checkAppFlow()',
      tag: 'PROFILE_CREATION',
    );
    context.read<AppFlowBloc>().add(CheckAppFlow());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        _handleBlocState(state);
      },
      child: AppScaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Message
              ProfileWelcomeMessage(isGoogleUser: _isGoogleUser),
              const SizedBox(height: 24),

              // Profile Form
              ProfileCreationForm(
                key: _formKey,
                initialName: _initialName,
                initialAvatarUrl: _initialAvatarUrl,
                isGoogleUser: _isGoogleUser,
                onSubmit: _handleProfileSubmit,
                isLoading: _isLoading,
              ),

              // Continue Button
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Complete Setup',
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          _formKey.currentState?.submit();
                        },
                isLoading: _isLoading,
                width: double.infinity,
              ),

              const SizedBox(height: 24),

              // Info Card
              const ProfileInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBlocState(UserProfileState state) {
    if (state is ProfileCreationDataLoaded) {
      setState(() {
        _userId = state.userId;
        _userEmail = state.email;
        _isGoogleUser = state.isGoogleUser;
        _initialName = state.displayName;
        _initialAvatarUrl = state.photoUrl;
      });
      AppLogger.info(
        'Profile creation: Profile creation data loaded - userId: $_userId, email: $_userEmail, isGoogleUser: $_isGoogleUser',
        tag: 'PROFILE_CREATION',
      );
    } else if (state is UserDataLoaded) {
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
      _showError('Failed to load user session: ${state.message}');
    } else if (state is UserProfileSaved) {
      setState(() => _isLoading = false);
      _showSuccess('Profile created successfully!');
      _handleAppFlowCheck();
    } else if (state is UserProfileError) {
      setState(() => _isLoading = false);
      AppLogger.error('Profile creation failed', tag: 'PROFILE_CREATION');
      _showError('Failed to create profile. Please try again.');
    } else if (state is UserProfileLoading) {
      AppLogger.info(
        'Profile creation in progress...',
        tag: 'PROFILE_CREATION',
      );
    } else if (state is UserProfileLoaded) {
      AppLogger.info(
        'Profile loaded after creation: ${state.profile.name}',
        tag: 'PROFILE_CREATION',
      );
      _showSuccess('Welcome ${state.profile.name}! Your profile is ready.');
      _handleAppFlowCheck();
    }
  }
}
