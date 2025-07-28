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

      // OFFLINE-FIRST: Save locally immediately
      await _localDataSource.cacheInvitation(invitationDto);

      // Try to sync to remote if connected
      try {
        final isConnected = await _networkStateManager.isConnected;
        if (isConnected) {
          final remoteResult = await _remoteDataSource.createInvitation(
            invitationDto,
          );
          remoteResult.fold(
            (failure) {
              AppLogger.warning(
                'Failed to sync invitation to remote: ${failure.message}',
                tag: 'InvitationRepository',
              );
              // Don't fail the operation - local save was successful
            },
            (_) {
              AppLogger.info(
                'Invitation synced to remote successfully',
                tag: 'InvitationRepository',
              );
            },
          );
        }
      } catch (e) {
        AppLogger.warning(
          'Background sync failed, but local save was successful: $e',
          tag: 'InvitationRepository',
        );
        // Don't fail the operation - local save was successful
      }

      return Right(invitation);
    } catch (e) {
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

        // Update locally immediately
        await _localDataSource.updateInvitation(invitationDto);

        // Try to sync to remote if connected
        try {
          final isConnected = await _networkStateManager.isConnected;
          if (isConnected) {
            final remoteResult = await _remoteDataSource.updateInvitation(
              invitationDto,
            );
            remoteResult.fold(
              (failure) {
                AppLogger.warning(
                  'Failed to sync accepted invitation to remote: ${failure.message}',
                  tag: 'InvitationRepository',
                );
              },
              (_) {
                AppLogger.info(
                  'Accepted invitation synced to remote successfully',
                  tag: 'InvitationRepository',
                );
              },
            );
          }
        } catch (e) {
          AppLogger.warning(
            'Background sync failed, but local update was successful: $e',
            tag: 'InvitationRepository',
          );
        }

        return Right(acceptedInvitation);
      });
    } catch (e) {
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

        // Update locally immediately
        await _localDataSource.updateInvitation(invitationDto);

        // Try to sync to remote if connected
        try {
          final isConnected = await _networkStateManager.isConnected;
          if (isConnected) {
            final remoteResult = await _remoteDataSource.updateInvitation(
              invitationDto,
            );
            remoteResult.fold(
              (failure) {
                AppLogger.warning(
                  'Failed to sync declined invitation to remote: ${failure.message}',
                  tag: 'InvitationRepository',
                );
              },
              (_) {
                AppLogger.info(
                  'Declined invitation synced to remote successfully',
                  tag: 'InvitationRepository',
                );
              },
            );
          }
        } catch (e) {
          AppLogger.warning(
            'Background sync failed, but local update was successful: $e',
            tag: 'InvitationRepository',
          );
        }

        return Right(declinedInvitation);
      });
    } catch (e) {
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

        // Update locally immediately
        await _localDataSource.updateInvitation(invitationDto);

        // Try to sync to remote if connected
        try {
          final isConnected = await _networkStateManager.isConnected;
          if (isConnected) {
            final remoteResult = await _remoteDataSource.updateInvitation(
              invitationDto,
            );
            remoteResult.fold(
              (failure) {
                AppLogger.warning(
                  'Failed to sync cancelled invitation to remote: ${failure.message}',
                  tag: 'InvitationRepository',
                );
              },
              (_) {
                AppLogger.info(
                  'Cancelled invitation synced to remote successfully',
                  tag: 'InvitationRepository',
                );
              },
            );
          }
        } catch (e) {
          AppLogger.warning(
            'Background sync failed, but local update was successful: $e',
            tag: 'InvitationRepository',
          );
        }

        return Right(unit);
      });
    } catch (e) {
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
}
