import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_cache/domain/services/download_management_service.dart';

@injectable
class GetDownloadProgressUseCase {
  final DownloadManagementService _downloadService;

  GetDownloadProgressUseCase(this._downloadService);

  Stream<DownloadProgressInfo> call(String trackId) {
    return _downloadService.getDownloadProgress(trackId);
  }

  DownloadStatus getStatus(String trackId) {
    return _downloadService.getDownloadStatus(trackId);
  }
}