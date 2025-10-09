import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/sync/domain/usecases/trigger_startup_sync_usecase.dart';
import 'package:trackflow/core/sync/domain/usecases/trigger_upstream_sync_usecase.dart';
import 'package:trackflow/core/sync/domain/usecases/trigger_foreground_sync_usecase.dart';
import 'package:trackflow/core/sync/domain/usecases/trigger_downstream_sync_usecase.dart';
import 'package:trackflow/core/sync/presentation/bloc/sync_event.dart';
import 'package:trackflow/core/sync/presentation/bloc/sync_state.dart';

/// BLoC for managing sync state and triggering sync operations
///
/// This BLoC handles:
/// - Initial sync on app startup (after authentication)
/// - Foreground sync when app resumes
/// - Manual upstream sync (push pending operations)
/// - Manual downstream sync (pull all data)
@injectable
class SyncBloc extends Bloc<SyncEvent, SyncBlocState> {
  final TriggerStartupSyncUseCase _triggerStartupSync;
  final TriggerUpstreamSyncUseCase _triggerUpstreamSync;
  final TriggerForegroundSyncUseCase _triggerForegroundSync;
  final TriggerDownstreamSyncUseCase _triggerDownstreamSync;

  SyncBloc(
    this._triggerStartupSync,
    this._triggerUpstreamSync,
    this._triggerForegroundSync,
    this._triggerDownstreamSync,
  ) : super(const SyncBlocState.initial()) {
    on<StartupSyncRequested>(_onStartupSyncRequested);
    on<ForegroundSyncRequested>(_onForegroundSyncRequested);
    on<UpstreamSyncRequested>(_onUpstreamSyncRequested);
    on<DownstreamSyncRequested>(_onDownstreamSyncRequested);
  }



  /// Trigger initial sync on app startup
  /// This performs both upstream (push pending) and downstream (pull critical data)
  Future<void> _onStartupSyncRequested(
    StartupSyncRequested event,
    Emitter<SyncBlocState> emit,
  ) async {
    await _triggerStartupSync.call();
  }

  /// Trigger foreground sync when app resumes
  /// This syncs non-critical entities (audio_comments, waveforms)
  Future<void> _onForegroundSyncRequested(
    ForegroundSyncRequested event,
    Emitter<SyncBlocState> emit,
  ) async {
    await _triggerForegroundSync.call();
  }

  /// Trigger upstream sync to push pending operations
  Future<void> _onUpstreamSyncRequested(
    UpstreamSyncRequested event,
    Emitter<SyncBlocState> emit,
  ) async {
    await _triggerUpstreamSync.call();
  }

  /// Trigger full downstream sync to pull all data
  Future<void> _onDownstreamSyncRequested(
    DownstreamSyncRequested event,
    Emitter<SyncBlocState> emit,
  ) async {
    await _triggerDownstreamSync.call();
  }
}
