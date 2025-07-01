import 'package:trackflow/features/playlist/domain/entities/playlist.dart';

class PlaylistUtils {
  static bool isPlayingFromPlaylist(List<String> currentQueue, Playlist playlist) {
    if (currentQueue.length != playlist.trackIds.length) return false;
    return playlist.trackIds.every((trackId) => currentQueue.contains(trackId));
  }
}