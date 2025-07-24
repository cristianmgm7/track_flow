import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';

class PlaylistDto {
  final String id;
  final String name;
  final List<String> trackIds;
  final String playlistSource;

  // ⭐ NEW: Sync metadata fields for proper offline-first sync
  final int version;
  final DateTime? lastModified;

  PlaylistDto({
    required this.id,
    required this.name,
    required this.trackIds,
    required this.playlistSource,
    // ⭐ NEW: Sync metadata fields
    this.version = 1,
    this.lastModified,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'trackIds': trackIds,
    'playlistSource': playlistSource,
    // ⭐ NEW: Include sync metadata in JSON
    'version': version,
    'lastModified': lastModified?.toIso8601String(),
  };

  factory PlaylistDto.fromJson(Map<String, dynamic> json) {
    return PlaylistDto(
      id: json['id'] as String,
      name: json['name'] as String,
      trackIds: List<String>.from(json['trackIds']),
      playlistSource: json['playlistSource'] as String,
      // ⭐ NEW: Parse sync metadata from JSON
      version: json['version'] as int? ?? 1,
      lastModified:
          json['lastModified'] != null
              ? DateTime.tryParse(json['lastModified'] as String)
              : null,
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
      // ⭐ NEW: Include sync metadata for new playlists
      version: 1, // Initial version for new playlists
      lastModified: DateTime.now(), // Current time as initial lastModified
    );
  }

  PlaylistSource _parsePlaylistSource(String source) {
    return PlaylistSource.values.firstWhere(
      (e) => e.name == source,
      orElse: () => PlaylistSource.user,
    );
  }
}
