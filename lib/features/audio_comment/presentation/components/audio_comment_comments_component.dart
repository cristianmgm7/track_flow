import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class CommentComponent extends StatelessWidget {
  final AudioComment comment;
  final UserProfile collaborator;

  const CommentComponent({
    super.key,
    required this.comment,
    required this.collaborator,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final createdAt = comment.createdAt;
    final createdAtStr = dateFormat.format(createdAt);

    return InkWell(
      onTap: () {
        context
            .read<AudioPlayerBloc>()
            .add(SeekToPositionRequested(comment.timestamp));
      },
      child: Padding(
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
                CircleAvatar(
                  radius: 28,
                  backgroundImage: collaborator.avatarUrl.isNotEmpty
                      ? NetworkImage(collaborator.avatarUrl)
                      : null,
                  child: collaborator.avatarUrl.isEmpty
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Text(comment.content, style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          'at ${_formatDuration(comment.timestamp)}',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          orElse: () => UserProfile(
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
