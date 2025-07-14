import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_event.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_state.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_state.dart';

class JoinAsCollaboratorDialog extends StatefulWidget {
  const JoinAsCollaboratorDialog({super.key});

  @override
  State<JoinAsCollaboratorDialog> createState() =>
      _JoinAsCollaboratorDialogState();
}

class _JoinAsCollaboratorDialogState extends State<JoinAsCollaboratorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _projectIdController;

  @override
  void initState() {
    super.initState();
    _projectIdController = TextEditingController();
  }

  @override
  void dispose() {
    _projectIdController.dispose();
    super.dispose();
  }

  void _joinProject() {
    if (!_formKey.currentState!.validate()) return;
    final projectId = UniqueId.fromString(_projectIdController.text);
    context.read<ManageCollaboratorsBloc>().add(
      JoinProjectWithIdRequested(projectId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManageCollaboratorsBloc, ManageCollaboratorsState>(
      listener: (context, state) {
        if (state is JoinProjectSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Successfully joined the project!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go(AppRoutes.projectDetails, extra: state.project);
        } else if (state is ManageCollaboratorsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BottomSheet(
        backgroundColor: Theme.of(context).colorScheme.surface,
        onClosing: () => Navigator.of(context).pop(),
        builder:
            (context) =>
                BlocBuilder<ManageCollaboratorsBloc, ManageCollaboratorsState>(
                  builder: (context, state) {
                    return Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _projectIdController,
                            decoration: const InputDecoration(
                              labelText: 'Project ID',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a project ID';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: Dimensions.space16),
                          ElevatedButton(
                            onPressed:
                                state is ProjectsLoading ? null : _joinProject,
                            child:
                                state is ProjectsLoading
                                    ? SizedBox(
                                      width: Dimensions.iconMedium,
                                      height: Dimensions.iconMedium,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text('Join Project'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
