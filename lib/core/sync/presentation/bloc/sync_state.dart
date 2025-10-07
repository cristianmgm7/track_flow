import 'package:equatable/equatable.dart';
import 'package:trackflow/core/sync/domain/entities/sync_state.dart';

/// State for the Sync BLoC
class SyncBlocState extends Equatable {
  final SyncState syncState;
  final int pendingCount;

  const SyncBlocState({
    required this.syncState,
    required this.pendingCount,
  });

  const SyncBlocState.initial()
      : syncState = SyncState.initial,
        pendingCount = 0;

  SyncBlocState copyWith({
    SyncState? syncState,
    int? pendingCount,
  }) {
    return SyncBlocState(
      syncState: syncState ?? this.syncState,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }

  @override
  List<Object?> get props => [syncState, pendingCount];
}
