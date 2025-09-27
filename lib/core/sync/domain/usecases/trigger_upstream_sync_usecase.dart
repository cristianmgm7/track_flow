import 'package:injectable/injectable.dart';
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart';

@lazySingleton
class TriggerUpstreamSyncUseCase {
  final BackgroundSyncCoordinator _coordinator;

  TriggerUpstreamSyncUseCase(this._coordinator);

  Future<void> call() async {
    await _coordinator.pushUpstream();
  }
}
