import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/invitations/presentation/blocs/actor/project_invitation_actor_bloc.dart';
import 'package:trackflow/features/invitations/presentation/blocs/events/invitation_events.dart';
import 'package:trackflow/features/invitations/presentation/blocs/states/invitation_states.dart';
import 'package:trackflow/features/ui/forms/app_form_field.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/features/ui/buttons/secondary_button.dart';
import 'package:trackflow/features/ui/feedback/app_feedback_system.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/invitations/domain/value_objects/send_invitation_params.dart';

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
      context.read<ProjectInvitationActorBloc>().add(const ClearUserSearch());
    } else {
      context.read<ProjectInvitationActorBloc>().add(SearchUserByEmail(email));
    }
  }

  void _sendInvitation(InvitationActorState state) {
    if (!_formKey.currentState!.validate()) return;
    
    // Only proceed if we have a successful search result or new user
    if (state is! UserSearchSuccess && _emailController.text.isEmpty) {
      AppFeedbackSystem.showSnackBar(
        context,
        message: 'Please enter a valid email first',
        type: FeedbackType.error,
      );
      return;
    }

    // Send invitation with default values
    final params = SendInvitationParams(
      projectId: widget.projectId,
      invitedEmail: _emailController.text.trim(),
      proposedRole: ProjectRole.editor, // Default role
      message:
          'I want to collaborate with you in this project', // Default message
      expirationDuration: const Duration(days: 30),
    );

    context.read<ProjectInvitationActorBloc>().add(SendInvitation(params));
  }

  Widget? _buildSuffixIcon(InvitationActorState state) {
    if (state is UserSearchLoading) {
      return SizedBox(
        width: Dimensions.iconMedium,
        height: Dimensions.iconMedium,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.primary,
          ),
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

  Widget _buildSearchError(InvitationActorState state) {
    if (state is UserSearchError) {
      return Column(
        children: [
          SizedBox(height: Dimensions.space8),
          Container(
            padding: EdgeInsets.all(Dimensions.space8),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: Dimensions.iconSmall,
                ),
                SizedBox(width: Dimensions.space8),
                Expanded(
                  child: Text(
                    state.message,
                    style: AppTextStyle.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildUserFoundIndicator(InvitationActorState state) {
    if (state is UserSearchSuccess && state.user != null) {
      final user = state.user!;
      return Column(
        children: [
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
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(
                    user.name.isNotEmpty
                        ? user.name[0].toUpperCase()
                        : 'U',
                    style: AppTextStyle.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: Dimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: AppTextStyle.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user.email,
                        style: AppTextStyle.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Usuario existente encontrado',
                        style: AppTextStyle.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildNewUserIndicator(InvitationActorState state) {
    if (_emailController.text.isNotEmpty &&
        state is UserSearchSuccess &&
        state.user == null) {
      return Column(
        children: [
          SizedBox(height: Dimensions.space12),
          Container(
            padding: EdgeInsets.all(Dimensions.space12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_add,
                  color: AppColors.info,
                  size: Dimensions.iconMedium,
                ),
                SizedBox(width: Dimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nuevo usuario',
                        style: AppTextStyle.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                      Text(
                        'Se enviará un enlace mágico para que se registre',
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
      );
    }
    return const SizedBox.shrink();
  }

  bool _canSendInvitation(InvitationActorState state) {
    return (state is UserSearchSuccess) ||
           (_emailController.text.isNotEmpty &&
            state is! UserSearchLoading &&
            state is! UserSearchError);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectInvitationActorBloc, InvitationActorState>(
      listener: (context, state) {
        if (state is SendInvitationSuccess) {
          Navigator.of(context).pop();
          AppFeedbackSystem.showSnackBar(
            context,
            message: '¡Invitación enviada exitosamente!',
            type: FeedbackType.success,
          );
        } else if (state is InvitationActorError && state is! UserSearchError) {
          AppFeedbackSystem.showSnackBar(
            context,
            message: 'Error al enviar invitación: ${state.message}',
            type: FeedbackType.error,
          );
        }
      },
      child: BlocBuilder<ProjectInvitationActorBloc, InvitationActorState>(
        builder: (context, state) {
          return Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Email Field with Real Search
            AppFormField(
              label: 'Email del colaborador',
              hint: 'Buscar por email...',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              isRequired: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El email es requerido';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Por favor ingresa un email válido';
                }
                return null;
              },
              onChanged: (value) {
                _searchUser(value);
              },
              suffixIcon: _buildSuffixIcon(state),
            ),

            // Search Error
            _buildSearchError(state),

            // User Found Indicator
            _buildUserFoundIndicator(state),

            // New User Indicator
            _buildNewUserIndicator(state),

            SizedBox(height: Dimensions.space24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Cancelar',
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
                        text: 'Enviar Invitación',
                        onPressed: _canSendInvitation(state)
                                ? () => _sendInvitation(state)
                                : null,
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
      );
        },
      ),
    );
  }
}
