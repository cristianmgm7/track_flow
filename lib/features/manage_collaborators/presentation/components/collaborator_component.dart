import 'package:flutter/material.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';

class CollaboratorComponent extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final ProjectRole role;
  final VoidCallback? onRemove;
  final UserId userId;

  const CollaboratorComponent({
    super.key,
    required this.name,
    required this.role,
    required this.userId,
    this.imageUrl,
    this.onRemove,
  });

  Color get roleColor {
    switch (role.value) {
      case ProjectRoleType.owner:
        return Colors.purple;
      case ProjectRoleType.admin:
        return Colors.blue;
      case ProjectRoleType.editor:
        return Colors.green;
      case ProjectRoleType.viewer:
        return Colors.grey;
    }
  }

  String get roleText {
    switch (role.value) {
      case ProjectRoleType.owner:
        return 'Owner';
      case ProjectRoleType.admin:
        return 'Admin';
      case ProjectRoleType.editor:
        return 'Editor';
      case ProjectRoleType.viewer:
        return 'Viewer';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.97),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: roleColor, width: 2),
              ),
              child:
                  imageUrl != null
                      ? ClipOval(
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildInitials();
                          },
                        ),
                      )
                      : _buildInitials(),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: roleColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  roleText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing:
            onRemove != null
                ? IconButton(
                  icon: const Icon(Icons.remove_circle),
                  color: Colors.red.withOpacity(0.8),
                  onPressed: onRemove,
                )
                : null,
      ),
    );
  }

  Widget _buildInitials() {
    final initials =
        name
            .split(' ')
            .take(2)
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
            .join();

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: roleColor.withOpacity(0.1),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: roleColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
