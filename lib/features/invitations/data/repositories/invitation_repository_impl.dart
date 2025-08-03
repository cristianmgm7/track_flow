import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/features/invitations/data/datasources/invitation_local_datasource.dart';
import 'package:trackflow/features/invitations/data/datasources/invitation_remote_datasource.dart';
import 'package:trackflow/features/invitations/data/models/invitation_dto.dart';
import 'package:trackflow/features/invitations/domain/entities/project_invitation.dart';
import 'package:trackflow/features/invitations/domain/entities/invitation_id.dart';
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart';
import 'package:trackflow/features/invitations/domain/value_objects/send_invitation_params.dart';
import 'package:trackflow/core/utils/app_logger.dart';

@LazySingleton(as: InvitationRepository)
class InvitationRepositoryImpl implements InvitationRepository {
  final InvitationLocalDataSource _localDataSource;
  final InvitationRemoteDataSource _remoteDataSource;
  final NetworkStateManager _networkStateManager;
  InvitationRepositoryImpl({
    required InvitationLocalDataSource localDataSource,
    required InvitationRemoteDataSource remoteDataSource,
    required NetworkStateManager networkStateManager,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _networkStateManager = networkStateManager;

  // Actor Methods (for performing actions)

  @override
  Future<Either<Failure, ProjectInvitation>> sendInvitation(
    SendInvitationParams params,
  ) async {
    try {
      // Create the invitation entity
      final invitation = ProjectInvitation(
        id: InvitationId(),
        projectId: params.projectId,
        invitedByUserId:
            params
                .invitedByUserId!, // Now guaranteed to be non-null from use case
        invitedUserId: params.invitedUserId,
        invitedEmail: params.invitedEmail,
        proposedRole: params.proposedRole,
        message: params.message,
        createdAt: DateTime.now(),
        expiresAt:
            params.expirationDuration != null
                ? DateTime.now().add(params.expirationDuration!)
                : DateTime.now().add(const Duration(days: 7)),
        status: InvitationStatus.pending,
      );

      // Convert to DTO
      final invitationDto = InvitationDto.fromDomain(invitation);

      // ONLINE-FIRST: Try to send to remote first
      final isConnected = await _networkStateManager.isConnected;
      if (isConnected) {
        final remoteResult = await _remoteDataSource.createInvitation(
          invitationDto,
        );

        return remoteResult.fold(
          (failure) {
            // ❌ REMOTE FAILED: Return error immediately
            // User needs to know the invitation wasn't sent
            AppLogger.error(
              'Failed to send invitation to remote: ${failure.message}',
              tag: 'InvitationRepository',
            );
            return Left(failure);
          },
          (remoteInvitation) async {
            // ✅ REMOTE SUCCESS: Save locally and return
            await _localDataSource.cacheInvitation(invitationDto);
            AppLogger.info(
              'Invitation sent successfully and cached locally',
              tag: 'InvitationRepository',
            );
            return Right(invitation);
          },
        );
      } else {
        // ❌ NO NETWORK: Fail immediately
        // User needs to know they can't send invitations offline
        AppLogger.warning(
          'Cannot send invitation: No internet connection',
          tag: 'InvitationRepository',
        );
        return Left(
          NetworkFailure(
            'No internet connection. Invitations require network.',
          ),
        );
      }
    } catch (e) {
      AppLogger.error(
        'Unexpected error sending invitation: $e',
        tag: 'InvitationRepository',
        error: e,
      );
      return Left(ServerFailure('Failed to send invitation: $e'));
    }
  }

  @override
  Future<Either<Failure, ProjectInvitation>> acceptInvitation(
    InvitationId invitationId,
  ) async {
    try {
      // Get the invitation
      final invitationResult = await getInvitationById(invitationId);

      return invitationResult.fold((failure) => Left(failure), (
        invitation,
      ) async {
        if (invitation == null) {
          return Left(ServerFailure('Invitation not found'));
        }

        // Accept the invitation using domain logic
        final acceptedInvitation = invitation.accept();
        final invitationDto = InvitationDto.fromDomain(acceptedInvitation);

        // ONLINE-FIRST: Try to update remote first
        final isConnected = await _networkStateManager.isConnected;
        if (isConnected) {
          final remoteResult = await _remoteDataSource.updateInvitation(
            invitationDto,
          );

          return remoteResult.fold(
            (failure) {
              // ❌ REMOTE FAILED: Return error immediately
              AppLogger.error(
                'Failed to accept invitation on remote: ${failure.message}',
                tag: 'InvitationRepository',
              );
              return Left(failure);
            },
            (_) async {
              // ✅ REMOTE SUCCESS: Update locally and return
              await _localDataSource.updateInvitation(invitationDto);
              AppLogger.info(
                'Invitation accepted successfully and cached locally',
                tag: 'InvitationRepository',
              );
              return Right(acceptedInvitation);
            },
          );
        } else {
          // ❌ NO NETWORK: Fail immediately
          AppLogger.warning(
            'Cannot accept invitation: No internet connection',
            tag: 'InvitationRepository',
          );
          return Left(
            NetworkFailure(
              'No internet connection. Accepting invitations require network.',
            ),
          );
        }
      });
    } catch (e) {
      AppLogger.error(
        'Unexpected error accepting invitation: $e',
        tag: 'InvitationRepository',
        error: e,
      );
      return Left(ServerFailure('Failed to accept invitation: $e'));
    }
  }

  @override
  Future<Either<Failure, ProjectInvitation>> declineInvitation(
    InvitationId invitationId,
  ) async {
    try {
      // Get the invitation
      final invitationResult = await getInvitationById(invitationId);

      return invitationResult.fold((failure) => Left(failure), (
        invitation,
      ) async {
        if (invitation == null) {
          return Left(ServerFailure('Invitation not found'));
        }

        // Decline the invitation using domain logic
        final declinedInvitation = invitation.decline();
        final invitationDto = InvitationDto.fromDomain(declinedInvitation);

        // ONLINE-FIRST: Try to update remote first
        final isConnected = await _networkStateManager.isConnected;
        if (isConnected) {
          final remoteResult = await _remoteDataSource.updateInvitation(
            invitationDto,
          );

          return remoteResult.fold(
            (failure) {
              // ❌ REMOTE FAILED: Return error immediately
              AppLogger.error(
                'Failed to decline invitation on remote: ${failure.message}',
                tag: 'InvitationRepository',
              );
              return Left(failure);
            },
            (_) async {
              // ✅ REMOTE SUCCESS: Update locally and return
              await _localDataSource.updateInvitation(invitationDto);
              AppLogger.info(
                'Invitation declined successfully and cached locally',
                tag: 'InvitationRepository',
              );
              return Right(declinedInvitation);
            },
          );
        } else {
          // ❌ NO NETWORK: Fail immediately
          AppLogger.warning(
            'Cannot decline invitation: No internet connection',
            tag: 'InvitationRepository',
          );
          return Left(
            NetworkFailure(
              'No internet connection. Declining invitations require network.',
            ),
          );
        }
      });
    } catch (e) {
      AppLogger.error(
        'Unexpected error declining invitation: $e',
        tag: 'InvitationRepository',
        error: e,
      );
      return Left(ServerFailure('Failed to decline invitation: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelInvitation(
    InvitationId invitationId,
  ) async {
    try {
      // Get the invitation
      final invitationResult = await getInvitationById(invitationId);

      return invitationResult.fold((failure) => Left(failure), (
        invitation,
      ) async {
        if (invitation == null) {
          return Left(ServerFailure('Invitation not found'));
        }

        // Cancel the invitation using domain logic
        final cancelledInvitation = invitation.cancel();
        final invitationDto = InvitationDto.fromDomain(cancelledInvitation);

        // ONLINE-FIRST: Try to update remote first
        final isConnected = await _networkStateManager.isConnected;
        if (isConnected) {
          final remoteResult = await _remoteDataSource.updateInvitation(
            invitationDto,
          );

          return remoteResult.fold(
            (failure) {
              // ❌ REMOTE FAILED: Return error immediately
              AppLogger.error(
                'Failed to cancel invitation on remote: ${failure.message}',
                tag: 'InvitationRepository',
              );
              return Left(failure);
            },
            (_) async {
              // ✅ REMOTE SUCCESS: Update locally and return
              await _localDataSource.updateInvitation(invitationDto);
              AppLogger.info(
                'Invitation cancelled successfully and cached locally',
                tag: 'InvitationRepository',
              );
              return const Right(unit);
            },
          );
        } else {
          // ❌ NO NETWORK: Fail immediately
          AppLogger.warning(
            'Cannot cancel invitation: No internet connection',
            tag: 'InvitationRepository',
          );
          return Left(
            NetworkFailure(
              'No internet connection. Cancelling invitations require network.',
            ),
          );
        }
      });
    } catch (e) {
      AppLogger.error(
        'Unexpected error cancelling invitation: $e',
        tag: 'InvitationRepository',
        error: e,
      );
      return Left(ServerFailure('Failed to cancel invitation: $e'));
    }
  }

  // Watcher Methods (for observing data)

  @override
  Future<Either<Failure, ProjectInvitation?>> getInvitationById(
    InvitationId invitationId,
  ) async {
    try {
      // Try to get from local cache first
      final localInvitation = await _localDataSource.getInvitationById(
        invitationId.value,
      );

      if (localInvitation != null) {
        return Right(localInvitation.toDomain());
      }

      // If not in local cache, try to sync from remote
      final syncResult = await syncInvitationFromRemote(invitationId);
      return syncResult.fold(
        (failure) => Left(failure),
        (invitation) => Right(invitation),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to get invitation: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<ProjectInvitation>>> watchPendingInvitations(
    UserId userId,
  ) async* {
    try {
      // Return local data immediately
      await for (final dtos in _localDataSource.watchPendingInvitationsForUser(
        userId.value,
      )) {
        yield Right(dtos.map((dto) => dto.toDomain()).toList());
      }
    } catch (e) {
      yield Left(DatabaseFailure('Failed to watch pending invitations: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<ProjectInvitation>>> watchSentInvitations(
    UserId userId,
  ) async* {
    try {
      // Return local data immediately
      await for (final dtos in _localDataSource.watchSentInvitationsByUser(
        userId.value,
      )) {
        yield Right(dtos.map((dto) => dto.toDomain()).toList());
      }
    } catch (e) {
      yield Left(DatabaseFailure('Failed to watch sent invitations: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getPendingInvitationsCount(UserId userId) async {
    try {
      // Get count from local cache
      final count = await _localDataSource.getPendingInvitationsCount(
        userId.value,
      );
      return Right(count);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to get pending invitations count: $e'),
      );
    }
  }

  // Helper Methods

  Future<Either<Failure, ProjectInvitation?>> syncInvitationFromRemote(
    InvitationId invitationId,
  ) async {
    try {
      final isConnected = await _networkStateManager.isConnected;
      if (!isConnected) {
        return Left(DatabaseFailure('No internet connection'));
      }

      // Get invitation from remote data source
      final remoteResult = await _remoteDataSource.getInvitationById(
        invitationId.value,
      );

      return remoteResult.fold((failure) => Left(failure), (
        remoteInvitation,
      ) async {
        // Cache the invitation locally
        await _localDataSource.cacheInvitation(remoteInvitation);
        return Right(remoteInvitation.toDomain());
      });
    } catch (e) {
      return Left(DatabaseFailure('Failed to sync invitation from remote: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCache() async {
    try {
      await _localDataSource.clearCache();
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to clear invitations cache: $e'));
    }
  }
}
