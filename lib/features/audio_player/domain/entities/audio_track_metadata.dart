import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// Pure audio track metadata without any business domain concerns
/// Contains only information necessary for audio playback
/// NO: UserProfile, ProjectId, collaboration data, or business context
class AudioTrackMetadata extends Equatable {
  const AudioTrackMetadata({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    this.coverUrl,
    this.fileSize,
    this.bitrate,
    this.sampleRate,
    this.format,
  });

  /// Unique identifier for this audio track
  final AudioTrackId id;

  /// Track title for display purposes
  final String title;

  /// Artist name for display purposes
  final String artist;

  /// Total duration of the audio track
  final Duration duration;

  /// Optional URL for track cover art
  final String? coverUrl;

  /// Optional file size in bytes (for display/caching decisions)
  final int? fileSize;

  /// Optional bitrate in kbps (for quality display)
  final int? bitrate;

  /// Optional sample rate in Hz (for quality display)
  final int? sampleRate;

  /// Optional audio format (mp3, flac, wav, etc.)
  final String? format;

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        duration,
        coverUrl,
        fileSize,
        bitrate,
        sampleRate,
        format,
      ];

  AudioTrackMetadata copyWith({
    AudioTrackId? id,
    String? title,
    String? artist,
    Duration? duration,
    String? coverUrl,
    int? fileSize,
    int? bitrate,
    int? sampleRate,
    String? format,
  }) {
    return AudioTrackMetadata(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      coverUrl: coverUrl ?? this.coverUrl,
      fileSize: fileSize ?? this.fileSize,
      bitrate: bitrate ?? this.bitrate,
      sampleRate: sampleRate ?? this.sampleRate,
      format: format ?? this.format,
    );
  }

  @override
  String toString() => 'AudioTrackMetadata(id: $id, title: $title, artist: $artist)';
}