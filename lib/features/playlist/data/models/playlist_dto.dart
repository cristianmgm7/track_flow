class PlaylistDto {
  final int id;
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
      id: json['id'],
      name: json['name'],
      trackIds: List<String>.from(json['trackIds']),
      playlistSource: json['playlistSource'],
    );
  }
}
