import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_player/domain/services/audio_source_resolver.dart';
import 'package:trackflow/features/audio_player/domain/models/audio_source_enum.dart';

@injectable
class CheckCacheStatusUseCase {
  final AudioSourceResolver _audioSourceResolver;

  CheckCacheStatusUseCase(this._audioSourceResolver);

  Future<CacheStatus> call(String trackUrl) async {
    return await _audioSourceResolver.getCacheStatus(trackUrl);
  }
}