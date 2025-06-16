import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

enum PlaybackSourceType { track, comment }

class PlaybackSource {
  final PlaybackSourceType type;
  final AudioTrack track;
  final UserProfile collaborator;

  const PlaybackSource({
    required this.type,
    required this.track,
    required this.collaborator,
  });
}
