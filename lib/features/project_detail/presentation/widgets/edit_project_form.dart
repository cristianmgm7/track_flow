import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_event.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_state.dart';

class EditProjectForm extends StatefulWidget {
  final Project project;
  const EditProjectForm({super.key, required this.project});

  @override
  State<EditProjectForm> createState() => _EditProjectFormState();
}

class _EditProjectFormState extends State<EditProjectForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.project.name.value.getOrElse(() => ''),
    );
    _descriptionController = TextEditingController(
      text: widget.project.description.value.getOrElse(() => ''),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedProject = widget.project.copyWith(
        name: ProjectName(_nameController.text),
        description: ProjectDescription(_descriptionController.text),
      );
      context.read<ProjectsBloc>().add(UpdateProjectRequested(updatedProject));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectsBloc, ProjectsState>(
      listener: (context, state) {
        if (state is ProjectOperationSuccess) {
          Navigator.of(context).pop();
          context.go(AppRoutes.projects);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is ProjectsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a project name';
                }
                return null;
              },
            ),
            SizedBox(height: Dimensions.space16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Project Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: Dimensions.space20),
            BlocBuilder<ProjectsBloc, ProjectsState>(
              builder: (context, state) {
                final isLoading = state is ProjectsLoading;
                return ElevatedButton(
                  onPressed: isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, Dimensions.buttonHeight),
                  ),
                  child:
                      isLoading
                          ? SizedBox(
                            height: Dimensions.iconMedium,
                            width: Dimensions.iconMedium,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Save Changes'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
