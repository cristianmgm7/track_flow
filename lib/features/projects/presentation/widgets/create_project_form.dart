import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_event.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_state.dart';
import 'package:trackflow/features/ui/forms/app_form_field.dart';
import 'package:trackflow/features/ui/buttons/primary_button.dart';
import 'package:trackflow/features/ui/buttons/secondary_button.dart';

class ProjectFormBottomSheet extends StatefulWidget {
  final Project? project;

  const ProjectFormBottomSheet({super.key, this.project});

  @override
  State<ProjectFormBottomSheet> createState() => _ProjectFormBottomSheetState();
}

class _ProjectFormBottomSheetState extends State<ProjectFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.project?.name.value.fold((l) => '', (r) => r),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    final name = ProjectName(_titleController.text);

    final params = CreateProjectParams(name: name);
    context.read<ProjectsBloc>().add(CreateProjectRequested(params));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectsBloc, ProjectsState>(
      listener: (context, state) {
        if (state is ProjectCreatedSuccess) {
          Navigator.of(context).pop();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Project created!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
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
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppFormField(
              label: 'Name of project',
              controller: _titleController,
              validator: (value) {
                return ProjectName(
                  value ?? '',
                ).value.fold((l) => l.message, (r) => null);
              },
            ),
            SizedBox(height: Dimensions.space24),
            BlocBuilder<ProjectsBloc, ProjectsState>(
              builder: (context, state) {
                final isLoading = state is ProjectsLoading;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SecondaryButton(
                      text: 'Cancel',
                      onPressed:
                          isLoading ? null : () => Navigator.of(context).pop(),
                      isDisabled: isLoading,
                    ),
                    SizedBox(width: Dimensions.space8),
                    PrimaryButton(
                      text: 'Create Project',
                      onPressed: isLoading ? null : _saveProject,
                      isLoading: isLoading,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
