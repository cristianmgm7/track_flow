import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_cache/domain/services/download_management_service.dart';

@injectable
class DownloadTrackManagedUseCase {
  final DownloadManagementService _downloadService;

  DownloadTrackManagedUseCase(this._downloadService);

  Future<Either<Failure, Unit>> call({
    required String trackId,
    required String trackUrl,
    required String trackName,
    DownloadPriority priority = DownloadPriority.normal,
  }) async {
    final request = DownloadTaskRequest(
      trackId: trackId,
      trackUrl: trackUrl,
      trackName: trackName,
      priority: priority,
    );
    
    return await _downloadService.downloadTrack(request);
  }
}