import 'package:equatable/equatable.dart';
import 'audio_track_metadata.dart';

/// Represents an audio source for playback
/// Contains the URL and associated metadata
class AudioSource extends Equatable {
  const AudioSource({
    required this.url,
    required this.metadata,
    this.headers,
  });

  /// URL to the audio file (local file path or remote URL)
  final String url;

  /// Metadata associated with this audio source
  final AudioTrackMetadata metadata;

  /// Optional HTTP headers for remote URLs
  final Map<String, String>? headers;

  @override
  List<Object?> get props => [url, metadata, headers];

  AudioSource copyWith({
    String? url,
    AudioTrackMetadata? metadata,
    Map<String, String>? headers,
  }) {
    return AudioSource(
      url: url ?? this.url,
      metadata: metadata ?? this.metadata,
      headers: headers ?? this.headers,
    );
  }

  @override
  String toString() => 'AudioSource(url: $url, track: ${metadata.title})';
}