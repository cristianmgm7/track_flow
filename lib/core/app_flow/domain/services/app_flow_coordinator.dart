import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/app_flow/domain/entities/app_flow_state.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/session/domain/entities/session_state.dart';
import 'package:trackflow/core/session/domain/services/session_service.dart';
import 'package:trackflow/core/session/domain/entities/user_session.dart';
import 'package:trackflow/core/sync/domain/services/sync_data_manager.dart';
import 'package:trackflow/core/sync/domain/entities/sync_state.dart';

/// Coordinates application flow by combining session and sync information
///
/// This service is responsible ONLY for orchestrating the flow.
/// It does NOT implement business logic or make decisions about navigation.
@lazySingleton
class AppFlowCoordinator {
  final SessionService _sessionService;
  final SyncDataManager _syncDataManager;

  AppFlowCoordinator({
    required SessionService sessionService,
    required SyncDataManager syncDataManager,
  }) : _sessionService = sessionService,
       _syncDataManager = syncDataManager;

  /// Determine the current application flow state
  ///
  /// This method combines session and sync information to create
  /// a unified flow state for navigation decisions.
  Future<Either<Failure, AppFlowState>> determineAppFlow() async {
    try {
      // Get current session and sync state in parallel
      final results = await Future.wait([
        _sessionService.getCurrentSession(),
        _syncDataManager.getCurrentSyncState(),
      ]);

      final sessionResult = results[0] as Either<Failure, UserSession>;
      final syncResult = results[1] as Either<Failure, SyncState>;

      // Handle session result
      return await sessionResult.fold(
        (sessionFailure) async {
          return Left(sessionFailure);
        },
        (session) async {
          // Handle sync result
          return await syncResult.fold(
            (syncFailure) async {
              // If sync fails, still return session state but with error
              return Right(
                AppFlowState.error(
                  error: 'Sync failed: ${syncFailure.message}',
                  session: session,
                ),
              );
            },
            (syncState) async {
              // Map combined state to app flow state
              return Right(_mapToAppFlowState(session, syncState));
            },
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to determine app flow: $e'));
    }
  }

  /// Watch for app flow changes
  ///
  /// This method combines session and sync streams to provide
  /// a unified stream of app flow states.
  Stream<AppFlowState> watchAppFlow() {
    // For now, return a simple stream
    // In a real implementation, this would combine session and sync streams
    return Stream.value(const AppFlowState.loading());
  }

  /// Map session and sync state to app flow state
  ///
  /// This is a pure mapping function with no business logic.
  AppFlowState _mapToAppFlowState(UserSession session, SyncState syncState) {
    // Handle session state
    if (session.state == SessionState.unauthenticated) {
      return const AppFlowState.unauthenticated();
    }

    if (session.state == SessionState.error) {
      return AppFlowState.error(
        error: session.errorMessage ?? 'Session error',
        session: session,
        syncState: syncState,
      );
    }

    if (session.state == SessionState.authenticated) {
      if (session.needsOnboarding || session.needsProfileSetup) {
        return AppFlowState.authenticated(session: session);
      }
    }

    if (session.state == SessionState.ready) {
      return AppFlowState.ready(session: session, syncState: syncState);
    }

    // Default to loading state
    return AppFlowState.loading(session: session, syncState: syncState);
  }

  /// Trigger background sync if user is ready
  ///
  /// This method coordinates between session and sync without
  /// implementing the actual sync logic.
  Future<Either<Failure, Unit>> triggerBackgroundSyncIfReady() async {
    final sessionResult = await _sessionService.getCurrentSession();

    return await sessionResult.fold((failure) async => Left(failure), (
      session,
    ) async {
      if (session.state == SessionState.ready) {
        return await _syncDataManager.performIncrementalSync();
      }
      return const Right(unit);
    });
  }

  /// Sign out and reset sync
  ///
  /// This method coordinates the sign out process across
  /// both session and sync systems.
  Future<Either<Failure, Unit>> signOut() async {
    try {
      // Sign out from session
      final sessionResult = await _sessionService.signOut();

      // Reset sync state (regardless of session result)
      await _syncDataManager.resetSyncState();

      return sessionResult;
    } catch (e) {
      return Left(ServerFailure('Sign out failed: $e'));
    }
  }
}
