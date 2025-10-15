import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../../core/error/failures.dart';
import '../../../audio_player/domain/entities/audio_source.dart';
import '../../../audio_player/domain/entities/audio_track_metadata.dart';
import '../../../audio_player/domain/services/audio_player_service.dart';
import '../entities/voice_memo.dart';

/// Play a voice memo using the centralized audio player
@lazySingleton
class PlayVoiceMemoUseCase {
  final AudioPlayerService _audioPlayerService;

  PlayVoiceMemoUseCase(this._audioPlayerService);

  Future<Either<Failure, Unit>> call(VoiceMemo memo) async {
    try {
      // Create audio metadata for the memo
      final metadata = AudioTrackMetadata(
        id: AudioTrackId.fromUniqueString(memo.id.value),
        title: memo.title,
        artist: 'Voice Memo',
        duration: memo.duration,
      );

      // Create audio source
      final audioSource = AudioSource(
        url: memo.fileLocalPath,
        metadata: metadata,
      );

      // Play via audio player service
      await _audioPlayerService.playbackService.play(audioSource);

      return const Right(unit);
    } catch (e) {
      return Left(StorageFailure('Failed to play voice memo: $e'));
    }
  }
}
