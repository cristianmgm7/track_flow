import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_player/domain/services/playback_service.dart';

@lazySingleton
class SeekToPositionUseCase {
  final PlaybackService _playbackService;

  SeekToPositionUseCase(this._playbackService);

  Future<void> call(Duration position) async {
    await _playbackService.seek(position);
  }
}