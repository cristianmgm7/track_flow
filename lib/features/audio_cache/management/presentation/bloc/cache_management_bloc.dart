import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart' show Unit;
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_cache/management/domain/usecases/delete_cached_audio_usecase.dart';
import 'package:trackflow/features/audio_cache/management/domain/usecases/delete_multiple_cached_audios_usecase.dart';
import 'package:trackflow/features/audio_cache/management/domain/usecases/get_cached_track_bundles_usecase.dart';
import 'package:trackflow/features/audio_cache/management/domain/usecases/watch_storage_usage_usecase.dart';
import 'package:trackflow/features/audio_cache/shared/domain/usecases/cleanup_cache_usecase.dart';
import 'package:trackflow/features/audio_cache/shared/domain/usecases/get_cache_storage_stats_usecase.dart';
import 'cache_management_event.dart';
import 'cache_management_state.dart';

@injectable
class CacheManagementBloc
    extends Bloc<CacheManagementEvent, CacheManagementState> {
  CacheManagementBloc({
    required GetCachedTrackBundlesUseCase getBundles,
    required DeleteCachedAudioUseCase deleteOne,
    required DeleteMultipleCachedAudiosUseCase deleteMany,
    required WatchStorageUsageUseCase watchUsage,
    required GetCacheStorageStatsUseCase getStats,
    required CleanupCacheUseCase cleanup,
  }) : _getBundles = getBundles,
       _deleteOne = deleteOne,
       _deleteMany = deleteMany,
       _watchUsage = watchUsage,
       _getStats = getStats,
       _cleanup = cleanup,
       super(const CacheManagementState()) {
    on<CacheManagementStarted>(_onStarted);
    on<CacheManagementRefreshRequested>(_onRefresh);
    on<CacheManagementToggleSelect>(_onToggleSelect);
    on<CacheManagementSelectAll>(_onSelectAll);
    on<CacheManagementClearSelection>(_onClearSelection);
    on<CacheManagementDeleteTrackRequested>(_onDeleteOne);
    on<CacheManagementDeleteSelectedRequested>(_onDeleteSelected);
    on<CacheManagementCleanupRequested>(_onCleanupRequested);
  }

  final GetCachedTrackBundlesUseCase _getBundles;
  final DeleteCachedAudioUseCase _deleteOne;
  final DeleteMultipleCachedAudiosUseCase _deleteMany;
  final WatchStorageUsageUseCase _watchUsage;
  final GetCacheStorageStatsUseCase _getStats;
  final CleanupCacheUseCase _cleanup;

  StreamSubscription<int>? _usageSub;

  Future<void> _onStarted(
    CacheManagementStarted event,
    Emitter<CacheManagementState> emit,
  ) async {
    emit(
      state.copyWith(status: CacheManagementStatus.loading, errorMessage: null),
    );

    // Watch storage usage and refresh stats on each change
    await emit.onEach<int>(
      _watchUsage.call(),
      onData: (usage) async {
        final statsEither = await _getStats.call();
        statsEither.fold(
          (failure) => emit(state.copyWith(storageUsageBytes: usage)),
          (stats) => emit(
            state.copyWith(storageUsageBytes: usage, storageStats: stats),
          ),
        );
      },
    );
  }

  Future<void> _onRefresh(
    CacheManagementRefreshRequested event,
    Emitter<CacheManagementState> emit,
  ) async {
    await _loadBundles(emit);
  }

  Future<void> _loadBundles(Emitter<CacheManagementState> emit) async {
    final either = await _getBundles.call();
    either.fold(
      (failure) => emit(
        state.copyWith(
          status: CacheManagementStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (bundles) => emit(
        state.copyWith(status: CacheManagementStatus.success, bundles: bundles),
      ),
    );
  }

  Future<void> _onToggleSelect(
    CacheManagementToggleSelect event,
    Emitter<CacheManagementState> emit,
  ) async {
    final updated = Set<AudioTrackId>.from(state.selected);
    if (updated.contains(event.trackId)) {
      updated.remove(event.trackId);
    } else {
      updated.add(event.trackId);
    }
    emit(state.copyWith(selected: updated));
  }

  Future<void> _onSelectAll(
    CacheManagementSelectAll event,
    Emitter<CacheManagementState> emit,
  ) async {
    final all =
        state.bundles
            .map((b) => AudioTrackId.fromUniqueString(b.trackId))
            .toSet();
    emit(state.copyWith(selected: all));
  }

  Future<void> _onClearSelection(
    CacheManagementClearSelection event,
    Emitter<CacheManagementState> emit,
  ) async {
    emit(state.copyWith(selected: {}));
  }

  Future<void> _onDeleteOne(
    CacheManagementDeleteTrackRequested event,
    Emitter<CacheManagementState> emit,
  ) async {
    final result = await _deleteOne.call(event.trackId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CacheManagementStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (Unit _) async {
        await _loadBundles(emit);
      },
    );
  }

  Future<void> _onDeleteSelected(
    CacheManagementDeleteSelectedRequested event,
    Emitter<CacheManagementState> emit,
  ) async {
    if (state.selected.isEmpty) return;
    final result = await _deleteMany.call(state.selected.toList());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CacheManagementStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (deletedIds) async {
        emit(state.copyWith(selected: {}));
        await _loadBundles(emit);
      },
    );
  }

  Future<void> _onCleanupRequested(
    CacheManagementCleanupRequested event,
    Emitter<CacheManagementState> emit,
  ) async {
    final result = await _cleanup.call(
      removeCorrupted: event.removeCorrupted,
      removeOrphaned: event.removeOrphaned,
      removeTemporary: event.removeTemporary,
      targetFreeBytes: event.targetFreeBytes,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CacheManagementStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) async {
        await _loadBundles(emit);
      },
    );
  }

  @override
  Future<void> close() {
    _usageSub?.cancel();
    return super.close();
  }
}
