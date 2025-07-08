import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
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
  Future<TrackContext?> getTrackContext(String trackId) async {
    try {
      // Get the audio track
      final trackResult = await _audioTrackRepository.getTrackById(
        AudioTrackId.fromUniqueString(trackId),
      );

      return await trackResult.fold(
        (failure) async => null, // Track not found
        (track) async {
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
              // Project not found
            },
            (project) {
              projectName = project.name.value.getOrElse(
                () => 'Unknown Project',
              );
            },
          );

          return TrackContext(
            trackId: trackId,
            collaborator: collaborator,
            projectId: track.projectId.value,
            projectName: projectName,
            uploadedAt: track.createdAt,
            lastModified:
                track.createdAt, // Could be enhanced with actual last modified
            tags: [], // Could be enhanced with track tags
            description: null, // Could be enhanced with track descriptions
          );
        },
      );
    } catch (e) {
      // Return null on any error - the UI will handle gracefully
      return null;
    }
  }

  @override
  Stream<TrackContext> watchTrackContext(String trackId) {
    // For now, return a simple stream that emits once
    // This could be enhanced to watch for real-time changes
    return Stream.fromFuture(
      getTrackContext(trackId),
    ).where((context) => context != null).cast<TrackContext>();
  }
}
