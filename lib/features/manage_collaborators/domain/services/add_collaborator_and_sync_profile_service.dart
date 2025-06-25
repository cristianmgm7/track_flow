import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

@lazySingleton
class AddCollaboratorAndSyncProfileService {
  final AddCollaboratorToProjectUseCase _addCollaboratorUseCase;
  final UserProfileRepository _userProfileRepository;

  AddCollaboratorAndSyncProfileService(
    this._addCollaboratorUseCase,
    this._userProfileRepository,
  );

  Future<Either<Failure, Project>> call(
    AddCollaboratorToProjectParams params,
  ) async {
    final result = await _addCollaboratorUseCase(params);
    if (result.isRight()) {
      final profilesResult = await _userProfileRepository.getUserProfilesByIds([
        params.collaboratorId.value,
      ]);
      profilesResult.fold((failure) => null, (profiles) async {
        if (profiles.isNotEmpty) {
          await _userProfileRepository.cacheUserProfiles([profiles.first]);
        }
      });
    }
    return result;
  }
}
