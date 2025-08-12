import 'package:injectable/injectable.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio_background/just_audio_background.dart';

/// Initializes audio background capabilities and audio session
///
/// - Configures lock screen/notification media controls (Android)
/// - Enables proper audio focus handling via AudioSession (iOS/Android)
@lazySingleton
class AudioBackgroundInitializer {
  const AudioBackgroundInitializer();

  Future<void> initialize() async {
    // Initialize background audio/notification integration
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.trackflow.playback',
      androidNotificationChannelName: 'Playback',
      androidNotificationOngoing: true,
    );

    // Configure system audio session for music playback
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }
}


