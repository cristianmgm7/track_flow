import 'package:injectable/injectable.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart';

@lazySingleton
class SyncAudioCommentsUseCase {
  final AudioCommentRemoteDataSource _audioCommentRemoteDataSource;
  final AudioCommentLocalDataSource _audioCommentLocalDataSource;
  final ProjectRemoteDataSource _projectRemoteDataSource;
  final SessionStorage _sessionStorage;
  final AudioTrackRemoteDataSource _audioTrackRemoteDataSource;

  SyncAudioCommentsUseCase(
    this._audioCommentRemoteDataSource,
    this._audioCommentLocalDataSource,
    this._projectRemoteDataSource,
    this._sessionStorage,
    this._audioTrackRemoteDataSource,
  );

  Future<void> call() async {
    final userId = await _sessionStorage.getUserId(); // Now async - prevents race conditions
    if (userId == null) {
      // DON'T delete comments - preserve existing data when no userId
      return;
    }

    final projectsEither = await _projectRemoteDataSource.getUserProjects(
      userId,
    );
    await projectsEither.fold((failure) {}, (projects) async {
      await _audioCommentLocalDataSource.deleteAllComments();
      if (projects.isEmpty) {
        return;
      }
      final projectIds = projects.map((p) => p.id).toList();
      final allTracks = await _audioTrackRemoteDataSource.getTracksByProjectIds(
        projectIds,
      );
      if (allTracks.isEmpty) {
        return;
      }
      for (final track in allTracks) {
        final comments = await _audioCommentRemoteDataSource
            .getCommentsByTrackId(track.id.value);
        for (final comment in comments) {
          await _audioCommentLocalDataSource.cacheComment(comment);
        }
      }
    });
  }
}
