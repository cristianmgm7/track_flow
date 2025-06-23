import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_local_datasource.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart';
import 'package:rxdart/rxdart.dart';

class ProjectDetailBundle {
  final List<AudioTrack> tracks;
  final List<UserProfile> collaborators;
  final List<AudioComment> comments;

  ProjectDetailBundle({
    required this.tracks,
    required this.collaborators,
    required this.comments,
  });
}

@lazySingleton
class WatchProjectDetailUseCase {
  final AudioTrackLocalDataSource tracksLocal;
  final UserProfileLocalDataSource userProfilesLocal;
  final AudioCommentLocalDataSource commentsLocal;

  WatchProjectDetailUseCase(
    this.tracksLocal,
    this.userProfilesLocal,
    this.commentsLocal,
  );

  Stream<ProjectDetailBundle> call({
    required String projectId,
    required List<String> collaboratorIds,
  }) {
    return Rx.combineLatest3<
      List<AudioTrack>,
      List<UserProfile>,
      List<AudioComment>,
      ProjectDetailBundle
    >(
      tracksLocal
          .watchTracksByProject(projectId)
          .map((dtos) => dtos.map((dto) => dto.toDomain()).toList()),
      userProfilesLocal
          .watchUserProfilesByIds(collaboratorIds)
          .map((dtos) => dtos.map((dto) => dto.toDomain()).toList()),
      commentsLocal
          .watchCommentsByTrack(projectId)
          .map((dtos) => dtos.map((dto) => dto.toDomain()).toList()),
      (tracks, collaborators, comments) => ProjectDetailBundle(
        tracks: tracks,
        collaborators: collaborators,
        comments: comments,
      ),
    );
  }
}
