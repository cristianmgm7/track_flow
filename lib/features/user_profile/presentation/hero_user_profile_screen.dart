import 'package:flutter/material.dart';
// import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profiles/user_profiles_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profiles/user_profiles_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profiles/user_profiles_state.dart';
import 'package:trackflow/features/user_profile/presentation/edit_profile_dialog.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_state.dart';

class HeroUserProfileScreen extends StatefulWidget {
  final UserId userId;

  const HeroUserProfileScreen({super.key, required this.userId});

  @override
  State<HeroUserProfileScreen> createState() => _HeroUserProfileScreenState();
}

class _HeroUserProfileScreenState extends State<HeroUserProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    AppLogger.info(
      'HeroUserProfileScreen: Loading user profile for userId: ${widget.userId.value}',
      tag: 'HERO_USER_PROFILE_SCREEN',
    );

    context.read<UserProfilesBloc>().add(
      WatchUserProfile(userId: widget.userId.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profile'), centerTitle: true),
      backgroundColor: AppColors.background,
      body: BlocListener<AppFlowBloc, AppFlowState>(
        listener: (context, appFlowState) {
          // If user becomes unauthenticated, show error
          if (appFlowState is AppFlowUnauthenticated) {
            AppLogger.warning(
              'HeroUserProfileScreen: User became unauthenticated',
              tag: 'HERO_USER_PROFILE_SCREEN',
            );
            // The UI will handle this through the UserProfileError state
          }
        },
        child: BlocBuilder<UserProfilesBloc, UserProfilesState>(
          builder: (context, state) {
            if (state is UserProfilesLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (state is UserProfileLoaded) {
              final profile = state.profile;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 240,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Lightweight gradient header to avoid heavy image decode
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF1F1F1F), Color(0xFF121212)],
                              ),
                            ),
                          ),
                          // Name at bottom left
                          Positioned(
                            left: 24,
                            bottom: 24,
                            right: 24,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background.withValues(
                                  alpha: 0.7,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                profile.name,
                                style: AppTextStyle.displayMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.background.withValues(
                                        alpha: 0.7,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: _buildInfoSection(context, profile),
                    ),
                  ],
                ),
              );
            }
            if (state is UserProfilesError) {
              return _buildErrorState();
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, profile) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      elevation: 2,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email
                      Text(
                        profile.email,
                        style: AppTextStyle.bodyLarge.copyWith(
                          color: AppColors.textPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Roles
                      Row(
                        children: [
                          if (profile.creativeRole != null) ...[
                            _buildGlassChip(
                              _getCreativeRoleName(profile.creativeRole),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (profile.role != null)
                            _buildGlassChip(profile.role!.toShortString()),
                        ],
                      ),
                    ],
                  ),
                ),
                // Edit button (top right)
                _buildPencilEditButton(context, profile),
              ],
            ),
            const SizedBox(height: 14),
            // Account Information
            _buildAccountInfoSection(profile),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.space12,
        vertical: Dimensions.space6,
      ),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(
          color: AppColors.textPrimary.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyle.labelMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPencilEditButton(BuildContext context, profile) {
    return Padding(
      padding: EdgeInsets.only(right: Dimensions.space8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                useRootNavigator: false,
                builder: (context) => EditProfileDialog(profile: profile),
              );
            },
            icon: Icon(
              Icons.edit,
              color: AppColors.textPrimary,
              size: Dimensions.iconMedium,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfoSection(profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider line
        Container(
          height: 1,
          color: AppColors.textPrimary.withValues(alpha: 0.1),
          margin: EdgeInsets.symmetric(vertical: Dimensions.space12),
        ),

        // Account info rows
        _buildGlassInfoRow('User ID', profile.id.value, Icons.fingerprint),
        SizedBox(height: Dimensions.space12),
        _buildGlassInfoRow(
          'Member Since',
          profile.createdAt.toLocal().toString().split(' ')[0],
          Icons.calendar_today,
        ),
      ],
    );
  }

  Widget _buildGlassInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: Dimensions.iconSmall,
          color: AppColors.textPrimary.withValues(alpha: 0.6),
        ),
        SizedBox(width: Dimensions.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyle.labelMedium.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: Dimensions.space4),
              Text(
                value,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ],
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
            'Please check your connection and try again',
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Dimensions.space16),
          ElevatedButton(
            onPressed: () {
              AppLogger.info(
                'HeroUserProfileScreen: Retrying profile load',
                tag: 'HERO_USER_PROFILE_SCREEN',
              );
              _loadUserProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            child: const Text('Retry'),
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
