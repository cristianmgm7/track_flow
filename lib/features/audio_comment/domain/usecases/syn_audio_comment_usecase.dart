import 'package:injectable/injectable.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';

@lazySingleton
class SyncAudioCommentsUseCase {
  final AudioCommentRemoteDataSource remote;
  final AudioCommentLocalDataSource local;
  final ProjectRemoteDataSource projectRemoteDataSource;
  final SessionStorage sessionStorage;

  SyncAudioCommentsUseCase(
    this.remote,
    this.local,
    this.projectRemoteDataSource,
    this.sessionStorage,
  );

  Future<void> call() async {
    final userId = sessionStorage.getUserId();
    if (userId == null) {
      await local.deleteAllComments();
      return;
    }

    final projectsEither = await projectRemoteDataSource.getUserProjects(
      userId,
    );
    await projectsEither.fold((failure) {}, (projects) async {
      await local.deleteAllComments();
      if (projects.isEmpty) {
        return;
      }
      final projectIds = projects.map((p) => p.id.value).toList();
      final List<AudioCommentDTO> comments = await remote
          .getCommentsByProjectIds(projectIds);
      for (final comment in comments) {
        await local.cacheComment(comment);
      }
    });
  }
}
