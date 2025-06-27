import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_cache/domain/services/download_management_service.dart';

@injectable
class CancelDownloadUseCase {
  final DownloadManagementService _downloadService;

  CancelDownloadUseCase(this._downloadService);

  Future<Either<Failure, Unit>> call(String trackId) async {
    return await _downloadService.cancelDownload(trackId);
  }
}