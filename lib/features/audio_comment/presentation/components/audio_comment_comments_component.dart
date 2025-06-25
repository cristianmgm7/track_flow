import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class CommentComponent extends StatelessWidget {
  final AudioComment comment;
  final UserProfile collaborator;

  const CommentComponent({
    super.key,
    required this.comment,
    required this.collaborator,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final createdAt = comment.createdAt; // Asegúrate que tu modelo tenga esto
    final createdAtStr = dateFormat.format(createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundImage:
                    collaborator.avatarUrl.isNotEmpty
                        ? NetworkImage(collaborator.avatarUrl)
                        : null,
                child:
                    collaborator.avatarUrl.isEmpty
                        ? Text(
                          collaborator.name.isNotEmpty
                              ? collaborator.name.substring(0, 1)
                              : comment.createdBy.value.substring(0, 1),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y fecha
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          collaborator.name.isNotEmpty
                              ? collaborator.name
                              : comment.createdBy.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          createdAtStr,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Contenido del comentario
                    Text(comment.content, style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AudioCommentCommentsList extends StatelessWidget {
  final List<AudioComment> comments;
  final List<UserProfile> collaborators;
  const AudioCommentCommentsList({
    super.key,
    required this.comments,
    required this.collaborators,
  });

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const Center(
        child: Text('No comments yet.', style: TextStyle(color: Colors.white)),
      );
    }
    return ListView.builder(
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        final collaborator = collaborators.firstWhere(
          (u) => u.id == comment.createdBy,
          orElse:
              () => UserProfile(
                id: comment.createdBy,
                name: '',
                email: '',
                avatarUrl: '',
                createdAt: DateTime.now(),
              ),
        );
        return CommentComponent(comment: comment, collaborator: collaborator);
      },
    );
  }
}
