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
    return AppScaffold(
      appBar: AppAppBar(title: 'Profile'),
      backgroundColor: AppColors.background,
      body: BlocBuilder<UserProfilesBloc, UserProfilesState>(
        builder: (context, state) {
          if (state is UserProfilesLoading || state is UserProfilesInitial) {
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
                  _HeaderBackground(profile: profile),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: _InfoSection(profile: profile),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Text(
              'Profile unavailable',
              style: AppTextStyle.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background photo (avatar) stretched to cover
          if ((profile.avatarLocalPath != null &&
                  profile.avatarLocalPath!.isNotEmpty) ||
              (profile.avatarUrl.isNotEmpty))
            Positioned.fill(
              child: Hero(
                tag: profile.avatarUrl,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
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
                  child: Container(color: AppColors.grey700.withValues(alpha: 0)),
                ),
              ),
            )
          else
            Container(color: AppColors.grey700),

          // Gradient overlay for readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 0.2),
                    AppColors.background.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),

          // Name overlaid at bottom
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Text(
              profile.name,
              style: AppTextStyle.displayMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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
