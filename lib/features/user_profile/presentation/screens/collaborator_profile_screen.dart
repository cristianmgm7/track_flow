import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/utils/image_utils.dart';
import 'package:trackflow/features/ui/navigation/app_bar.dart';
import 'package:trackflow/features/ui/navigation/app_scaffold.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_states.dart';

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
    context.read<UserProfileBloc>().add(
      WatchAnyUserProfile(widget.userId.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(title: 'Profile'),
      backgroundColor: AppColors.background,
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          if (state is UserProfileLoading || state is UserProfileInitial) {
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
              child: ImageUtils.createAdaptiveImageWidget(
                imagePath:
                    (profile.avatarLocalPath != null &&
                            profile.avatarLocalPath!.isNotEmpty)
                        ? profile.avatarLocalPath!
                        : profile.avatarUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                fallbackWidget: Container(color: AppColors.grey700),
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
            // Roles
            Row(
              children: [
                if (profile.creativeRole != null) ...[
                  _buildChip(_roleName(profile.creativeRole)),
                  const SizedBox(width: 8),
                ],
                if (profile.role != null)
                  _buildChip(profile.role!.toShortString()),
              ],
            ),
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
