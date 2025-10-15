import 'package:injectable/injectable.dart';
import 'package:audio_session/audio_session.dart';

/// Initializes audio background capabilities and audio session
///
/// - Configures lock screen/notification media controls (Android)
/// - Enables proper audio focus handling via AudioSession (iOS/Android)
@lazySingleton
class AudioBackgroundInitializer {
  const AudioBackgroundInitializer();

  Future<void> initialize() async {
    // Temporarily disable just_audio_background to allow multiple players (track + comments)
    // Background notifications will be reintroduced via audio_service for the main track
    // await JustAudioBackground.init(
    //   androidNotificationChannelId: 'com.trackflow.playback',
    //   androidNotificationChannelName: 'Playback',
    //   androidNotificationOngoing: true,
    // );

    // Note: AudioService initialization with custom handler
    // This would be initialized when needed, not at app startup
    // Example: await AudioService.init(builder: () => MyHandler());

    // For now, we rely on just_audio_background for basic functionality

    // Configure system audio session for music playback
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }
}
