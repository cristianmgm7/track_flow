import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';
import 'package:trackflow/features/user_profile/presentation/edit_profile_dialog.dart';
import 'package:trackflow/core/utils/image_utils.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class UserProfileScreen extends StatefulWidget {
  final UserId userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserProfileBloc>().add(
      WatchUserProfile(userId: widget.userId.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyle.titleMedium),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          if (state is UserProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is UserProfileLoaded) {
            final profile = state.profile;
            final avatarProvider = ImageUtils.createSafeImageProvider(
              profile.avatarUrl,
            );

            return SingleChildScrollView(
              padding: EdgeInsets.all(Dimensions.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Header
                  _buildProfileHeader(profile, avatarProvider),

                  SizedBox(height: Dimensions.space32),

                  // Profile Information Cards
                  _buildProfileInfo(profile),

                  SizedBox(height: Dimensions.space32),

                  // Edit Profile Button
                  _buildEditButton(context, profile),
                ],
              ),
            );
          }
          if (state is UserProfileError) {
            return _buildErrorState();
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProfileHeader(profile, ImageProvider? avatarProvider) {
    return Column(
      children: [
        // Avatar
        CircleAvatar(
          radius: 64,
          backgroundColor: AppColors.grey600,
          backgroundImage: avatarProvider,
          child:
              avatarProvider == null
                  ? Icon(Icons.person, size: 64, color: AppColors.textSecondary)
                  : null,
        ),
        SizedBox(height: Dimensions.space20),

        // Name
        Text(
          profile.name,
          style: AppTextStyle.headlineLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: Dimensions.space8),

        // Email
        Text(
          profile.email,
          style: AppTextStyle.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileInfo(profile) {
    return Column(
      children: [
        // Roles Section
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(Dimensions.space16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Roles',
                style: AppTextStyle.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: Dimensions.space16),

              // Creative Role
              _buildInfoRow(
                'Creative Role',
                _getCreativeRoleName(profile.creativeRole),
                Icons.brush,
              ),

              SizedBox(height: Dimensions.space12),

              // Project Role
              _buildInfoRow(
                'Project Role',
                profile.role?.toShortString() ?? 'Not specified',
                Icons.work,
              ),
            ],
          ),
        ),

        SizedBox(height: Dimensions.space16),

        // Account Information
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(Dimensions.space16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Information',
                style: AppTextStyle.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: Dimensions.space16),

              // User ID
              _buildInfoRow('User ID', profile.id.value, Icons.fingerprint),

              SizedBox(height: Dimensions.space12),

              // Join Date
              _buildInfoRow(
                'Member Since',
                profile.createdAt.toLocal().toString().split(' ')[0],
                Icons.calendar_today,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: Dimensions.iconSmall, color: AppColors.textSecondary),
        SizedBox(width: Dimensions.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyle.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: Dimensions.space4),
              Text(
                value,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context, profile) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            useRootNavigator: false,
            builder: (context) => EditProfileDialog(profile: profile),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: EdgeInsets.symmetric(vertical: Dimensions.space16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
          ),
        ),
        child: Text(
          'Edit Profile',
          style: AppTextStyle.button.copyWith(color: AppColors.onPrimary),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          SizedBox(height: Dimensions.space16),
          Text(
            'Unable to load profile',
            style: AppTextStyle.titleMedium.copyWith(color: AppColors.error),
          ),
          SizedBox(height: Dimensions.space8),
          Text(
            'Please try again later',
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getCreativeRoleName(CreativeRole? role) {
    if (role == null) return 'Not specified';

    switch (role) {
      case CreativeRole.producer:
        return 'Producer';
      case CreativeRole.composer:
        return 'Composer';
      case CreativeRole.mixingEngineer:
        return 'Mixing Engineer';
      case CreativeRole.masteringEngineer:
        return 'Mastering Engineer';
      case CreativeRole.vocalist:
        return 'Vocalist';
      case CreativeRole.instrumentalist:
        return 'Instrumentalist';
      case CreativeRole.other:
        return 'Other';
    }
  }
}
