import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';
import 'package:trackflow/features/user_profile/presentation/edit_profile_dialog.dart';
import 'package:trackflow/core/widgets/user_avatar.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';

class ProfileInformation extends StatefulWidget {
  const ProfileInformation({super.key});

  @override
  State<ProfileInformation> createState() => _ProfileInformationState();
}

class _ProfileInformationState extends State<ProfileInformation> {
  @override
  void initState() {
    super.initState();
    context.read<CurrentUserBloc>().add(WatchCurrentUserProfile());
  }

  void _onEditProfile(BuildContext context, UserProfile profile) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => EditProfileDialog(profile: profile),
    );
  }

  String _getCreativeRoleDisplayName(CreativeRole role) {
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentUserBloc, CurrentUserState>(
      builder: (context, state) {
        if (state is CurrentUserLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (state is CurrentUserLoaded) {
          final profile = state.profile;

          return Card(
            margin: EdgeInsets.all(Dimensions.space16),
            child: Padding(
              padding: EdgeInsets.all(Dimensions.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Profile Avatar: prefer local cache, else remote URL
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: (profile.avatarLocalPath != null &&
                                profile.avatarLocalPath!.isNotEmpty)
                            ? UserAvatar(
                              imageUrl: profile.avatarLocalPath!,
                              size: 60,
                              fallback: Icon(
                                Icons.person,
                                size: 30,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            )
                            : UserAvatar(
                              imageUrl: profile.avatarUrl,
                              size: 60,
                              fallback: Icon(
                                Icons.person,
                                size: 30,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                      ),
                      SizedBox(width: Dimensions.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style: AppTextStyle.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: Dimensions.space4),
                            Text(
                              profile.email,
                              style: AppTextStyle.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (profile.creativeRole != null) ...[
                              SizedBox(height: Dimensions.space4),
                              Text(
                                _getCreativeRoleDisplayName(
                                  profile.creativeRole!,
                                ),
                                style: AppTextStyle.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _onEditProfile(context, profile),
                        icon: Icon(Icons.edit, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // User ID display removed for privacy
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => _onEditProfile(context, profile),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      "Edit Profile",
                      style: AppTextStyle.button.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is CurrentUserError) {
          return Center(
            child: Text(
              "An error occurred.",
              style: AppTextStyle.bodyLarge.copyWith(color: AppColors.error),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
