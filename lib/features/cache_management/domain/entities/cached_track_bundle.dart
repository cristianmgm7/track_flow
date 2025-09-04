import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_cache/domain/entities/cached_audio.dart';
import 'package:trackflow/features/audio_cache/domain/entities/download_progress.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

/// Aggregate of cached file + rich context for UI display
class CachedTrackBundle extends Equatable {
  const CachedTrackBundle({
    required this.cached,
    this.track,
    this.uploader,
    this.projectName,
    this.activeDownload,
  });

  final CachedAudio cached;
  final AudioTrack? track;
  final UserProfile? uploader;
  final String? projectName;
  final DownloadProgress? activeDownload;

  String get trackId => cached.trackId;

  @override
  List<Object?> get props => [
    cached,
    track,
    uploader,
    projectName,
    activeDownload,
  ];
}
