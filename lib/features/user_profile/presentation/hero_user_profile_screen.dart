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
    context.read<UserProfileBloc>().add(
      WatchUserProfile(userId: widget.userId.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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

            return CustomScrollView(
              slivers: [
                // Header Sliver: background image + centered name
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height * 0.35,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppColors.background,
                  iconTheme: const IconThemeData(color: AppColors.textPrimary),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background image
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:
                                  avatarProvider ??
                                  const AssetImage(
                                    'assets/images/default_profile_bg.jpg',
                                  ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Name at bottom left
                        Positioned(
                          left: 24,
                          bottom: 24,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background.withOpacity(0.7),
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
                                    color: AppColors.background.withOpacity(
                                      0.7,
                                    ),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Info Section below header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: _buildInfoSection(context, profile),
                  ),
                ),
              ],
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
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
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
