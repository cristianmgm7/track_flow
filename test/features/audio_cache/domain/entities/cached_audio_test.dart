import 'package:flutter_test/flutter_test.dart';
import 'package:trackflow/features/audio_cache/shared/domain/entities/cached_audio.dart';

void main() {
  group('CachedAudio', () {
    group('constructor', () {
      test('should create instance with valid parameters', () {
        final cachedAudio = CachedAudio(
          trackId: 'track123',
          filePath: '/path/to/audio.mp3',
          fileSizeBytes: 1048576,
          cachedAt: DateTime(2024, 1, 1),
          checksum: 'abc123',
          quality: AudioQuality.high,
          status: CacheStatus.cached,
        );

        expect(cachedAudio.trackId, equals('track123'));
        expect(cachedAudio.filePath, equals('/path/to/audio.mp3'));
        expect(cachedAudio.fileSizeBytes, equals(1048576));
        expect(cachedAudio.cachedAt, equals(DateTime(2024, 1, 1)));
        expect(cachedAudio.checksum, equals('abc123'));
        expect(cachedAudio.quality, equals(AudioQuality.high));
        expect(cachedAudio.status, equals(CacheStatus.cached));
      });

      test('should create instance with all required parameters', () {
        final cachedAudio = CachedAudio(
          trackId: 'track123',
          filePath: '/path/to/audio.mp3',
          fileSizeBytes: 1048576,
          cachedAt: DateTime(2024, 1, 1),
          checksum: 'abc123',
          quality: AudioQuality.medium,
          status: CacheStatus.cached,
        );

        expect(cachedAudio.quality, equals(AudioQuality.medium));
        expect(cachedAudio.status, equals(CacheStatus.cached));
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        final cachedAt = DateTime(2024, 1, 1);
        
        final audio1 = CachedAudio(
          trackId: 'track123',
          filePath: '/path/to/audio.mp3',
          fileSizeBytes: 1048576,
          cachedAt: cachedAt,
          checksum: 'abc123',
          quality: AudioQuality.high,
          status: CacheStatus.cached,
        );

        final audio2 = CachedAudio(
          trackId: 'track123',
          filePath: '/path/to/audio.mp3',
          fileSizeBytes: 1048576,
          cachedAt: cachedAt,
          checksum: 'abc123',
          quality: AudioQuality.high,
          status: CacheStatus.cached,
        );

        expect(audio1, equals(audio2));
        expect(audio1.hashCode, equals(audio2.hashCode));
      });

      test('should not be equal when trackId is different', () {
        final cachedAt = DateTime(2024, 1, 1);
        
        final audio1 = CachedAudio(
          trackId: 'track123',
          filePath: '/path/to/audio.mp3',
          fileSizeBytes: 1048576,
          cachedAt: cachedAt,
          checksum: 'abc123',
          quality: AudioQuality.medium,
          status: CacheStatus.cached,
        );

        final audio2 = CachedAudio(
          trackId: 'track456',
          filePath: '/path/to/audio.mp3',
          fileSizeBytes: 1048576,
          cachedAt: cachedAt,
          checksum: 'abc123',
          quality: AudioQuality.medium,
          status: CacheStatus.cached,
        );

        expect(audio1, isNot(equals(audio2)));
      });

      test('should not be equal when filePath is different', () {
        final cachedAt = DateTime(2024, 1, 1);
        
        final audio1 = CachedAudio(
          trackId: 'track123',
          filePath: '/path/to/audio1.mp3',
          fileSizeBytes: 1048576,
          cachedAt: cachedAt,
          checksum: 'abc123',
          quality: AudioQuality.medium,
          status: CacheStatus.cached,
        );

        final audio2 = CachedAudio(
          trackId: 'track123',
          filePath: '/path/to/audio2.mp3',
          fileSizeBytes: 1048576,
          cachedAt: cachedAt,
          checksum: 'abc123',
          quality: AudioQuality.medium,
          status: CacheStatus.cached,
        );

        expect(audio1, isNot(equals(audio2)));
      });
    });

    group('copyWith', () {
      test('should create copy with updated properties', () {
        final original = CachedAudio(
          trackId: 'track123',
          filePath: '/path/to/audio.mp3',
          fileSizeBytes: 1048576,
          cachedAt: DateTime(2024, 1, 1),
          checksum: 'abc123',
          quality: AudioQuality.medium,
          status: CacheStatus.cached,
        );

        final updated = original.copyWith(
          status: CacheStatus.downloading,
          quality: AudioQuality.high,
        );

        expect(updated.trackId, equals(original.trackId));
        expect(updated.filePath, equals(original.filePath));
        expect(updated.fileSizeBytes, equals(original.fileSizeBytes));
        expect(updated.cachedAt, equals(original.cachedAt));
        expect(updated.checksum, equals(original.checksum));
        expect(updated.quality, equals(AudioQuality.high));
        expect(updated.status, equals(CacheStatus.downloading));
      });

      test('should keep original values when no updates provided', () {
        final original = CachedAudio(
          trackId: 'track123',
          filePath: '/path/to/audio.mp3',
          fileSizeBytes: 1048576,
          cachedAt: DateTime(2024, 1, 1),
          checksum: 'abc123',
          quality: AudioQuality.high,
          status: CacheStatus.cached,
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('validation', () {
      test('should accept valid file size', () {
        expect(
          () => CachedAudio(
            trackId: 'track123',
            filePath: '/path/to/audio.mp3',
            fileSizeBytes: 1048576,
            cachedAt: DateTime.now(),
            checksum: 'abc123',
            quality: AudioQuality.medium,
            status: CacheStatus.cached,
          ),
          returnsNormally,
        );
      });

      test('should accept zero file size', () {
        expect(
          () => CachedAudio(
            trackId: 'track123',
            filePath: '/path/to/audio.mp3',
            fileSizeBytes: 0,
            cachedAt: DateTime.now(),
            checksum: 'abc123',
            quality: AudioQuality.medium,
            status: CacheStatus.cached,
          ),
          returnsNormally,
        );
      });
    });

    group('toString', () {
      test('should provide readable string representation', () {
        final cachedAudio = CachedAudio(
          trackId: 'track123',
          filePath: '/path/to/audio.mp3',
          fileSizeBytes: 1048576,
          cachedAt: DateTime(2024, 1, 1),
          checksum: 'abc123',
          quality: AudioQuality.high,
          status: CacheStatus.cached,
        );

        final stringRepresentation = cachedAudio.toString();
        
        expect(stringRepresentation, contains('CachedAudio'));
        expect(stringRepresentation, contains('track123'));
        expect(stringRepresentation, contains('1048576'));
        expect(stringRepresentation, contains('abc123'));
      });
    });
  });

  group('AudioQuality', () {
    test('should have correct enum values', () {
      expect(AudioQuality.values, hasLength(4));
      expect(AudioQuality.values, contains(AudioQuality.low));
      expect(AudioQuality.values, contains(AudioQuality.medium));
      expect(AudioQuality.values, contains(AudioQuality.high));
      expect(AudioQuality.values, contains(AudioQuality.lossless));
    });
  });

  group('CacheStatus', () {
    test('should have correct enum values', () {
      expect(CacheStatus.values, hasLength(5));
      expect(CacheStatus.values, contains(CacheStatus.notCached));
      expect(CacheStatus.values, contains(CacheStatus.downloading));
      expect(CacheStatus.values, contains(CacheStatus.cached));
      expect(CacheStatus.values, contains(CacheStatus.failed));
      expect(CacheStatus.values, contains(CacheStatus.corrupted));
    });
  });
}