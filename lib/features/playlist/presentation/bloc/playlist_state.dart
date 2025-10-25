import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_track/presentation/models/audio_track_ui_model.dart';
import 'package:trackflow/features/playlist/presentation/models/track_row_view_model.dart';

class PlaylistState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<AudioTrackUiModel> tracks;
  final List<TrackRowViewModel> items;

  const PlaylistState({
    required this.isLoading,
    required this.error,
    required this.tracks,
    required this.items,
  });

  factory PlaylistState.initial() =>
      const PlaylistState(isLoading: true, error: null, tracks: [], items: []);

  PlaylistState copyWith({
    bool? isLoading,
    String? error,
    List<AudioTrackUiModel>? tracks,
    List<TrackRowViewModel>? items,
  }) {
    return PlaylistState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      tracks: tracks ?? this.tracks,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, tracks, items];
}
