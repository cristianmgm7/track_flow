import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_cache_repository.dart';

@injectable
class GetCachedAudioPath {
  final AudioCacheRepository _repository;

  const GetCachedAudioPath(this._repository);

  Future<String> call(String trackUrl) async {
    return await _repository.getCachedAudioPath(trackUrl);
  }
}