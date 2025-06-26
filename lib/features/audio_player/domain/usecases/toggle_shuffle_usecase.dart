import 'package:injectable/injectable.dart';
import 'dart:math';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';

@lazySingleton
class ToggleShuffleUseCase {
  ToggleShuffleUseCase();

  ToggleShuffleResult call({
    required PlaybackQueueMode currentMode,
    required List<String> queue,
  }) {
    final newMode = currentMode == PlaybackQueueMode.normal
        ? PlaybackQueueMode.shuffle
        : PlaybackQueueMode.normal;

    final shuffledQueue = newMode == PlaybackQueueMode.shuffle
        ? _generateShuffledQueue(queue)
        : <String>[];

    return ToggleShuffleResult(
      newMode: newMode,
      shuffledQueue: shuffledQueue,
    );
  }

  List<String> _generateShuffledQueue(List<String> originalQueue) {
    if (originalQueue.isEmpty) return [];
    final shuffled = List<String>.from(originalQueue);
    shuffled.shuffle(Random());
    return shuffled;
  }
}

class ToggleShuffleResult {
  final PlaybackQueueMode newMode;
  final List<String> shuffledQueue;

  ToggleShuffleResult({
    required this.newMode,
    required this.shuffledQueue,
  });
}