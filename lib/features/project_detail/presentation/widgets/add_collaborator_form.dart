import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_event.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_state.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

class AddCollaboratorForm extends StatefulWidget {
  final Project project;
  const AddCollaboratorForm({super.key, required this.project});

  @override
  State<AddCollaboratorForm> createState() => _AddCollaboratorFormState();
}

class _AddCollaboratorFormState extends State<AddCollaboratorForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ManageCollaboratorsBloc>().add(
        AddCollaborator(
          projectId: widget.project.id,
          collaboratorId: UserId.fromUniqueString(_idController.text.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManageCollaboratorsBloc, ManageCollaboratorsState>(
      listener: (context, state) {
        if (state is AddCollaboratorSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Collaborator invited!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ManageCollaboratorsError) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Collaborator ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a collaborator ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            BlocBuilder<ManageCollaboratorsBloc, ManageCollaboratorsState>(
              builder: (context, state) {
                final isLoading = state is ManageCollaboratorsLoading;
                return ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child:
                      isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Invite'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
