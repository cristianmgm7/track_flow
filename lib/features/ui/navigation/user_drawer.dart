import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/utils/image_utils.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';

class UserDrawer extends StatelessWidget {
  const UserDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          // Drawer Header with User Profile
          _buildDrawerHeader(context),
          // Drawer Body with Navigation Options
          Expanded(child: _buildDrawerBody(context)),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        if (state is UserProfileLoaded) {
          final profile = state.profile;
          final avatarProvider = ImageUtils.createSafeImageProvider(
            profile.avatarUrl,
          );

          return DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Avatar
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.grey600,
                    backgroundImage: avatarProvider,
                    child:
                        avatarProvider == null
                            ? Icon(
                              Icons.person,
                              size: 40,
                              color: AppColors.textSecondary,
                            )
                            : null,
                  ),
                ),
                const SizedBox(height: Dimensions.space16),
                // User Name
                Center(
                  child: Text(
                    profile.name,
                    style: AppTextStyle.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }

        // Loading or error state
        return DrawerHeader(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.grey600,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.space16),
              Center(
                child: Text(
                  'Loading...',
                  style: AppTextStyle.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerBody(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Settings Option
        ListTile(
          leading: Icon(
            Icons.settings_rounded,
            color: AppColors.textPrimary,
            size: Dimensions.iconMedium,
          ),
          title: Text(
            'Settings',
            style: AppTextStyle.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            'Account preferences and configuration',
            style: AppTextStyle.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          onTap: () {
            Navigator.pop(context); // Close drawer
            context.go(AppRoutes.settings);
          },
        ),
        const Divider(color: AppColors.border),
        // Profile Option
        ListTile(
          leading: Icon(
            Icons.person_rounded,
            color: AppColors.textPrimary,
            size: Dimensions.iconMedium,
          ),
          title: Text(
            'Profile',
            style: AppTextStyle.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            'View and edit your profile',
            style: AppTextStyle.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          onTap: () {
            Navigator.pop(context); // Close drawer
            context.go(AppRoutes.userProfile);
          },
        ),
        const Divider(color: AppColors.border),
        // Sign Out Option
        ListTile(
          leading: Icon(
            Icons.logout_rounded,
            color: AppColors.error,
            size: Dimensions.iconMedium,
          ),
          title: Text(
            'Sign Out',
            style: AppTextStyle.bodyLarge.copyWith(color: AppColors.error),
          ),
          subtitle: Text(
            'Sign out of your account',
            style: AppTextStyle.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          onTap: () {
            Navigator.pop(context); // Close drawer
            _showSignOutDialog(context);
          },
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Sign Out', style: AppTextStyle.titleMedium),
            content: Text(
              'Are you sure you want to sign out?',
              style: AppTextStyle.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: AppTextStyle.bodyMedium),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Stop audio playback before signing out
                  context.read<AudioPlayerBloc>().add(StopAudioRequested());
                  context.read<AuthBloc>().add(AuthSignOutRequested());
                  context.read<NavigationCubit>().reset();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.onPrimary,
                ),
                child: Text(
                  'Sign Out',
                  style: AppTextStyle.button.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
