import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import '../../../audio_track/domain/repositories/audio_track_repository.dart';
import '../../../projects/domain/repositories/projects_repository.dart';
import '../../domain/entities/track_context.dart';
import '../../domain/services/audio_context_service.dart';

/// Implementation of AudioContextService that resolves business context for tracks
/// Composes data from multiple repositories to provide rich track context
@LazySingleton(as: AudioContextService)
class AudioContextServiceImpl implements AudioContextService {
  const AudioContextServiceImpl({
    required UserProfileRepository userProfileRepository,
    required AudioTrackRepository audioTrackRepository,
    required ProjectsRepository projectsRepository,
  }) : _userProfileRepository = userProfileRepository,
       _audioTrackRepository = audioTrackRepository,
       _projectsRepository = projectsRepository;

  final UserProfileRepository _userProfileRepository;
  final AudioTrackRepository _audioTrackRepository;
  final ProjectsRepository _projectsRepository;

  @override
  Future<Either<Failure, TrackContext>> getTrackContext(
    AudioTrackId trackId,
  ) async {
    try {
      // Get the audio track
      final trackResult = await _audioTrackRepository.getTrackById(trackId);

      // If track not found, return the failure directly
      if (trackResult.isLeft()) {
        return trackResult.fold(
          (failure) => Left(failure), // Extract failure and wrap in correct type
          (_) => throw Exception('Unexpected state'), // Should never happen
        );
      }

      // Extract the track from the Either
      final track = trackResult.fold(
        (_) => throw Exception('Unexpected state'), // Should never happen
        (track) => track,
      );

      // Resolve user profile for the track uploader
      UserProfile? collaborator;
      final userResult = await _userProfileRepository.getUserProfile(
        track.uploadedBy,
      );
      userResult.fold(
        (failure) {
          // User profile not found, create minimal profile with ID
          collaborator = UserProfile(
            id: track.uploadedBy.value,
            name: track.uploadedBy.value, // Fallback to ID
          );
        },
        (userProfile) {
          if (userProfile != null) {
            collaborator = UserProfile(
              id: userProfile.id.value,
              name: userProfile.name,
              email: userProfile.email,
              avatarUrl: userProfile.avatarUrl,
              role: null, // Could be enhanced with project-specific roles
            );
          }
        },
      );

      // Resolve project information
      String? projectName;
      final projectResult = await _projectsRepository.getProjectById(
        track.projectId,
      );
      projectResult.fold(
        (failure) {
          // Project not found - continue with null project name
        },
        (project) {
          projectName = project.name.value.getOrElse(() => 'Unknown Project');
        },
      );

      final trackContext = TrackContext(
        trackId: trackId.value,
        collaborator: collaborator,
        projectId: track.projectId.value,
        projectName: projectName,
        uploadedAt: track.createdAt,
        lastModified:
            track.createdAt, // Could be enhanced with actual last modified
        tags: [], // Could be enhanced with track tags
        description: null, // Could be enhanced with track descriptions
      );

      return Right(trackContext);
    } catch (e) {
      // Return failure on any unexpected error
      return Left(
        ServerFailure('Failed to get track context: ${e.toString()}'),
      );
    }
  }
}
