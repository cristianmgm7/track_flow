import 'package:injectable/injectable.dart';
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart';

@lazySingleton
class TriggerUpstreamSyncUseCase {
  final BackgroundSyncCoordinator _syncTrigger;

  TriggerUpstreamSyncUseCase(this._syncTrigger);

  Future<void> call() async {
    await _syncTrigger.pushUpstream();
  }
}
