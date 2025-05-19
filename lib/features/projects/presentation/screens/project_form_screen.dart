import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_name.dart';
import 'package:trackflow/features/projects/domain/entities/project_description.dart';
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_event.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_state.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project;
  final SharedPreferences prefs;

  const ProjectFormScreen({super.key, this.project, required this.prefs});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  Project? _project;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadProject();
  }

  Future<void> _loadProject() async {
    if (widget.project != null) {
      _project = widget.project;
    }
    if (mounted && _project != null) {
      setState(() {
        _titleController.text = _project!.name.value.fold((l) => '', (r) => r);
        _descriptionController.text = _project!.description.value.fold(
          (l) => '',
          (r) => r,
        );
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to save projects'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final ownerId = UniqueId.fromUniqueString(authState.user.id);
    final name = ProjectName(_titleController.text);
    final description = ProjectDescription(_descriptionController.text);

    if (_project == null) {
      final params = CreateProjectParams(
        ownerId: UserId.fromUniqueString(ownerId.value),
        name: name,
        description: description,
      );
      context.read<ProjectsBloc>().add(CreateProjectRequested(params));
    } else {
      final updatedProject = _project!.copyWith(
        name: name,
        description: description,
      );
      context.read<ProjectsBloc>().add(UpdateProjectRequested(updatedProject));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _project != null;

    return BlocListener<ProjectsBloc, ProjectsState>(
      listener: (context, state) {
        if (state is ProjectOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing ? 'Project updated!' : 'Project created!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else if (state is ProjectsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Project' : 'New Project'),
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
                    onPressed: isLoading ? null : _saveProject,
                    child:
                        isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text(
                              isEditing ? 'Update Project' : 'Create Project',
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
