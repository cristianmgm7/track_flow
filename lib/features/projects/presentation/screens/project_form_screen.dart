import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/features/projects/domain/models/project.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';
import 'package:provider/provider.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project;

  const ProjectFormScreen({super.key, this.project});

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
    _loadProject();
  }

  Future<void> _loadProject() async {
    if (widget.project != null) {
      _project = widget.project;
    } else {
      final projectId = GoRouterState.of(context).pathParameters['id'];
      if (projectId != null) {
        final projectRepository = context.read<ProjectRepository>();
        try {
          _project = await projectRepository.getProject(projectId);
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
        _titleController = TextEditingController(text: _project?.title);
        _descriptionController = TextEditingController(
          text: _project?.description,
        );
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

  @override
  Widget build(BuildContext context) {
    final isEditing = _project != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Project' : 'New Project'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body:
          _project == null &&
                  GoRouterState.of(context).pathParameters['id'] != null
              ? const Center(child: CircularProgressIndicator())
              : Form(
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
              ),
    );
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    final projectRepository = context.read<ProjectRepository>();
    final userId = 'current-user-id'; // TODO: Get from auth service

    final project = Project(
      id: _project?.id ?? '',
      userId: userId,
      title: _titleController.text,
      description:
          _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
      createdAt: _project?.createdAt ?? DateTime.now(),
      status: _status,
    );

    try {
      if (_project == null) {
        await projectRepository.createProject(project);
      } else {
        await projectRepository.updateProject(project);
      }
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
