import 'package:equatable/equatable.dart';

/// Value object representing a unique identifier for an audio track
/// This is a pure audio concept with no business domain coupling
class AudioTrackId extends Equatable {
  const AudioTrackId(this.value);

  final String value;

  @override
  List<Object> get props => [value];

  @override
  String toString() => 'AudioTrackId($value)';
}