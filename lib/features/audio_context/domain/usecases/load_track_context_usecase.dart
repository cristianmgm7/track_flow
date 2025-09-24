import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart'
    as profile;
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

import '../entities/track_context.dart';

/// Use case for loading track business context
/// Follows clean architecture principles by encapsulating business logic
@injectable
class LoadTrackContextUseCase {
  const LoadTrackContextUseCase({
    required AudioTrackRepository audioTrackRepository,
    required TrackVersionRepository trackVersionRepository,
    required UserProfileRepository userProfileRepository,
    required ProjectsRepository projectsRepository,
  }) : _audioTrackRepository = audioTrackRepository,
       _trackVersionRepository = trackVersionRepository,
       _userProfileRepository = userProfileRepository,
       _projectsRepository = projectsRepository;

  final AudioTrackRepository _audioTrackRepository;
  final TrackVersionRepository _trackVersionRepository;
  final UserProfileRepository _userProfileRepository;
  final ProjectsRepository _projectsRepository;

  /// Load context for a specific track.
  /// Returns the best available business context, gracefully degrading when
  /// ancillary data (collaborator, project, active version) cannot be fetched.
  Future<Either<Failure, TrackContext>> call(AudioTrackId trackId) async {
    final trackResult = await _audioTrackRepository.getTrackById(trackId);

    return await trackResult.fold((failure) => Left(failure), (track) async {
      final collaborator = await _loadCollaborator(track.uploadedBy);
      final projectName = await _loadProjectName(track.projectId);
      final activeVersion = await _loadActiveVersion(trackId, track);

      final mappedDuration = _mapDuration(
        activeVersion?.durationMs,
        track.duration,
      );

      final context = TrackContext(
        trackId: track.id.value,
        collaborator: collaborator,
        projectId: track.projectId.value,
        projectName: projectName,
        uploadedAt: track.createdAt,
        lastModified: activeVersion?.createdAt ?? track.createdAt,
        tags: const [],
        description: null,
        activeVersionId: activeVersion?.id.value,
        activeVersionNumber: activeVersion?.versionNumber,
        activeVersionLabel: activeVersion?.label,
        activeVersionStatus: activeVersion?.status,
        activeVersionDuration: mappedDuration,
        activeVersionFileUrl: activeVersion?.fileRemoteUrl,
      );

      return Right(context);
    });
  }

  Future<TrackContextCollaborator?> _loadCollaborator(UserId uploadedBy) async {
    final result = await _userProfileRepository.getUserProfile(uploadedBy);

    return result.fold(
      (_) => null,
      (profile.UserProfile? user) =>
          user != null ? _mapUserProfile(user) : null,
    );
  }

  Future<String?> _loadProjectName(ProjectId projectId) async {
    final result = await _projectsRepository.getProjectById(projectId);

    return result.fold(
      (_) => null,
      (Project project) => project.name.value.fold((_) => null, (name) => name),
    );
  }

  Future<TrackVersion?> _loadActiveVersion(
    AudioTrackId trackId,
    AudioTrack track,
  ) async {
    final activeVersionResult = await _trackVersionRepository.getActiveVersion(
      trackId,
    );

    final activeVersion = activeVersionResult.fold<TrackVersion?>(
      (_) => null,
      (version) => version,
    );

    if (activeVersion != null) {
      return activeVersion;
    }

    final activeVersionId = track.activeVersionId;
    if (activeVersionId == null) {
      return null;
    }

    final fallbackResult = await _trackVersionRepository.getById(
      activeVersionId,
    );
    return fallbackResult.fold<TrackVersion?>(
      (_) => null,
      (version) => version,
    );
  }

  TrackContextCollaborator _mapUserProfile(profile.UserProfile user) {
    return TrackContextCollaborator(
      id: user.id.value,
      name: user.name,
      email: user.email,
      avatarUrl: user.avatarUrl,
    );
  }

  Duration? _mapDuration(int? durationMs, Duration fallback) {
    if (durationMs != null && durationMs > 0) {
      return Duration(milliseconds: durationMs);
    }
    if (fallback.inMilliseconds > 0) {
      return fallback;
    }
    return null;
  }
}
