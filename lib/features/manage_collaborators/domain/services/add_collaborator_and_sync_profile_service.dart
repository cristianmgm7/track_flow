import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profiles_cache_repository.dart';

@lazySingleton
class AddCollaboratorAndSyncProfileService {
  final AddCollaboratorToProjectUseCase _addCollaboratorUseCase;
  final UserProfileCacheRepository _userProfileCacheRepository;

  AddCollaboratorAndSyncProfileService(
    this._addCollaboratorUseCase,
    this._userProfileCacheRepository,
  );

  Future<Either<Failure, Project>> call(
    AddCollaboratorToProjectParams params,
  ) async {
    final result = await _addCollaboratorUseCase(params);
    if (result.isRight()) {
      final profilesResult = await _userProfileCacheRepository.getUserProfilesByIds([
        params.collaboratorId,
      ]);
      profilesResult.fold((failure) => null, (profiles) async {
        if (profiles.isNotEmpty) {
          await _userProfileCacheRepository.cacheUserProfiles([profiles.first]);
        }
      });
    }
    return result;
  }
}
