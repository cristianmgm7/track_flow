import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'dart:io';

class ProjectDetailCollaboratorsComponent extends StatelessWidget {
  final ProjectDetailBundleState state;
  const ProjectDetailCollaboratorsComponent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.people),
                const SizedBox(width: 8),
                Text(
                  'Collaborators (${state.collaborators.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (state.isLoadingCollaborators) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
                IconButton(
                  alignment: Alignment.centerRight,
                  onPressed: () {
                    context.push(
                      AppRoutes.manageCollaborators,
                      extra: state.project,
                    );
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (state.collaboratorsError != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error loading collaborators: ${state.collaboratorsError}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
            if (state.collaborators.isEmpty &&
                !state.isLoadingCollaborators &&
                state.collaboratorsError == null) ...[
              const SizedBox(height: 16),
              const Text('No collaborators found'),
            ],
            if (state.collaborators.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...state.collaborators.map(
                (collaborator) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        (collaborator.avatarUrl.isNotEmpty)
                            ? (collaborator.avatarUrl.startsWith('http')
                                ? NetworkImage(collaborator.avatarUrl)
                                : FileImage(File(collaborator.avatarUrl))
                                    as ImageProvider)
                            : null,
                    child:
                        (collaborator.avatarUrl.isEmpty)
                            ? Text(
                              collaborator.name.isNotEmpty
                                  ? collaborator.name[0].toUpperCase()
                                  : '?',
                            )
                            : null,
                  ),
                  title: Text(collaborator.name),
                  subtitle: Text(collaborator.email),
                  trailing: const Icon(Icons.more_vert),
                  onTap: () {
                    context.push(
                      AppRoutes.artistProfile.replaceFirst(
                        ':id',
                        collaborator.id.value,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
