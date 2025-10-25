import 'package:equatable/equatable.dart';
import '../../domain/entities/audio_track.dart';

/// UI model wrapping AudioTrack domain entity with unwrapped primitives
class AudioTrackUiModel extends Equatable {
  final AudioTrack track; // Composition pattern

  // Unwrapped primitives
  final String id;
  final String name;
  final String coverUrl;
  final String? coverLocalPath;
  final Duration duration;
  final String projectId;
  final String uploadedBy;
  final DateTime createdAt;
  final String? activeVersionId;
  final bool isDeleted;

  // UI-specific computed fields
  final String formattedDuration;

  const AudioTrackUiModel({
    required this.track,
    required this.id,
    required this.name,
    required this.coverUrl,
    this.coverLocalPath,
    required this.duration,
    required this.projectId,
    required this.uploadedBy,
    required this.createdAt,
    this.activeVersionId,
    required this.isDeleted,
    required this.formattedDuration,
  });

  factory AudioTrackUiModel.fromDomain(AudioTrack track) {
    return AudioTrackUiModel(
      track: track,
      id: track.id.value,
      name: track.name,
      coverUrl: track.coverUrl,
      coverLocalPath: track.coverLocalPath,
      duration: track.duration,
      projectId: track.projectId.value,
      uploadedBy: track.uploadedBy.value,
      createdAt: track.createdAt,
      activeVersionId: track.activeVersionId?.value,
      isDeleted: track.isDeleted,
      formattedDuration: _formatDuration(track.duration),
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    coverUrl,
    coverLocalPath,
    duration,
    projectId,
    uploadedBy,
    createdAt,
    activeVersionId,
    isDeleted,
    formattedDuration,
  ];
}
