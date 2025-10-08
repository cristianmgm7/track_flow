import 'package:injectable/injectable.dart';
import 'package:trackflow/core/app_flow/domain/entities/user_session.dart';
import 'package:trackflow/core/app_flow/domain/services/session_service.dart';
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// Use case for triggering initial sync on app startup
///
/// This performs:
/// 1. Push pending operations (upstream sync)
/// 2. Pull critical data for startup (downstream sync)
@lazySingleton
class TriggerStartupSyncUseCase {
  final BackgroundSyncCoordinator _syncTrigger;
  final SessionService _sessionService;

  TriggerStartupSyncUseCase(this._syncTrigger, this._sessionService);

  Future<void> call() async {
    try {
      final sessionResult = await _sessionService.getCurrentSession();
      if (sessionResult.isRight()) {
        final session = sessionResult.getOrElse(
          () => UserSession.unauthenticated(),
        );
        if (session.currentUser != null) {
          await _syncTrigger.triggerStartupSync(
            session.currentUser!.id.value,
          );
        }
      }
    } catch (e) {
      AppLogger.warning('Failed to trigger startup sync: $e');
    }
  }
}
