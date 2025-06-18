import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_name.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_description.dart';
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_event.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_state.dart';
import 'package:trackflow/features/project_detail/presentation/screens/project_details_screen.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project;
  final bool isEditing;

  const ProjectFormScreen({super.key, this.project})
    : isEditing = project != null;

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.project?.name.value.fold((l) => '', (r) => r),
    );
    _descriptionController = TextEditingController(
      text: widget.project?.description.value.fold((l) => '', (r) => r),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProjectOrEditProject() async {
    if (!_formKey.currentState!.validate()) return;

    final name = ProjectName(_titleController.text);
    final description = ProjectDescription(_descriptionController.text);

    if (widget.isEditing) {
      final updatedProject = widget.project!.copyWith(
        name: name,
        description: description,
      );
      context.read<ProjectsBloc>().add(UpdateProjectRequested(updatedProject));
    } else {
      final params = CreateProjectParams(name: name, description: description);
      context.read<ProjectsBloc>().add(CreateProjectRequested(params));
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectsBloc, ProjectsState>(
      listener: (context, state) {
        if (state is ProjectCreatedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project created!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (_) =>
                      ProjectDetailsScreen(projectId: state.project.id.value),
            ),
          );
        } else if (state is ProjectsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: \\${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit Project' : 'New Project'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocBuilder<ProjectsBloc, ProjectsState>(
          builder: (context, state) {
            final isLoading = state is ProjectsLoading;
            return Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _saveProjectOrEditProject,
                    child:
                        isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text(
                              widget.isEditing
                                  ? 'Edit Project'
                                  : 'Create Project',
                            ),
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
