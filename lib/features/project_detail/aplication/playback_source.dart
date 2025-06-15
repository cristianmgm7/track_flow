import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';

enum PlaybackSourceType { track, comment }

class PlaybackSource {
  final PlaybackSourceType type;
  final AudioTrack track;

  const PlaybackSource({required this.type, required this.track});
}
