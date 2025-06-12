import 'package:just_audio/just_audio.dart';

class AudioUtils {
  static Future<Duration> getAudioDuration(String filePath) async {
    final player = AudioPlayer();
    try {
      await player
          .setFilePath(filePath)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Audio loading timed out'),
          );
      return player.duration ?? Duration.zero;
    } finally {
      await player.dispose();
    }
  }
}
