import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class AudioComment extends Equatable {
  final AudioCommentId id;
  final AudioTrackId trackId;
  final UserId userId;
  final String content;
  final Duration timestamp;
  final DateTime createdAt;

  const AudioComment({
    required this.id,
    required this.trackId,
    required this.userId,
    required this.content,
    required this.timestamp,
    required this.createdAt,
  });

  @override
  List<Object> get props => [
    id,
    trackId,
    userId,
    content,
    timestamp,
    createdAt,
  ];

  AudioComment copyWith({
    AudioCommentId? id,
    AudioTrackId? trackId,
    UserId? userId,
    String? content,
    Duration? timestamp,
    DateTime? createdAt,
  }) {
    return AudioComment(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
