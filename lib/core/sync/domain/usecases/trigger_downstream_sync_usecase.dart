import 'package:injectable/injectable.dart';
import 'package:trackflow/core/app_flow/domain/entities/user_session.dart';
import 'package:trackflow/core/sync/domain/services/sync_trigger.dart';
import 'package:trackflow/core/app_flow/domain/services/session_service.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// Use case for triggering full downstream sync (pull all data)
///
/// This performs:
/// 1. Push pending operations (upstream sync)
/// 2. Pull all data from remote (downstream sync for all entities)
///
/// Used for manual refresh or when user explicitly requests full sync
@lazySingleton
class TriggerDownstreamSyncUseCase {
  final SyncTrigger _syncTrigger;
  final SessionService _sessionService;

  TriggerDownstreamSyncUseCase(this._syncTrigger, this._sessionService);

  Future<void> call() async {
    try {
      final sessionResult = await _sessionService.getCurrentSession();
      if (sessionResult.isRight()) {
        final session = sessionResult.getOrElse(
          () => UserSession.unauthenticated(),
        );
        if (session.currentUser != null) {
          await _syncTrigger.triggerFullSync(
            session.currentUser!.id.value,
          );
        }
      }
    } catch (e) {
      AppLogger.warning('Failed to trigger downstream sync: $e');
    }
  }
}
