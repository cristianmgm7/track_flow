import 'package:equatable/equatable.dart';
import '../../domain/entities/audio_comment.dart';

/// UI model wrapping AudioComment domain entity with unwrapped primitives
class AudioCommentUiModel extends Equatable {
  final AudioComment comment; // Composition pattern

  // Unwrapped primitives
  final String id;
  final String projectId;
  final String versionId;
  final String createdBy;
  final String content;
  final Duration timestamp;
  final DateTime createdAt;
  final String? audioStorageUrl;
  final String? localAudioPath;
  final Duration? audioDuration;
  final String commentType;

  // UI-specific computed fields
  final String formattedTimestamp;
  final String formattedCreatedAt;
  final bool hasAudio;

  const AudioCommentUiModel({
    required this.comment,
    required this.id,
    required this.projectId,
    required this.versionId,
    required this.createdBy,
    required this.content,
    required this.timestamp,
    required this.createdAt,
    this.audioStorageUrl,
    this.localAudioPath,
    this.audioDuration,
    required this.commentType,
    required this.formattedTimestamp,
    required this.formattedCreatedAt,
    required this.hasAudio,
  });

  factory AudioCommentUiModel.fromDomain(AudioComment comment) {
    return AudioCommentUiModel(
      comment: comment,
      id: comment.id.value,
      projectId: comment.projectId.value,
      versionId: comment.versionId.value,
      createdBy: comment.createdBy.value,
      content: comment.content,
      timestamp: comment.timestamp,
      createdAt: comment.createdAt,
      audioStorageUrl: comment.audioStorageUrl,
      localAudioPath: comment.localAudioPath,
      audioDuration: comment.audioDuration,
      commentType: comment.commentType.toString(),
      formattedTimestamp: _formatDuration(comment.timestamp),
      formattedCreatedAt: _formatDateTime(comment.createdAt),
      hasAudio: comment.audioStorageUrl != null || comment.localAudioPath != null,
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        versionId,
        createdBy,
        content,
        timestamp,
        createdAt,
        audioStorageUrl,
        localAudioPath,
        audioDuration,
        commentType,
        formattedTimestamp,
        formattedCreatedAt,
        hasAudio,
      ];
}
