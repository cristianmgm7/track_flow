import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';

@lazySingleton
class ToggleRepeatModeUseCase {
  ToggleRepeatModeUseCase();

  RepeatMode call(RepeatMode currentMode) {
    switch (currentMode) {
      case RepeatMode.none:
        return RepeatMode.single;
      case RepeatMode.single:
        return RepeatMode.queue;
      case RepeatMode.queue:
        return RepeatMode.none;
    }
  }
}