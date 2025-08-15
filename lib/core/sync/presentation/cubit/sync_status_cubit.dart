import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/sync/domain/entities/sync_state.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart';
import 'package:trackflow/core/sync/domain/usecases/trigger_upstream_sync_usecase.dart';

part 'sync_status_state.dart';

@injectable
class SyncStatusCubit extends Cubit<SyncStatusState> {
  final SyncStatusProvider _statusProvider;
  final PendingOperationsManager _pendingManager;
  final TriggerUpstreamSyncUseCase _triggerUpstream;

  StreamSubscription<SyncState>? _syncSub;
  StreamSubscription? _pendingSub;

  SyncStatusCubit(
    this._statusProvider,
    this._pendingManager,
    this._triggerUpstream,
  ) : super(const SyncStatusState.initial());

  void start() {
    _syncSub?.cancel();
    _pendingSub?.cancel();
    _syncSub = _statusProvider.watchSyncState().listen((s) {
      emit(state.copyWith(syncState: s));
    });
    _pendingSub = _pendingManager.watchPendingOperations().listen((ops) {
      emit(state.copyWith(pendingCount: ops.length));
    });
  }

  Future<void> retryUpstream() async {
    await _triggerUpstream();
  }

  @override
  Future<void> close() {
    _syncSub?.cancel();
    _pendingSub?.cancel();
    return super.close();
  }
}
