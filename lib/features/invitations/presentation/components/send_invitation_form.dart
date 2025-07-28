import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/invitations/domain/value_objects/send_invitation_params.dart';
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart';
import 'package:trackflow/features/invitations/presentation/blocs/events/invitation_events.dart';
import 'package:trackflow/features/invitations/presentation/blocs/states/invitation_states.dart';
import 'package:trackflow/features/ui/forms/app_form_field.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/features/ui/buttons/secondary_button.dart';
import 'package:trackflow/features/ui/feedback/app_feedback_system.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class SendInvitationForm extends StatefulWidget {
  final ProjectId projectId;
  final String? initialEmail;

  const SendInvitationForm({
    super.key,
    required this.projectId,
    this.initialEmail,
  });

  @override
  State<SendInvitationForm> createState() => _SendInvitationFormState();
}

class _SendInvitationFormState extends State<SendInvitationForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  ProjectRole _selectedRole = ProjectRole.editor;
  bool _isSearching = false;
  UserProfile? _foundUser;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
      _searchUser(widget.initialEmail!);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _searchUser(String email) async {
    if (email.isEmpty) {
      setState(() {
        _foundUser = null;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _foundUser = null;
    });

    // TODO: Implement user search using FindUserByEmailUseCase
    // For now, simulate search
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isSearching = false;
      // TODO: Set _foundUser based on actual search result
    });
  }

  Future<void> _sendInvitation() async {
    if (!_formKey.currentState!.validate()) return;

    final params = SendInvitationParams(
      projectId: widget.projectId,
      invitedUserId: _foundUser?.id, // null for new users
      invitedEmail: _emailController.text.trim(),
      proposedRole: _selectedRole,
      message: _messageController.text.trim(),
    );

    context.read<ProjectInvitationActorBloc>().add(SendInvitation(params));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectInvitationActorBloc, InvitationActorState>(
      listener: (context, state) {
        if (state is InvitationActorSuccess) {
          Navigator.of(context).pop();
          AppFeedbackSystem.showSnackBar(
            context,
            message: 'Invitation sent successfully!',
            type: FeedbackType.success,
          );
        } else if (state is InvitationActorError) {
          AppFeedbackSystem.showSnackBar(
            context,
            message: 'Failed to send invitation: ${state.message}',
            type: FeedbackType.error,
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Email Field
            AppFormField(
              label: 'Email Address',
              hint: 'Enter collaborator\'s email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              isRequired: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _searchUser(value);
                }
              },
              suffixIcon:
                  _isSearching
                      ? SizedBox(
                        width: Dimensions.iconMedium,
                        height: Dimensions.iconMedium,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      )
                      : _foundUser != null
                      ? Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: Dimensions.iconMedium,
                      )
                      : null,
            ),

            // User Found Indicator
            if (_foundUser != null) ...[
              SizedBox(height: Dimensions.space12),
              Container(
                padding: EdgeInsets.all(Dimensions.space12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: AppColors.success,
                      size: Dimensions.iconMedium,
                    ),
                    SizedBox(width: Dimensions.space8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _foundUser!.name,
                            style: AppTextStyle.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Existing user found',
                            style: AppTextStyle.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: Dimensions.space16),

            // Role Selection
            Text('Role', style: AppTextStyle.labelMedium),
            SizedBox(height: Dimensions.space8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
              ),
              child: Column(
                children: [
                  _buildRoleOption(ProjectRole.owner),
                  _buildRoleOption(ProjectRole.admin),
                  _buildRoleOption(ProjectRole.editor),
                  _buildRoleOption(ProjectRole.viewer),
                ],
              ),
            ),

            SizedBox(height: Dimensions.space16),

            // Message Field
            AppFormField(
              label: 'Message (Optional)',
              hint: 'Add a personal message to your invitation',
              controller: _messageController,
              maxLines: 3,
              maxLength: 200,
            ),

            SizedBox(height: Dimensions.space24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                SizedBox(width: Dimensions.space12),
                Expanded(
                  child: BlocBuilder<
                    ProjectInvitationActorBloc,
                    InvitationActorState
                  >(
                    builder: (context, state) {
                      return PrimaryButton(
                        text: 'Send Invitation',
                        onPressed: _sendInvitation,
                        isLoading: state is InvitationActorLoading,
                        isDisabled: state is InvitationActorLoading,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(ProjectRole role) {
    final isSelected = _selectedRole == role;

    return RadioListTile<ProjectRole>(
      title: Text(_getRoleDisplayName(role), style: AppTextStyle.bodyMedium),
      subtitle: Text(
        _getRoleDescription(role),
        style: AppTextStyle.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      value: role,
      groupValue: _selectedRole,
      onChanged: (value) {
        setState(() {
          _selectedRole = value!;
        });
      },
      activeColor: AppColors.primary,
    );
  }

  String _getRoleDisplayName(ProjectRole role) {
    switch (role.value) {
      case ProjectRoleType.owner:
        return 'Owner';
      case ProjectRoleType.admin:
        return 'Admin';
      case ProjectRoleType.editor:
        return 'Editor';
      case ProjectRoleType.viewer:
        return 'Viewer';
    }
  }

  String _getRoleDescription(ProjectRole role) {
    switch (role.value) {
      case ProjectRoleType.owner:
        return 'Full control over the project';
      case ProjectRoleType.admin:
        return 'Can manage collaborators and settings';
      case ProjectRoleType.editor:
        return 'Can edit and contribute to the project';
      case ProjectRoleType.viewer:
        return 'Can only view the project';
    }
  }
}
