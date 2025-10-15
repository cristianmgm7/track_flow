import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Represents a completed audio recording with metadata
class AudioRecording extends Equatable {
  final String id;                  // Unique identifier
  final String localPath;           // Local file path
  final Duration duration;          // Recording length
  final AudioFormat format;         // File format
  final int fileSizeBytes;          // File size
  final DateTime recordedAt;        // Recording timestamp
  final Map<String, dynamic>? metadata; // Optional consumer metadata

  const AudioRecording({
    required this.id,
    required this.localPath,
    required this.duration,
    required this.format,
    required this.fileSizeBytes,
    required this.recordedAt,
    this.metadata,
  });

  /// Create a new recording instance
  factory AudioRecording.create({
    required String localPath,
    required Duration duration,
    AudioFormat format = AudioFormat.m4a,
    int fileSizeBytes = 0,
    Map<String, dynamic>? metadata,
  }) {
    return AudioRecording(
      id: const Uuid().v4(),
      localPath: localPath,
      duration: duration,
      format: format,
      fileSizeBytes: fileSizeBytes,
      recordedAt: DateTime.now(),
      metadata: metadata,
    );
  }

  AudioRecording copyWith({
    String? id,
    String? localPath,
    Duration? duration,
    AudioFormat? format,
    int? fileSizeBytes,
    DateTime? recordedAt,
    Map<String, dynamic>? metadata,
  }) {
    return AudioRecording(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      duration: duration ?? this.duration,
      format: format ?? this.format,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      recordedAt: recordedAt ?? this.recordedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, localPath, duration, format, fileSizeBytes, recordedAt, metadata];
}

/// Supported audio formats
enum AudioFormat {
  m4a,  // AAC in M4A container (iOS & Android compatible)
  aac,  // Raw AAC
  mp3,  // MP3 (future support)
}
