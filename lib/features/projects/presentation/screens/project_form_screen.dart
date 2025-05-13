import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
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
  late String _status;
  Project? _project;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _status = Project.statusDraft;
    _loadProject();
  }

  Future<void> _loadProject() async {
    if (widget.project != null) {
      _project = widget.project;
    } else {
      final projectId = GoRouterState.of(context).pathParameters['id'];
      if (projectId != null) {
        try {
          context.read<ProjectsBloc>().add(LoadProjectDetails(projectId));
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading project: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
            context.pop();
          }
          return;
        }
      }
    }

    if (mounted) {
      setState(() {
        _titleController.text = _project?.title ?? '';
        _descriptionController.text = _project?.description ?? '';
        _status = _project?.status ?? Project.statusDraft;
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

    final userId =
        authState.isOfflineMode
            ? 'offline-${widget.prefs.getString('offline_email') ?? 'user'}'
            : authState.user!.uid;

    final project = Project(
      id: _project?.id ?? '',
      userId: userId,
      title: _titleController.text,
      description: _descriptionController.text,
      createdAt: _project?.createdAt ?? DateTime.now(),
      status: _status,
    );

    if (_project == null) {
      context.read<ProjectsBloc>().add(CreateProject(project));
    } else {
      context.read<ProjectsBloc>().add(UpdateProject(project));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _project != null;

    return BlocListener<ProjectsBloc, ProjectsState>(
      listener: (context, state) {
        if (state is ProjectDetailsLoaded && _project == null) {
          setState(() {
            _project = state.project;
            _titleController.text = state.project.title;
            _descriptionController.text = state.project.description ?? '';
            _status = state.project.status;
          });
        } else if (state is ProjectOperationSuccess) {
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
            if (state is ProjectsLoading && _project == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Form(
              key: _formKey,
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
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        Project.validStatuses.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(
                              status.replaceAll('_', ' ').toUpperCase(),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _status = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveProject,
                    child: Text(
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
