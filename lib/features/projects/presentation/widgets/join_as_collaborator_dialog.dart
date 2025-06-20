import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_event.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_state.dart';
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
            const SnackBar(
              content: Text('Successfully joined the project!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go(AppRoutes.projectDetails, extra: state.project);
        } else if (state is ManageCollaboratorsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BottomSheet(
        backgroundColor: Colors.black,
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
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed:
                                state is ProjectsLoading ? null : _joinProject,
                            child:
                                state is ProjectsLoading
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
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
