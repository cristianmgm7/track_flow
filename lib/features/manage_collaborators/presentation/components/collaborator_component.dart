import 'package:flutter/material.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/core/widgets/user_avatar.dart';

class CollaboratorComponent extends StatelessWidget {
  final String name;
  final String imageUrl;
  final ProjectRole role;
  final UserId userId;
  final VoidCallback onTap;

  const CollaboratorComponent({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.role,
    required this.userId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              UserAvatar(
                imageUrl: imageUrl,
                size: 48,
                fallback: const Icon(Icons.person, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      role.toShortString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz_outlined),
            ],
          ),
        ),
      ),
    );
  }
}
