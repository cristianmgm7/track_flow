import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';

class TrackRowViewModel extends Equatable {
  final AudioTrack track;
  final Duration displayedDuration;
  final String? cacheableRemoteUrl;
  final String? activeVersionId;
  final TrackVersionStatus? status;

  const TrackRowViewModel({
    required this.track,
    required this.displayedDuration,
    this.cacheableRemoteUrl,
    this.activeVersionId,
    this.status,
  });

  // Factory method for consistency with new UI models
  factory TrackRowViewModel.fromDomain({
    required AudioTrack track,
    Duration? displayedDuration,
    String? cacheableRemoteUrl,
    String? activeVersionId,
    TrackVersionStatus? status,
  }) {
    return TrackRowViewModel(
      track: track,
      displayedDuration: displayedDuration ?? track.duration,
      cacheableRemoteUrl: cacheableRemoteUrl,
      activeVersionId: activeVersionId,
      status: status,
    );
  }

  @override
  List<Object?> get props => [
    track,
    displayedDuration,
    cacheableRemoteUrl,
    activeVersionId,
    status,
  ];
}
