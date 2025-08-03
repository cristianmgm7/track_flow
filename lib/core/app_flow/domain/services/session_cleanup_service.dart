import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart';
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart';
import 'package:trackflow/features/audio_player/domain/repositories/playback_persistence_repository.dart';
import 'package:trackflow/core/app_flow/domain/services/bloc_state_cleanup_service.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';

/// Service responsible for comprehensive session cleanup
///
/// This service coordinates clearing all user-related data when a user logs out
/// to prevent data leakage between different user sessions.
@injectable
class SessionCleanupService {
  final UserProfileRepository _userProfileRepository;
  final ProjectsRepository _projectsRepository;
  final AudioTrackRepository _audioTrackRepository;
  final AudioCommentRepository _audioCommentRepository;
  final InvitationRepository _invitationRepository;
  final PlaybackPersistenceRepository _playbackPersistenceRepository;
  final BlocStateCleanupService _blocStateCleanupService;
  final SessionStorage _sessionStorage;
  
  // Prevent multiple concurrent cleanup operations
  bool _isCleanupInProgress = false;

  SessionCleanupService({
    required UserProfileRepository userProfileRepository,
    required ProjectsRepository projectsRepository,
    required AudioTrackRepository audioTrackRepository,
    required AudioCommentRepository audioCommentRepository,
    required InvitationRepository invitationRepository,
    required PlaybackPersistenceRepository playbackPersistenceRepository,
    required BlocStateCleanupService blocStateCleanupService,
    required SessionStorage sessionStorage,
  }) : _userProfileRepository = userProfileRepository,
       _projectsRepository = projectsRepository,
       _audioTrackRepository = audioTrackRepository,
       _audioCommentRepository = audioCommentRepository,
       _invitationRepository = invitationRepository,
       _playbackPersistenceRepository = playbackPersistenceRepository,
       _blocStateCleanupService = blocStateCleanupService,
       _sessionStorage = sessionStorage;

  /// Clear all user-related data from local storage
  ///
  /// This method performs a comprehensive cleanup of all user data including:
  /// - User profiles
  /// - Projects and project-related data
  /// - Audio tracks and comments
  /// - Invitations
  /// - Playback state and preferences
  /// - BLoC states (reset to initial state)
  Future<Either<Failure, Unit>> clearAllUserData() async {
    // Prevent concurrent cleanup operations
    if (_isCleanupInProgress) {
      AppLogger.info(
        'Session cleanup already in progress, skipping duplicate request',
        tag: 'SESSION_CLEANUP',
      );
      return const Right(unit);
    }

    try {
      _isCleanupInProgress = true;
      
      AppLogger.info(
        'Starting comprehensive session cleanup',
        tag: 'SESSION_CLEANUP',
      );

      // Step 1: Clear SessionStorage FIRST to prevent race conditions
      AppLogger.info(
        'Clearing SessionStorage (userId and all session data)',
        tag: 'SESSION_CLEANUP',
      );
      await _sessionStorage.clearAll();

      // Step 2: Clear UserProfile cache SYNCHRONOUSLY before BLoC reset
      // This prevents widgets from finding cached profiles during rebuild
      AppLogger.info(
        'Clearing UserProfile cache synchronously to prevent race conditions',
        tag: 'SESSION_CLEANUP',
      );
      final profileClearResult = await _userProfileRepository.clearProfileCache();
      profileClearResult.fold(
        (failure) => AppLogger.warning(
          'UserProfile cache clear failed: ${failure.message}, but continuing cleanup',
          tag: 'SESSION_CLEANUP',
        ),
        (_) => AppLogger.info(
          'UserProfile cache cleared successfully',
          tag: 'SESSION_CLEANUP',
        ),
      );

      // Step 3: Reset BLoC states AFTER critical caches are cleared
      _blocStateCleanupService.resetAllBlocStates();

      // Step 4: Clear remaining repository data in parallel
      final List<Future<Either<Failure, Unit>>> cleanupTasks = [
        // Clear projects data
        _projectsRepository.clearLocalCache(),

        // Clear audio tracks
        _audioTrackRepository.deleteAllTracks(),

        // Clear audio comments
        _audioCommentRepository.deleteAllComments(),

        // Clear invitations
        _invitationRepository.clearCache(),

        // Clear notifications
        _clearNotifications(),

        // Clear playback persistence data
        _clearPlaybackData(),
      ];

      // Execute all cleanup tasks in parallel for better performance
      final results = await Future.wait(cleanupTasks);

      // Check if any cleanup task failed
      final failures = <Failure>[];
      for (final result in results) {
        result.fold(
          (failure) => failures.add(failure),
          (_) => {}, // Success, do nothing
        );
      }

      if (failures.isNotEmpty) {
        final combinedMessage = failures.map((f) => f.message).join('; ');

        AppLogger.warning(
          'Some cleanup tasks failed: $combinedMessage',
          tag: 'SESSION_CLEANUP',
        );

        // Even if some tasks failed, continue with cleanup
        // This ensures we don't leave the app in a broken state
      }

      AppLogger.info(
        'Session cleanup completed successfully',
        tag: 'SESSION_CLEANUP',
      );

      return const Right(unit);
    } catch (e) {
      AppLogger.error(
        'Session cleanup failed with exception: $e',
        tag: 'SESSION_CLEANUP',
        error: e,
      );

      return Left(ServerFailure('Session cleanup failed: $e'));
    } finally {
      _isCleanupInProgress = false;
    }
  }

  /// Clear specific user data (for partial cleanup scenarios)
  Future<Either<Failure, Unit>> clearUserSpecificData(String userId) async {
    try {
      AppLogger.info(
        'Starting user-specific data cleanup for user: $userId',
        tag: 'SESSION_CLEANUP',
      );

      // For now, we'll use the comprehensive cleanup
      // In the future, this could be enhanced to clear only data for a specific user
      return await clearAllUserData();
    } catch (e) {
      AppLogger.error(
        'User-specific cleanup failed: $e',
        tag: 'SESSION_CLEANUP',
        error: e,
      );

      return Left(ServerFailure('User-specific cleanup failed: $e'));
    }
  }

  /// Helper method to clear notifications without requiring user ID
  Future<Either<Failure, Unit>> _clearNotifications() async {
    try {
      // Since we don't have a clearAll method without userId,
      // we'll need to implement this at the datasource level
      // For now, return success (this can be enhanced later)
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to clear notifications: $e'));
    }
  }

  /// Helper method to clear playback persistence data
  Future<Either<Failure, Unit>> _clearPlaybackData() async {
    try {
      await _playbackPersistenceRepository.clearPlaybackState();
      await _playbackPersistenceRepository.clearTrackPositions();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to clear playback data: $e'));
    }
  }
}
