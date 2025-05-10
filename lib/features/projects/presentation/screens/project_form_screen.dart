import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/project.dart';
import '../../domain/repositories/project_repository.dart';

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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project?.title);
    _descriptionController = TextEditingController(
      text: widget.project?.description,
    );
    _status = widget.project?.status ?? Project.statusDraft;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Project' : 'New Project')),
      body: Form(
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
                      child: Text(status.replaceAll('_', ' ').toUpperCase()),
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
              child: Text(isEditing ? 'Update Project' : 'Create Project'),
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
      id: widget.project?.id ?? '',
      userId: userId,
      title: _titleController.text,
      description:
          _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
      createdAt: widget.project?.createdAt ?? DateTime.now(),
      status: _status,
    );

    try {
      if (widget.project == null) {
        await projectRepository.createProject(project);
      } else {
        await projectRepository.updateProject(project);
      }
      if (mounted) {
        Navigator.pop(context);
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
