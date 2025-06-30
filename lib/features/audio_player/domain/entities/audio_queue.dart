import 'package:equatable/equatable.dart';
import 'audio_source.dart';

/// Pure audio queue management without business logic
/// Contains only the information needed for audio playback sequencing
class AudioQueue extends Equatable {
  const AudioQueue({
    required this.sources,
    required this.currentIndex,
    this.shuffleEnabled = false,
    this.originalOrder,
  });

  /// List of audio sources in the current queue order
  final List<AudioSource> sources;

  /// Current track index in the queue
  final int currentIndex;

  /// Whether shuffle mode is enabled
  final bool shuffleEnabled;

  /// Original order of sources (before shuffle)
  /// Only populated when shuffle is enabled
  final List<AudioSource>? originalOrder;

  /// Check if queue is empty
  bool get isEmpty => sources.isEmpty;

  /// Check if queue has tracks
  bool get isNotEmpty => sources.isNotEmpty;

  /// Get current audio source (null if queue is empty or index invalid)
  AudioSource? get currentSource {
    if (isEmpty || currentIndex < 0 || currentIndex >= sources.length) {
      return null;
    }
    return sources[currentIndex];
  }

  /// Check if there's a next track
  bool get hasNext => isNotEmpty && currentIndex < sources.length - 1;

  /// Check if there's a previous track
  bool get hasPrevious => isNotEmpty && currentIndex > 0;

  /// Get next audio source (null if no next track)
  AudioSource? get nextSource {
    if (!hasNext) return null;
    return sources[currentIndex + 1];
  }

  /// Get previous audio source (null if no previous track)
  AudioSource? get previousSource {
    if (!hasPrevious) return null;
    return sources[currentIndex - 1];
  }

  /// Total number of tracks in queue
  int get length => sources.length;

  /// Get source at specific index
  AudioSource? operator [](int index) {
    if (index < 0 || index >= sources.length) return null;
    return sources[index];
  }

  /// Get first source in queue
  AudioSource? first() {
    if (isEmpty) return null;
    return sources.first;
  }

  /// Get last source in queue
  AudioSource? last() {
    if (isEmpty) return null;
    return sources.last;
  }

  /// Move to next track in queue
  AudioSource? next() {
    if (!hasNext) return null;
    return sources[currentIndex + 1];
  }

  /// Move to previous track in queue
  AudioSource? previous() {
    if (!hasPrevious) return null;
    return sources[currentIndex - 1];
  }

  /// Add source to end of queue
  AudioQueue add(AudioSource source) {
    final newSources = List<AudioSource>.from(sources)..add(source);
    return copyWith(sources: newSources);
  }

  /// Insert source at specific index
  AudioQueue insert(AudioSource source, int index) {
    final newSources = List<AudioSource>.from(sources);
    final clampedIndex = index.clamp(0, sources.length);
    newSources.insert(clampedIndex, source);
    
    // Adjust current index if insertion affects it
    final newCurrentIndex = index <= currentIndex ? currentIndex + 1 : currentIndex;
    
    return copyWith(
      sources: newSources,
      currentIndex: newCurrentIndex,
    );
  }

  /// Remove source at specific index
  AudioQueue removeAt(int index) {
    if (index < 0 || index >= sources.length) {
      return this; // No change if index is invalid
    }
    
    final newSources = List<AudioSource>.from(sources);
    newSources.removeAt(index);
    
    // Adjust current index after removal
    int newCurrentIndex = currentIndex;
    if (index < currentIndex) {
      newCurrentIndex = currentIndex - 1;
    } else if (index == currentIndex && currentIndex >= newSources.length) {
      newCurrentIndex = newSources.length - 1;
    }
    
    return copyWith(
      sources: newSources,
      currentIndex: newSources.isEmpty ? -1 : newCurrentIndex,
    );
  }

  /// Move to next track and return it
  AudioQueue moveToNext() {
    if (!hasNext) return this;
    return copyWith(currentIndex: currentIndex + 1);
  }

  /// Move to previous track and return it
  AudioQueue moveToPrevious() {
    if (!hasPrevious) return this;
    return copyWith(currentIndex: currentIndex - 1);
  }

  /// Move to specific index
  AudioQueue moveToIndex(int index) {
    if (index < 0 || index >= sources.length) return this;
    return copyWith(currentIndex: index);
  }

  /// Enable or disable shuffle
  AudioQueue withShuffle(bool enabled) {
    if (enabled == shuffleEnabled) return this;
    
    if (enabled) {
      // Enable shuffle: save original order and shuffle
      final originalOrder = List<AudioSource>.from(sources);
      final shuffledSources = List<AudioSource>.from(sources);
      shuffledSources.shuffle();
      
      // Find new index of current track in shuffled list
      final currentSource = this.currentSource;
      final newCurrentIndex = currentSource != null 
          ? shuffledSources.indexOf(currentSource)
          : -1;
      
      return AudioQueue(
        sources: shuffledSources,
        currentIndex: newCurrentIndex,
        shuffleEnabled: true,
        originalOrder: originalOrder,
      );
    } else {
      // Disable shuffle: restore original order
      final originalSources = originalOrder ?? sources;
      final currentSource = this.currentSource;
      final newCurrentIndex = currentSource != null 
          ? originalSources.indexOf(currentSource)
          : -1;
      
      return AudioQueue(
        sources: originalSources,
        currentIndex: newCurrentIndex,
        shuffleEnabled: false,
      );
    }
  }

  @override
  List<Object?> get props => [sources, currentIndex, shuffleEnabled, originalOrder];

  AudioQueue copyWith({
    List<AudioSource>? sources,
    int? currentIndex,
    bool? shuffleEnabled,
    List<AudioSource>? originalOrder,
  }) {
    return AudioQueue(
      sources: sources ?? this.sources,
      currentIndex: currentIndex ?? this.currentIndex,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      originalOrder: originalOrder ?? this.originalOrder,
    );
  }

  /// Create empty queue
  factory AudioQueue.empty() => const AudioQueue(sources: [], currentIndex: -1);

  /// Create queue from list of audio sources
  factory AudioQueue.fromSources(List<AudioSource> sources, {int startIndex = 0}) {
    return AudioQueue(
      sources: sources,
      currentIndex: sources.isEmpty ? -1 : startIndex.clamp(0, sources.length - 1),
    );
  }

  /// Create queue with single source
  factory AudioQueue.withSource(AudioSource source) {
    return AudioQueue(
      sources: [source],
      currentIndex: 0,
    );
  }

  @override
  String toString() => 'AudioQueue(sources: ${sources.length}, currentIndex: $currentIndex, shuffle: $shuffleEnabled)';
}