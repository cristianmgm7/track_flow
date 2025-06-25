import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

enum PlaylistSource { project, user }

class Playlist extends Equatable {
  final String id;
  final String name;
  final List<String> trackIds;
  final PlaylistSource playlistSource;

  const Playlist({
    required this.id,
    required this.name,
    required this.trackIds,
    required this.playlistSource,
  });

  Playlist copyWith({
    String? id,
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Playlist &&
        other.id == id &&
        other.name == name &&
        ListEquality().equals(other.trackIds, trackIds) &&
        other.playlistSource == playlistSource;
  }

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ trackIds.hashCode ^ playlistSource.hashCode;

  @override
  List<Object?> get props => [id, name, trackIds, playlistSource];
}
