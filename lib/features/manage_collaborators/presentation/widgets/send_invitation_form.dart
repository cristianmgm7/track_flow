import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_event.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_state.dart';
import 'package:trackflow/features/ui/forms/app_form_field.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/features/ui/feedback/app_feedback_system.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/manage_collaborators/presentation/widgets/search_error_indicator.dart';
import 'package:trackflow/features/manage_collaborators/presentation/widgets/user_found_indicator.dart';
import 'package:trackflow/features/manage_collaborators/presentation/widgets/new_user_indicator.dart';

class SendInvitationForm extends StatefulWidget {
  final ProjectId projectId;

  const SendInvitationForm({super.key, required this.projectId});

  @override
  State<SendInvitationForm> createState() => _SendInvitationFormState();
}

class _SendInvitationFormState extends State<SendInvitationForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _searchUser(String email) {
    if (email.isEmpty) {
      context.read<ManageCollaboratorsBloc>().add(ClearUserSearch());
    } else {
      context.read<ManageCollaboratorsBloc>().add(SearchUserByEmail(email));
    }
  }

  void _addCollaborator(ManageCollaboratorsState state) {
    if (!_formKey.currentState!.validate()) return;

    // Only proceed if we have a successful search result or valid email
    if (state is! UserSearchSuccess && _emailController.text.isEmpty) {
      AppFeedbackSystem.showSnackBar(
        context,
        message: 'Please enter a valid email first',
        type: FeedbackType.error,
      );
      return;
    }

    // Add collaborator directly with default editor role
    context.read<ManageCollaboratorsBloc>().add(
      AddCollaboratorByEmail(
        projectId: widget.projectId,
        email: _emailController.text.trim(),
        role: ProjectRole.editor, // Default role
      ),
    );
  }

  Widget? _buildSuffixIcon(ManageCollaboratorsState state) {
    if (state is UserSearchLoading) {
      return SizedBox(
        width: Dimensions.iconMedium,
        height: Dimensions.iconMedium,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    } else if (state is UserSearchSuccess && state.user != null) {
      return Icon(
        Icons.check_circle,
        color: AppColors.success,
        size: Dimensions.iconMedium,
      );
    }
    return null;
  }

  bool _canAddCollaborator(ManageCollaboratorsState state) {
    return (state is UserSearchSuccess) ||
        (_emailController.text.isNotEmpty &&
            state is! UserSearchLoading &&
            state is! UserSearchError &&
            state is! ManageCollaboratorsLoading);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManageCollaboratorsBloc, ManageCollaboratorsState>(
      listener: (context, state) {
        if (state is AddCollaboratorByEmailSuccess) {
          Navigator.of(context).pop();
          AppFeedbackSystem.showSnackBar(
            context,
            message: state.message,
            type: FeedbackType.success,
          );
        } else if (state is ManageCollaboratorsError) {
          AppFeedbackSystem.showSnackBar(
            context,
            message: 'Error adding collaborator: ${state.message}',
            type: FeedbackType.error,
          );
        }
      },
      child: BlocBuilder<ManageCollaboratorsBloc, ManageCollaboratorsState>(
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Email Field with Real Search
                AppFormField(
                  label: 'Email of collaborator',
                  hint: 'Search by email...',
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
                    _searchUser(value);
                  },
                  suffixIcon: _buildSuffixIcon(state),
                ),

                // Search Error
                SearchErrorIndicator(state: state),

                // User Found Indicator
                UserFoundIndicator(state: state),

                // New User Indicator
                NewUserIndicator(email: _emailController.text, state: state),

                SizedBox(height: Dimensions.space24),

                // Action Button
                BlocBuilder<ManageCollaboratorsBloc, ManageCollaboratorsState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      text: 'Add Collaborator',
                      onPressed:
                          _canAddCollaborator(state)
                              ? () => _addCollaborator(state)
                              : null,
                      isLoading: state is ManageCollaboratorsLoading,
                      isDisabled: state is ManageCollaboratorsLoading,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
