part of 'sync_status_cubit.dart';

class SyncStatusState extends Equatable {
  final SyncState syncState;
  final int pendingCount;

  const SyncStatusState({required this.syncState, required this.pendingCount});

  const SyncStatusState.initial()
    : syncState = SyncState.initial,
      pendingCount = 0;

  SyncStatusState copyWith({SyncState? syncState, int? pendingCount}) {
    return SyncStatusState(
      syncState: syncState ?? this.syncState,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }

  @override
  List<Object?> get props => [syncState, pendingCount];
}
