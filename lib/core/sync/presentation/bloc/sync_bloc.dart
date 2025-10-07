import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/sync/domain/entities/sync_state.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart';
import 'package:trackflow/core/sync/domain/usecases/trigger_startup_sync_usecase.dart';
import 'package:trackflow/core/sync/domain/usecases/trigger_upstream_sync_usecase.dart';
import 'package:trackflow/core/sync/domain/usecases/trigger_foreground_sync_usecase.dart';
import 'package:trackflow/core/sync/presentation/bloc/sync_event.dart';
import 'package:trackflow/core/sync/presentation/bloc/sync_state.dart';

/// BLoC for managing sync state and triggering sync operations
///
/// This BLoC handles:
/// - Initial sync on app startup (after authentication)
/// - Foreground sync when app resumes
/// - Manual upstream sync (push pending operations)
/// - Watching sync state and pending operations count
@injectable
class SyncBloc extends Bloc<SyncEvent, SyncBlocState> {
  final SyncStatusProvider _statusProvider;
  final PendingOperationsManager _pendingManager;
  final TriggerStartupSyncUseCase _triggerStartupSync;
  final TriggerUpstreamSyncUseCase _triggerUpstreamSync;
  final TriggerForegroundSyncUseCase _triggerForegroundSync;

  StreamSubscription<SyncState>? _syncSub;
  StreamSubscription? _pendingSub;

  SyncBloc(
    this._statusProvider,
    this._pendingManager,
    this._triggerStartupSync,
    this._triggerUpstreamSync,
    this._triggerForegroundSync,
  ) : super(const SyncBlocState.initial()) {
    on<SyncWatchingStarted>(_onSyncWatchingStarted);
    on<InitialSyncRequested>(_onInitialSyncRequested);
    on<ForegroundSyncRequested>(_onForegroundSyncRequested);
    on<UpstreamSyncRequested>(_onUpstreamSyncRequested);
  }

  /// Start watching sync state and pending operations
  Future<void> _onSyncWatchingStarted(
    SyncWatchingStarted event,
    Emitter<SyncBlocState> emit,
  ) async {
    await _syncSub?.cancel();
    await _pendingSub?.cancel();

    _syncSub = _statusProvider.watchSyncState().listen((syncState) {
      emit(state.copyWith(syncState: syncState));
    });

    _pendingSub = _pendingManager.watchPendingOperations().listen((ops) {
      emit(state.copyWith(pendingCount: ops.length));
    });
  }

  /// Trigger initial sync on app startup
  /// This performs both upstream (push pending) and downstream (pull critical data)
  Future<void> _onInitialSyncRequested(
    InitialSyncRequested event,
    Emitter<SyncBlocState> emit,
  ) async {
    await _triggerStartupSync();
  }

  /// Trigger foreground sync when app resumes
  /// This syncs non-critical entities (audio_comments, waveforms)
  Future<void> _onForegroundSyncRequested(
    ForegroundSyncRequested event,
    Emitter<SyncBlocState> emit,
  ) async {
    await _triggerForegroundSync();
  }

  /// Trigger upstream sync to push pending operations
  Future<void> _onUpstreamSyncRequested(
    UpstreamSyncRequested event,
    Emitter<SyncBlocState> emit,
  ) async {
    await _triggerUpstreamSync();
  }

  @override
  Future<void> close() {
    _syncSub?.cancel();
    _pendingSub?.cancel();
    return super.close();
  }
}
