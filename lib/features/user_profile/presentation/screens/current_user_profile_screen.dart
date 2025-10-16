import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profiles/user_profiles_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/hero_user_profile_screen.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/di/injection.dart';

/// Screen that displays the current user's profile
/// 
/// This wrapper component automatically handles loading the current user's
/// profile without requiring a userId parameter. It uses the CurrentUserBloc
/// to load the current user's data from session storage.
class CurrentUserProfileScreen extends StatefulWidget {
  const CurrentUserProfileScreen({super.key});

  @override
  State<CurrentUserProfileScreen> createState() => _CurrentUserProfileScreenState();
}

class _CurrentUserProfileScreenState extends State<CurrentUserProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadCurrentUserProfile();
  }

  void _loadCurrentUserProfile() {
    AppLogger.info(
      'CurrentUserProfileScreen: Loading current user profile',
      tag: 'CURRENT_USER_PROFILE_SCREEN',
    );

    // Trigger loading of current user profile
    context.read<CurrentUserBloc>().add(WatchCurrentUserProfile());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentUserBloc, CurrentUserState>(
      builder: (context, state) {
        if (state is CurrentUserLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        
        if (state is CurrentUserLoaded) {
          // Once we have the profile, we can use the HeroUserProfileScreen
          // Provide UserProfilesBloc for the display screen
          return BlocProvider<UserProfilesBloc>(
            create: (_) => sl<UserProfilesBloc>(),
            child: HeroUserProfileScreen(userId: state.profile.id),
          );
        }
        
        if (state is CurrentUserError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to load profile',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check your connection and try again',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCurrentUserProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Initial state - trigger loading
        if (state is CurrentUserInitial) {
          // This should not happen due to initState, but handle it
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadCurrentUserProfile();
          });
          
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        
        // Fallback
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Text('Loading profile...'),
          ),
        );
      },
    );
  }
}