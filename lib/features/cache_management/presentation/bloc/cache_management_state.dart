import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/cache_management/presentation/models/cached_track_bundle_ui_model.dart';
import 'package:trackflow/features/cache_management/domain/usecases/get_cache_storage_stats_usecase.dart';

enum CacheManagementStatus { initial, loading, success, failure }

class CacheManagementState extends Equatable {
  const CacheManagementState({
    this.status = CacheManagementStatus.initial,
    this.bundles = const [],
    this.selected = const {},
    this.storageUsageBytes = 0,
    this.storageStats,
    this.errorMessage,
  });

  final CacheManagementStatus status;
  final List<CachedTrackBundleUiModel> bundles;
  final Set<AudioTrackId> selected;
  final int storageUsageBytes;
  final StorageStats? storageStats;
  final String? errorMessage;

  CacheManagementState copyWith({
    CacheManagementStatus? status,
    List<CachedTrackBundleUiModel>? bundles,
    Set<AudioTrackId>? selected,
    int? storageUsageBytes,
    StorageStats? storageStats,
    String? errorMessage,
  }) {
    return CacheManagementState(
      status: status ?? this.status,
      bundles: bundles ?? this.bundles,
      selected: selected ?? this.selected,
      storageUsageBytes: storageUsageBytes ?? this.storageUsageBytes,
      storageStats: storageStats ?? this.storageStats,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    bundles,
    selected,
    storageUsageBytes,
    storageStats,
    errorMessage,
  ];
}
