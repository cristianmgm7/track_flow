import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';

class PlaylistDto {
  final String id;
  final String name;
  final List<String> trackIds;
  final String playlistSource;

  PlaylistDto({
    required this.id,
    required this.name,
    required this.trackIds,
    required this.playlistSource,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'trackIds': trackIds,
    'playlistSource': playlistSource,
  };

  factory PlaylistDto.fromJson(Map<String, dynamic> json) {
    return PlaylistDto(
      id: json['id'] as String,
      name: json['name'] as String,
      trackIds: List<String>.from(json['trackIds']),
      playlistSource: json['playlistSource'] as String,
    );
  }

  Playlist toDomain() {
    return Playlist(
      id: PlaylistId.fromUniqueString(id),
      name: name,
      trackIds: trackIds,
      playlistSource: _parsePlaylistSource(playlistSource),
    );
  }

  factory PlaylistDto.fromDomain(Playlist playlist) {
    return PlaylistDto(
      id: playlist.id.value,
      name: playlist.name,
      trackIds: playlist.trackIds,
      playlistSource: playlist.playlistSource.name,
    );
  }

  PlaylistSource _parsePlaylistSource(String source) {
    return PlaylistSource.values.firstWhere(
      (e) => e.name == source,
      orElse: () => PlaylistSource.user,
    );
  }
}
