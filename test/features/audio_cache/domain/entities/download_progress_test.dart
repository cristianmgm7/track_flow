import 'package:test/test.dart';
import 'package:trackflow/features/audio_cache/shared/domain/entities/download_progress.dart';

void main() {
  group('DownloadProgress', () {
    group('constructor', () {
      test('should create instance with valid parameters', () {
        final progress = DownloadProgress(
          trackId: 'track123',
          state: DownloadState.downloading,
          downloadedBytes: 512000,
          totalBytes: 1024000,
        );

        expect(progress.trackId, equals('track123'));
        expect(progress.state, equals(DownloadState.downloading));
        expect(progress.downloadedBytes, equals(512000));
        expect(progress.totalBytes, equals(1024000));
      });

      test('should create instance with optional parameters', () {
        final progress = DownloadProgress(
          trackId: 'track123',
          state: DownloadState.downloading,
          downloadedBytes: 512000,
          totalBytes: 1024000,
          downloadSpeed: 102400.0,
          estimatedTimeRemaining: Duration(seconds: 5),
          errorMessage: 'Some error',
        );

        expect(progress.downloadSpeed, equals(102400.0));
        expect(progress.estimatedTimeRemaining, equals(Duration(seconds: 5)));
        expect(progress.errorMessage, equals('Some error'));
      });
    });

    group('named constructors', () {
      test('should create completed progress', () {
        final progress = DownloadProgress.completed('track123', 1024000);

        expect(progress.trackId, equals('track123'));
        expect(progress.state, equals(DownloadState.completed));
        expect(progress.downloadedBytes, equals(1024000));
        expect(progress.totalBytes, equals(1024000));
        expect(progress.progressPercentage, equals(1.0));
      });

      test('should create failed progress', () {
        final progress = DownloadProgress.failed('track123', 'Network error');

        expect(progress.trackId, equals('track123'));
        expect(progress.state, equals(DownloadState.failed));
        expect(progress.downloadedBytes, equals(0));
        expect(progress.totalBytes, equals(0));
        expect(progress.errorMessage, equals('Network error'));
      });

      test('should create queued progress', () {
        final progress = DownloadProgress.queued('track123');

        expect(progress.trackId, equals('track123'));
        expect(progress.state, equals(DownloadState.queued));
        expect(progress.downloadedBytes, equals(0));
        expect(progress.totalBytes, equals(0));
      });

      test('should create notStarted progress', () {
        final progress = DownloadProgress.notStarted('track123');

        expect(progress.trackId, equals('track123'));
        expect(progress.state, equals(DownloadState.notStarted));
        expect(progress.downloadedBytes, equals(0));
        expect(progress.totalBytes, equals(0));
      });
    });

    group('progressPercentage calculation', () {
      test('should calculate correct percentage', () {
        final progress = DownloadProgress(
          trackId: 'track123',
          state: DownloadState.downloading,
          downloadedBytes: 250000,
          totalBytes: 1000000,
        );

        expect(progress.progressPercentage, equals(0.25));
      });

      test('should return 0.0 when total bytes is 0', () {
        final progress = DownloadProgress(
          trackId: 'track123',
          state: DownloadState.downloading,
          downloadedBytes: 100,
          totalBytes: 0,
        );

        expect(progress.progressPercentage, equals(0.0));
      });

      test('should return 1.0 when downloaded equals total', () {
        final progress = DownloadProgress(
          trackId: 'track123',
          state: DownloadState.downloading,
          downloadedBytes: 1000000,
          totalBytes: 1000000,
        );

        expect(progress.progressPercentage, equals(1.0));
      });

      test('should cap percentage at 1.0', () {
        final progress = DownloadProgress(
          trackId: 'track123',
          state: DownloadState.downloading,
          downloadedBytes: 1500000,
          totalBytes: 1000000,
        );

        expect(progress.progressPercentage, equals(1.0));
      });
    });

    group('status getters', () {
      test('isActive should return true for active states', () {
        final downloadingProgress = DownloadProgress(
          trackId: 'track123',
          state: DownloadState.downloading,
          downloadedBytes: 500000,
          totalBytes: 1000000,
        );
        expect(downloadingProgress.isActive, isTrue);

        final queuedProgress = DownloadProgress.queued('track123');
        expect(queuedProgress.isActive, isTrue);
      });

      test('isActive should return false for inactive states', () {
        final completedProgress = DownloadProgress.completed('track123', 1000000);
        expect(completedProgress.isActive, isFalse);

        final failedProgress = DownloadProgress.failed('track123', 'Error');
        expect(failedProgress.isActive, isFalse);
      });

      test('isCompleted should return true for completed state', () {
        final progress = DownloadProgress.completed('track123', 1000000);
        expect(progress.isCompleted, isTrue);
      });

      test('isCompleted should return false for other states', () {
        final states = [
          DownloadState.notStarted,
          DownloadState.queued,
          DownloadState.downloading,
          DownloadState.failed,
          DownloadState.cancelled,
        ];

        for (final state in states) {
          final progress = DownloadProgress(
            trackId: 'track123',
            state: state,
            downloadedBytes: 500000,
            totalBytes: 1000000,
          );
          expect(progress.isCompleted, isFalse, reason: 'State: $state');
        }
      });

      test('isFailed should return true for failed state', () {
        final progress = DownloadProgress.failed('track123', 'Error');
        expect(progress.isFailed, isTrue);
      });

      test('isCancelled should return true for cancelled state', () {
        final progress = DownloadProgress(
          trackId: 'track123',
          state: DownloadState.cancelled,
          downloadedBytes: 500000,
          totalBytes: 1000000,
        );
        expect(progress.isCancelled, isTrue);
      });
    });

    group('formatted getters', () {
      test('formattedProgress should return percentage string', () {
        final progress = DownloadProgress(
          trackId: 'track123',
          state: DownloadState.downloading,
          downloadedBytes: 250000,
          totalBytes: 1000000,
        );

        expect(progress.formattedProgress, equals('25.0%'));
      });

      test('formattedSize should return size string', () {
        final progress = DownloadProgress(
          trackId: 'track123',
          state: DownloadState.downloading,
          downloadedBytes: 500000,
          totalBytes: 1048576, // 1MB
        );

        expect(progress.formattedSize, contains('KB'));
        expect(progress.formattedSize, contains('/'));
        expect(progress.formattedSize, contains('1.0MB'));
      });

      test('formattedSpeed should return speed string when available', () {
        final progress = DownloadProgress(
          trackId: 'track123',
          state: DownloadState.downloading,
          downloadedBytes: 500000,
          totalBytes: 1000000,
          downloadSpeed: 102400.0, // 100KB/s
        );

        expect(progress.formattedSpeed, contains('100.0KB/s'));
      });

      test('formattedSpeed should return empty string when not available', () {
        final progress = DownloadProgress(
          trackId: 'track123',
          state: DownloadState.downloading,
          downloadedBytes: 500000,
          totalBytes: 1000000,
        );

        expect(progress.formattedSpeed, equals(''));
      });
    });

    group('copyWith', () {
      test('should create copy with updated properties', () {
        final original = DownloadProgress(
          trackId: 'track123',
          state: DownloadState.downloading,
          downloadedBytes: 500000,
          totalBytes: 1000000,
        );

        final updated = original.copyWith(
          downloadedBytes: 750000,
          state: DownloadState.completed,
        );

        expect(updated.trackId, equals(original.trackId));
        expect(updated.totalBytes, equals(original.totalBytes));
        expect(updated.downloadedBytes, equals(750000));
        expect(updated.state, equals(DownloadState.completed));
      });

      test('should keep original values when no updates provided', () {
        final original = DownloadProgress(
          trackId: 'track123',
          state: DownloadState.downloading,
          downloadedBytes: 500000,
          totalBytes: 1000000,
        );

        final copy = original.copyWith();
        expect(copy, equals(original));
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        final progress1 = DownloadProgress(
          trackId: 'track123',
          state: DownloadState.downloading,
          downloadedBytes: 500000,
          totalBytes: 1000000,
        );

        final progress2 = DownloadProgress(
          trackId: 'track123',
          state: DownloadState.downloading,
          downloadedBytes: 500000,
          totalBytes: 1000000,
        );

        expect(progress1, equals(progress2));
        expect(progress1.hashCode, equals(progress2.hashCode));
      });

      test('should not be equal when trackId is different', () {
        final progress1 = DownloadProgress(
          trackId: 'track123',
          state: DownloadState.downloading,
          downloadedBytes: 500000,
          totalBytes: 1000000,
        );

        final progress2 = DownloadProgress(
          trackId: 'track456',
          state: DownloadState.downloading,
          downloadedBytes: 500000,
          totalBytes: 1000000,
        );

        expect(progress1, isNot(equals(progress2)));
      });
    });

    group('toString', () {
      test('should provide readable string representation', () {
        final progress = DownloadProgress(
          trackId: 'track123',
          state: DownloadState.downloading,
          downloadedBytes: 500000,
          totalBytes: 1000000,
        );

        final stringRepresentation = progress.toString();
        
        expect(stringRepresentation, contains('DownloadProgress'));
        expect(stringRepresentation, contains('track123'));
        expect(stringRepresentation, contains('500000'));
        expect(stringRepresentation, contains('1000000'));
      });
    });
  });

  group('DownloadState', () {
    test('should have correct enum values', () {
      expect(DownloadState.values, hasLength(6));
      expect(DownloadState.values, contains(DownloadState.notStarted));
      expect(DownloadState.values, contains(DownloadState.queued));
      expect(DownloadState.values, contains(DownloadState.downloading));
      expect(DownloadState.values, contains(DownloadState.completed));
      expect(DownloadState.values, contains(DownloadState.failed));
      expect(DownloadState.values, contains(DownloadState.cancelled));
    });
  });
}