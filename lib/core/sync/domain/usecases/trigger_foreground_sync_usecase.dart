import 'package:injectable/injectable.dart';
import 'package:trackflow/core/app_flow/domain/entities/user_session.dart';
import 'package:trackflow/core/sync/domain/services/sync_trigger.dart';
import 'package:trackflow/core/app_flow/domain/services/session_service.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// Use case for triggering sync when app comes to foreground
@lazySingleton
class TriggerForegroundSyncUseCase {
  final SyncTrigger _syncTrigger;
  final SessionService _sessionService;

  TriggerForegroundSyncUseCase(this._syncTrigger, this._sessionService);

  Future<void> call() async {
    try {
      final sessionResult = await _sessionService.getCurrentSession();
      if (sessionResult.isRight()) {
        final session = sessionResult.getOrElse(
          () => UserSession.unauthenticated(),
        );
        if (session.currentUser != null) {
          await _syncTrigger.triggerForegroundSync(
            session.currentUser!.id.value,
          );
        }
      }
    } catch (e) {
      AppLogger.warning('Failed to trigger foreground sync: $e');
    }
  }
}
