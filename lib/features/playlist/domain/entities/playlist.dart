import 'package:trackflow/core/domain/aggregate_root.dart';
import 'package:trackflow/core/entities/unique_id.dart';

enum PlaylistSource { project, user }

class Playlist extends AggregateRoot<PlaylistId> {
  final String name;
  final List<String> trackIds;
  final PlaylistSource playlistSource;

  const Playlist({
    required PlaylistId id,
    required this.name,
    required this.trackIds,
    required this.playlistSource,
  }) : super(id);

  Playlist copyWith({
    PlaylistId? id,
    String? name,
    List<String>? trackIds,
    PlaylistSource? playlistSource,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      trackIds: trackIds ?? this.trackIds,
      playlistSource: playlistSource ?? this.playlistSource,
    );
  }

  @override
  String toString() =>
      'Playlist(id: $id, name: $name, trackIds: $trackIds, playlistSource: $playlistSource)';
}
