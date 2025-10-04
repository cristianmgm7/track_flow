import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/playlist/domain/entities/track_summary.dart';

class PlaylistTracksBundle extends Equatable {
  final List<AudioTrack> tracks;
  final List<TrackSummary> summaries;

  const PlaylistTracksBundle({required this.tracks, required this.summaries});

  @override
  List<Object?> get props => [tracks, summaries];
}












