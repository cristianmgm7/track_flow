import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class AudioCommentDTO {
  final String id;
  final String trackId;
  final String userId;
  final String content;
  final int timestamp;
  final String createdAt;

  AudioCommentDTO({
    required this.id,
    required this.trackId,
    required this.userId,
    required this.content,
    required this.timestamp,
    required this.createdAt,
  });

  factory AudioCommentDTO.fromDomain(AudioComment audioComment) {
    return AudioCommentDTO(
      id: audioComment.id.value,
      trackId: audioComment.trackId.value,
      userId: audioComment.userId.value,
      content: audioComment.content,
      timestamp: audioComment.timestamp.inMilliseconds,
      createdAt: audioComment.createdAt.toIso8601String(),
    );
  }

  AudioComment toDomain() {
    return AudioComment(
      id: AudioCommentId.fromUniqueString(id),
      trackId: AudioTrackId.fromUniqueString(trackId),
      userId: UserId.fromUniqueString(userId),
      content: content,
      timestamp: Duration(milliseconds: timestamp),
      createdAt: DateTime.parse(createdAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackId': trackId,
      'userId': userId,
      'content': content,
      'timestamp': timestamp,
      'createdAt': createdAt,
    };
  }

  factory AudioCommentDTO.fromJson(Map<String, dynamic> json) {
    return AudioCommentDTO(
      id: json['id'] as String,
      trackId: json['trackId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] as int,
      createdAt: json['createdAt'] as String,
    );
  }
}
