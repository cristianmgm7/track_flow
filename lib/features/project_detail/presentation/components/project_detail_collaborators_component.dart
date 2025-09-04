import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'package:trackflow/features/project_detail/presentation/components/collaborator_card.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';

class ProjectDetailCollaboratorsComponent extends StatelessWidget {
  final ProjectDetailState state;
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
                  icon: const Icon(Icons.more_horiz_outlined),
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
              CollaboratorCardsHorizontalList(
                collaborators:
                    state.collaborators.map((collaborator) {
                      // Find the role from project collaborators
                      final projectCollaborator = state.project?.collaborators
                          .firstWhere(
                            (pc) => pc.userId == collaborator.id,
                            orElse:
                                () =>
                                    throw StateError('Collaborator not found'),
                          );

                      return CollaboratorCardData(
                        id: collaborator.id.value,
                        name: collaborator.name,
                        email: collaborator.email,
                        avatarUrl: collaborator.avatarUrl,
                        role: projectCollaborator?.role ?? ProjectRole.viewer,
                        creativeRole: collaborator.creativeRole,
                      );
                    }).toList(),
                onCardTap: (collaborator) {
                  context.push(
                    AppRoutes.artistProfile.replaceFirst(
                      ':id',
                      collaborator.id,
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
