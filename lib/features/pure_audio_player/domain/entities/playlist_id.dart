import 'package:equatable/equatable.dart';

/// Value object representing a unique identifier for a playlist
/// Used for pure audio operations without business domain coupling
class PlaylistId extends Equatable {
  const PlaylistId(this.value);

  final String value;

  @override
  List<Object> get props => [value];

  @override
  String toString() => 'PlaylistId($value)';
}