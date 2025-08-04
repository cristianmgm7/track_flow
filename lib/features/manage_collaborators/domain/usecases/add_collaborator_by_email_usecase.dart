import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/find_user_by_email_usecase.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart';
import 'package:trackflow/core/notifications/domain/services/notification_service.dart';

class AddCollaboratorByEmailParams extends Equatable {
  final ProjectId projectId;
  final String email;
  final ProjectRole role;

  const AddCollaboratorByEmailParams({
    required this.projectId,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [projectId, email, role];
}

/// Use case that handles the complete flow of adding a collaborator by email:
/// 1. Find user by email
/// 2. Add collaborator to project
/// 3. Create notification for the added user
///
/// This follows Clean Architecture by keeping all business logic in the domain layer
@lazySingleton
class AddCollaboratorByEmailUseCase {
  final FindUserByEmailUseCase _findUserByEmailUseCase;
  final AddCollaboratorToProjectUseCase _addCollaboratorUseCase;
  final NotificationService _notificationService;

  AddCollaboratorByEmailUseCase(
    this._findUserByEmailUseCase,
    this._addCollaboratorUseCase,
    this._notificationService,
  );

  Future<Either<Failure, Project>> call(
    AddCollaboratorByEmailParams params,
  ) async {
    try {
      // 1. Find user by email
      final userResult = await _findUserByEmailUseCase(params.email);

      return await userResult.fold((failure) async => Left(failure), (
        user,
      ) async {
        // Handle case where user doesn't exist
        if (user == null) {
          return Left(
            ServerFailure('User with email ${params.email} not found'),
          );
        }

        // 2. Add collaborator to project
        final addResult = await _addCollaboratorUseCase(
          AddCollaboratorToProjectParams(
            projectId: params.projectId,
            collaboratorId: user.id,
          ),
        );

        return await addResult.fold((failure) async => Left(failure), (
          project,
        ) async {
          // 3. Create notification for the added user
          try {
            await _notificationService.createCollaboratorJoinedNotification(
              recipientId: user.id,
              projectId: project.id,
              projectName:
                  project.name.toString(), // Convert ProjectName to String
              collaboratorName: user.name,
            );
          } catch (e) {
            // Don't fail the whole operation if notification fails
            // This is a business decision - collaborator addition succeeded
            // but notification failed (could be network issue, etc.)
            // In production, you might want to log this or retry later
          }

          // Return successful result
          return Right(project);
        });
      });
    } catch (e) {
      return Left(ServerFailure('Failed to add collaborator by email: $e'));
    }
  }
}
