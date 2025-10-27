import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/ui/navigation/app_bar.dart';
import 'package:trackflow/features/ui/navigation/app_scaffold.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profiles/user_profiles_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profiles/user_profiles_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profiles/user_profiles_state.dart';
import 'package:trackflow/features/user_profile/presentation/widgets/social_links_display.dart';

class CollaboratorProfileScreen extends StatefulWidget {
  final UserId userId;

  const CollaboratorProfileScreen({super.key, required this.userId});

  @override
  State<CollaboratorProfileScreen> createState() =>
      _CollaboratorProfileScreenState();
}

class _CollaboratorProfileScreenState extends State<CollaboratorProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserProfilesBloc>().add(
      WatchUserProfile(userId: widget.userId.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfilesBloc, UserProfilesState>(
      builder: (context, state) {
        if (state is UserProfilesLoading || state is UserProfilesInitial) {
          return AppScaffold(
            appBar: AppAppBar(title: 'Profile'),
            backgroundColor: AppColors.background,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (state is UserProfileLoaded) {
          final profile = state.profile;
          return Scaffold(
            body: Stack(
              children: [
                // 1. BACKGROUND IMAGE (AVATAR)
                Column(
                  children: [
                    _BackgroundAvatar(profile: profile),
                    Expanded(child: Container()),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                      ),
                    ),
                  ],
                ),
                // 2. SCROLLABLE FOREGROUND CONTENT
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      expandedHeight: Dimensions.space272,  
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Text(
                          profile.name,
                          style: AppTextStyle.headlineLarge,
                        ),
                      ),
                    ),
                    // 3. MAIN CONTENT SECTION
                    SliverToBoxAdapter(

                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: Dimensions.space16,
                              right: Dimensions.space16,
                              top: Dimensions.space12,
                              bottom: Dimensions.space24,
                          ),
                          child: _InfoSection(profile: profile),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return AppScaffold(
          appBar: AppAppBar(title: 'Profile'),
          backgroundColor: AppColors.background,
          body: Center(
            child: Text(
              'Profile unavailable',
              style: AppTextStyle.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BackgroundAvatar extends StatelessWidget {
  const _BackgroundAvatar({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Avatar image or fallback
    if ((profile.avatarLocalPath != null &&
            profile.avatarLocalPath!.isNotEmpty) ||
        (profile.avatarUrl.isNotEmpty)) {
      return Hero(
        tag: profile.avatarUrl,
        child: Container(
          width: screenWidth,
          height: screenWidth,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: (profile.avatarLocalPath != null &&
                      profile.avatarLocalPath!.isNotEmpty)
                  ? FileImage(
                      File(profile.avatarLocalPath!),
                    ) as ImageProvider
                  : NetworkImage(profile.avatarUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: screenWidth,
        height: screenWidth,
        color: AppColors.grey700,
      );
    }
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
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
            // Email
            Text(
              profile.email,
              style: AppTextStyle.bodyLarge.copyWith(
                color: AppColors.textPrimary.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 10),

            // Location
            if (profile.location != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: Dimensions.iconSmall,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    profile.location!,
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Creative Role (Primary)
            if (profile.creativeRole != null) ...[
              Row(
                children: [
                  _buildChip(_roleName(profile.creativeRole)),
                  const SizedBox(width: 8),
                  if (profile.role != null)
                    _buildChip(profile.role!.toShortString()),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Bio/Description
            if (profile.description != null && profile.description!.isNotEmpty) ...[
              Text(
                'About',
                style: AppTextStyle.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                profile.description!,
                style: AppTextStyle.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],

            // Roles (Multiple)
            if (profile.roles != null && profile.roles!.isNotEmpty) ...[
              Text(
                'Roles',
                style: AppTextStyle.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.roles!.map((role) => _buildChip(role)).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Genres
            if (profile.genres != null && profile.genres!.isNotEmpty) ...[
              Text(
                'Genres',
                style: AppTextStyle.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.genres!.map((genre) => _buildChip(genre)).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Skills
            if (profile.skills != null && profile.skills!.isNotEmpty) ...[
              Text(
                'Skills',
                style: AppTextStyle.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.skills!.map((skill) => _buildChip(skill)).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Social Links
            if (profile.socialLinks != null && profile.socialLinks!.isNotEmpty) ...[
              Text(
                'Connect',
                style: AppTextStyle.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SocialLinksDisplay(socialLinks: profile.socialLinks!),
              const SizedBox(height: 16),
            ],

            // Website & Linktree
            if (profile.websiteUrl != null || profile.linktreeUrl != null) ...[
              if (profile.websiteUrl != null)
                _buildLinkRow(
                  icon: Icons.language,
                  label: 'Website',
                  url: profile.websiteUrl!,
                ),
              if (profile.linktreeUrl != null) ...[
                const SizedBox(height: 8),
                _buildLinkRow(
                  icon: Icons.link,
                  label: 'Linktree',
                  url: profile.linktreeUrl!,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
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

  Widget _buildLinkRow({
    required IconData icon,
    required String label,
    required String url,
  }) {
    return Row(
      children: [
        Icon(icon, size: Dimensions.iconSmall, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyle.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            url,
            style: AppTextStyle.bodySmall.copyWith(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _roleName(CreativeRole? role) {
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
