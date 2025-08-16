import 'package:flutter/material.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';

enum AudioTrackSort {
  newest,
  oldest,
  nameAsc,
  nameDesc,
  durationAsc,
  durationDesc,
}

extension AudioTrackSortX on AudioTrackSort {
  String get label => switch (this) {
    AudioTrackSort.newest => 'Newest',
    AudioTrackSort.oldest => 'Oldest',
    AudioTrackSort.nameAsc => 'Name A–Z',
    AudioTrackSort.nameDesc => 'Name Z–A',
    AudioTrackSort.durationAsc => 'Duration ↑',
    AudioTrackSort.durationDesc => 'Duration ↓',
  };

  IconData get icon => switch (this) {
    AudioTrackSort.newest => Icons.schedule_rounded,
    AudioTrackSort.oldest => Icons.history_toggle_off_rounded,
    AudioTrackSort.nameAsc => Icons.sort_by_alpha_rounded,
    AudioTrackSort.nameDesc => Icons.sort_rounded,
    AudioTrackSort.durationAsc => Icons.timer_outlined,
    AudioTrackSort.durationDesc => Icons.timelapse_rounded,
  };
}

int compareTracksBySort(AudioTrack a, AudioTrack b, AudioTrackSort sort) {
  switch (sort) {
    case AudioTrackSort.newest:
      return b.createdAt.compareTo(a.createdAt);
    case AudioTrackSort.oldest:
      return a.createdAt.compareTo(b.createdAt);
    case AudioTrackSort.nameAsc:
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    case AudioTrackSort.nameDesc:
      return b.name.toLowerCase().compareTo(a.name.toLowerCase());
    case AudioTrackSort.durationAsc:
      return a.duration.compareTo(b.duration);
    case AudioTrackSort.durationDesc:
      return b.duration.compareTo(a.duration);
  }
}


