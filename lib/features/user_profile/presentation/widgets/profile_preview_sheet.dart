import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/ui/modals/app_form_sheet.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/presentation/widgets/social_links_display.dart';
import 'package:trackflow/core/widgets/user_avatar.dart';

void showProfilePreview(BuildContext context, UserProfile profile) {
  showAppFormSheet(
    context: context,
    title: 'Profile Preview',
    initialChildSize: 0.9,
    maxChildSize: 0.95,
    child: ProfilePreviewContent(profile: profile),
  );
}

class ProfilePreviewContent extends StatelessWidget {
  final UserProfile profile;

  const ProfilePreviewContent({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar
          Center(
            child: Column(
              children: [
                UserAvatar(
                  imageUrl: profile.avatarUrl,
                  size: 100,
                  fallback: Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: Dimensions.space16),
                Text(
                  profile.name,
                  style: AppTextStyle.displaySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (profile.location != null) ...[
                  SizedBox(height: Dimensions.space8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: Dimensions.iconSmall,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: Dimensions.space4),
                      Text(
                        profile.location!,
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (profile.verified) ...[
                  SizedBox(height: Dimensions.space8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.space12,
                      vertical: Dimensions.space4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: Dimensions.iconSmall,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: Dimensions.space4),
                        Text(
                          'Verified',
                          style: AppTextStyle.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: Dimensions.space24),

          // Bio
          if (profile.description != null && profile.description!.isNotEmpty) ...[
            Text(
              'About',
              style: AppTextStyle.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Dimensions.space8),
            Text(
              profile.description!,
              style: AppTextStyle.bodyMedium,
            ),
            SizedBox(height: Dimensions.space24),
          ],

          // Roles
          if (profile.roles != null && profile.roles!.isNotEmpty) ...[
            Text(
              'Roles',
              style: AppTextStyle.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Dimensions.space8),
            Wrap(
              spacing: Dimensions.space8,
              runSpacing: Dimensions.space8,
              children: profile.roles!.map((role) {
                return _buildChip(role);
              }).toList(),
            ),
            SizedBox(height: Dimensions.space24),
          ],

          // Genres
          if (profile.genres != null && profile.genres!.isNotEmpty) ...[
            Text(
              'Genres',
              style: AppTextStyle.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Dimensions.space8),
            Wrap(
              spacing: Dimensions.space8,
              runSpacing: Dimensions.space8,
              children: profile.genres!.map((genre) {
                return _buildChip(genre);
              }).toList(),
            ),
            SizedBox(height: Dimensions.space24),
          ],

          // Skills
          if (profile.skills != null && profile.skills!.isNotEmpty) ...[
            Text(
              'Skills',
              style: AppTextStyle.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Dimensions.space8),
            Wrap(
              spacing: Dimensions.space8,
              runSpacing: Dimensions.space8,
              children: profile.skills!.map((skill) {
                return _buildChip(skill);
              }).toList(),
            ),
            SizedBox(height: Dimensions.space24),
          ],

          // Social Links
          if (profile.socialLinks != null && profile.socialLinks!.isNotEmpty) ...[
            Text(
              'Connect',
              style: AppTextStyle.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Dimensions.space12),
            SocialLinksDisplay(socialLinks: profile.socialLinks!),
            SizedBox(height: Dimensions.space24),
          ],

          // Website & Linktree
          if (profile.websiteUrl != null || profile.linktreeUrl != null) ...[
            if (profile.websiteUrl != null)
              _buildLinkTile(
                icon: Icons.language,
                label: 'Website',
                url: profile.websiteUrl!,
              ),
            if (profile.linktreeUrl != null)
              _buildLinkTile(
                icon: Icons.link,
                label: 'Linktree',
                url: profile.linktreeUrl!,
              ),
          ],
        ],
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
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyle.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String label,
    required String url,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.space8),
      child: Row(
        children: [
          Icon(icon, size: Dimensions.iconSmall, color: AppColors.textSecondary),
          SizedBox(width: Dimensions.space8),
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
      ),
    );
  }
}
