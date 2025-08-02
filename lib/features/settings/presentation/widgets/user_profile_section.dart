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
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
import 'package:trackflow/features/ui/buttons/secondary_button.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';

class UserProfileSection extends StatelessWidget {
  const UserProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        return Card(
          color: AppColors.surface,
          child: Padding(
            padding: EdgeInsets.all(Dimensions.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                _buildProfileHeader(context, state),
                SizedBox(height: Dimensions.space16),
                
                // Profile Options
                _buildProfileOption(
                  context,
                  icon: Icons.person_rounded,
                  title: 'Profile',
                  subtitle: 'View and edit your profile',
                  onTap: () => context.push(AppRoutes.userProfile),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfileState state) {
    if (state is UserProfileLoaded) {
      final profile = state.profile;
      final avatarProvider = ImageUtils.createSafeImageProvider(
        profile.avatarUrl,
      );

      return Row(
        children: [
          // User Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.grey600,
            backgroundImage: avatarProvider,
            child: avatarProvider == null
                ? Icon(
                    Icons.person,
                    size: 30,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),
          SizedBox(width: Dimensions.space16),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: AppTextStyle.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Dimensions.space4),
                Text(
                  'Account Settings',
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Handle different states
    String displayText;
    Color textColor;
    IconData? actionIcon;
    VoidCallback? onActionTap;

    if (state is UserProfileLoading) {
      displayText = 'Loading...';
      textColor = AppColors.textPrimary;
    } else if (state is UserProfileError) {
      displayText = 'Unable to load profile';
      textColor = AppColors.error;
      actionIcon = Icons.refresh;
      onActionTap = () {
        // Retry loading the profile
        context.read<UserProfileBloc>().add(WatchUserProfile());
      };
    } else if (state is UserProfileInitial) {
      displayText = 'Loading profile...';
      textColor = AppColors.textSecondary;
    } else {
      displayText = 'Profile unavailable';
      textColor = AppColors.textSecondary;
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.grey600,
          child: Icon(
            Icons.person,
            size: 30,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: Dimensions.space16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayText,
                style: AppTextStyle.headlineMedium.copyWith(
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: Dimensions.space4),
              Text(
                'Account Settings',
                style: AppTextStyle.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (actionIcon != null && onActionTap != null)
          SecondaryButton(
            text: 'Retry',
            icon: actionIcon,
            onPressed: onActionTap,
            size: ButtonSize.small,
          ),
      ],
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.textPrimary,
        size: Dimensions.iconMedium,
      ),
      title: Text(
        title,
        style: AppTextStyle.bodyLarge.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyle.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textSecondary,
        size: Dimensions.iconSmall,
      ),
      onTap: onTap,
    );
  }
}