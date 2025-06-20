import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart';
import 'package:trackflow/features/audio_comment/data/datasources/audio_comment_local_datasource.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';

@lazySingleton
class SyncAudioCommentsUseCase {
  final AudioCommentRemoteDataSource remote;
  final AudioCommentLocalDataSource local;

  SyncAudioCommentsUseCase(this.remote, this.local);

  Future<void> call() async {
    final List<AudioCommentDTO> comments = await remote.getAllComments();
    for (final comment in comments) {
      await local.cacheComment(comment);
    }
  }
}
