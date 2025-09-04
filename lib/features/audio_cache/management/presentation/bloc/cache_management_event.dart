import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_cache/management/domain/entities/cached_track_bundle.dart';

abstract class CacheManagementEvent extends Equatable {
  const CacheManagementEvent();
  @override
  List<Object?> get props => [];
}

class CacheManagementStarted extends CacheManagementEvent {
  const CacheManagementStarted();
}

class CacheManagementRefreshRequested extends CacheManagementEvent {
  const CacheManagementRefreshRequested();
}

/// Internal: emitted when cached audios stream updates
class CacheManagementBundlesUpdated extends CacheManagementEvent {
  const CacheManagementBundlesUpdated(this.bundles);
  final List<CachedTrackBundle> bundles;
  @override
  List<Object?> get props => [bundles];
}

class CacheManagementToggleSelect extends CacheManagementEvent {
  const CacheManagementToggleSelect(this.trackId);
  final AudioTrackId trackId;
  @override
  List<Object?> get props => [trackId];
}

class CacheManagementSelectAll extends CacheManagementEvent {
  const CacheManagementSelectAll();
}

class CacheManagementClearSelection extends CacheManagementEvent {
  const CacheManagementClearSelection();
}

class CacheManagementDeleteTrackRequested extends CacheManagementEvent {
  const CacheManagementDeleteTrackRequested(this.trackId);
  final AudioTrackId trackId;
  @override
  List<Object?> get props => [trackId];
}

class CacheManagementDeleteSelectedRequested extends CacheManagementEvent {
  const CacheManagementDeleteSelectedRequested();
}

class CacheManagementCleanupRequested extends CacheManagementEvent {
  const CacheManagementCleanupRequested({
    this.removeCorrupted = true,
    this.removeOrphaned = true,
    this.removeTemporary = true,
    this.targetFreeBytes,
  });
  final bool removeCorrupted;
  final bool removeOrphaned;
  final bool removeTemporary;
  final int? targetFreeBytes;

  @override
  List<Object?> get props => [
    removeCorrupted,
    removeOrphaned,
    removeTemporary,
    targetFreeBytes,
  ];
}
