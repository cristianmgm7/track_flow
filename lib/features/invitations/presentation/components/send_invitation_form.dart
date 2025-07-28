import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/features/ui/buttons/secondary_button.dart';
import 'package:trackflow/features/ui/inputs/app_text_field.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/invitations/presentation/blocs/invitations_blocs.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// Form component for sending invitations
class SendInvitationForm extends StatefulWidget {
  final ProjectId projectId;
  final VoidCallback? onInvitationSent;
  final VoidCallback? onCancel;

  const SendInvitationForm({
    super.key,
    required this.projectId,
    this.onInvitationSent,
    this.onCancel,
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
  bool _isUserFound = false;
  String? _foundUserName;
  String? _foundUserEmail;

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invite Collaborator',
            style: AppTextStyle.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Dimensions.space16),
          Text(
            'Search for a user by email or invite a new user',
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: Dimensions.space24),

          // Email search field
          AppTextField(
            labelText: 'Email Address',
            hintText: 'Enter email to search for user',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _searchUser(),
            suffixIcon: _isSearching ? Icons.search : Icons.search,
            onSuffixIconPressed: _searchUser,
          ),
          SizedBox(height: Dimensions.space16),

          // User found indicator
          if (_isUserFound) ...[
            Container(
              padding: EdgeInsets.all(Dimensions.space12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: Dimensions.iconSmall,
                  ),
                  SizedBox(width: Dimensions.space8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _foundUserName ?? 'User Found',
                          style: AppTextStyle.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_foundUserEmail != null)
                          Text(
                            _foundUserEmail!,
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
            SizedBox(height: Dimensions.space16),
          ],

          // Role selection
          Text(
            'Role',
            style: AppTextStyle.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Dimensions.space8),
          _buildRoleSelector(),
          SizedBox(height: Dimensions.space16),

          // Message field
          AppTextField(
            labelText: 'Message (Optional)',
            hintText: 'Add a personal message to your invitation',
            controller: _messageController,
            maxLines: 3,
            maxLength: 200,
          ),
          SizedBox(height: Dimensions.space24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: 'Cancel',
                  onPressed: widget.onCancel,
                  icon: Icons.close,
                ),
              ),
              SizedBox(width: Dimensions.space12),
              Expanded(
                child: BlocConsumer<
                  ProjectInvitationActorBloc,
                  InvitationActorState
                >(
                  listener: (context, state) {
                    if (state is SendInvitationSuccess) {
                      widget.onInvitationSent?.call();
                    }
                  },
                  builder: (context, state) {
                    return PrimaryButton(
                      text: 'Send Invitation',
                      onPressed: _canSendInvitation() ? _sendInvitation : null,
                      isLoading: state is InvitationActorLoading,
                      icon: Icons.send,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
      ),
      child: Column(
        children: [
          _buildRoleOption(
            ProjectRole.editor,
            'Editor',
            'Can edit project content and manage collaborators',
            Icons.edit,
          ),
          _buildRoleOption(
            ProjectRole.viewer,
            'Viewer',
            'Can view project content but cannot make changes',
            Icons.visibility,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(
    ProjectRole role,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = _selectedRole == role;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: EdgeInsets.all(Dimensions.space16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: AppColors.border,
              width: role == ProjectRole.editor ? 1 : 0,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child:
                  isSelected
                      ? Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
            ),
            SizedBox(width: Dimensions.space12),
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: Dimensions.iconMedium,
            ),
            SizedBox(width: Dimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.bodyMedium.copyWith(
                      color:
                          isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
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
    );
  }

  Future<void> _searchUser() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      // TODO: Implement user search using FindUserByEmailUseCase
      // For now, simulate a search
      await Future.delayed(const Duration(seconds: 1));

      // Simulate finding a user (replace with actual search)
      if (email.contains('@')) {
        setState(() {
          _isUserFound = true;
          _foundUserName = 'John Doe'; // TODO: Get from search result
          _foundUserEmail = email;
        });
      } else {
        setState(() {
          _isUserFound = false;
          _foundUserName = null;
          _foundUserEmail = null;
        });
      }
    } catch (e) {
      // Handle error
      setState(() {
        _isUserFound = false;
        _foundUserName = null;
        _foundUserEmail = null;
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  bool _canSendInvitation() {
    return _emailController.text.trim().isNotEmpty &&
        _formKey.currentState?.validate() == true;
  }

  void _sendInvitation() {
    if (!_canSendInvitation()) return;

    // TODO: Implement proper invitation sending
    // For now, just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invitation sent to ${_emailController.text.trim()}'),
        backgroundColor: AppColors.success,
      ),
    );

    widget.onInvitationSent?.call();
  }
}
