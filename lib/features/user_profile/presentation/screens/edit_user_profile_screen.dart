import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_icons.dart';
import 'package:trackflow/features/ui/navigation/app_scaffold.dart';
import 'package:trackflow/features/ui/navigation/app_bar.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';
import 'package:trackflow/features/user_profile/presentation/components/edit_profile_form.dart';
import 'package:trackflow/features/user_profile/presentation/widgets/profile_preview_sheet.dart';

class EditUserProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditUserProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditUserProfileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  final GlobalKey<EditProfileFormState> _formKey =
      GlobalKey<EditProfileFormState>();

  bool _isLoading = false;

  void _handleSubmit(UserProfile updatedProfile) {
    setState(() => _isLoading = true);
    context.read<CurrentUserBloc>().add(UpdateCurrentUserProfile(updatedProfile));
  }

  void _showPreview() {
    final profile = _formKey.currentState?.getUpdatedProfile();
    if (profile != null) {
      showProfilePreview(context, profile);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CurrentUserBloc, CurrentUserState>(
      listener: (context, state) {
        if (state is CurrentUserSaved) {
          setState(() => _isLoading = false);
          _showSuccess('Profile updated successfully!');
          context.pop();
        } else if (state is CurrentUserError) {
          setState(() => _isLoading = false);
          _showError('Failed to update profile. Please try again.');
        }
      },
      child: AppScaffold(
        appBar: AppAppBar(
          title: 'Edit Profile',
          actions: [
            AppIconButton(
              icon: AppIcons.preview,
              onPressed: _isLoading ? null : _showPreview,
            ),
          ],
          backgroundColor: AppColors.background.withValues(alpha: 0.9),
        ),
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            
            padding: EdgeInsets.symmetric(horizontal: Dimensions.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                EditProfileForm(
                  key: _formKey,
                  initialProfile: widget.profile,
                  onSubmit: _handleSubmit,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Save Changes',
                  onPressed: _isLoading
                      ? null
                      : () {
                          _formKey.currentState?.submit();
                        },
                  isLoading: _isLoading,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
