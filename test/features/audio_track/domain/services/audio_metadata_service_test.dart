import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackflow/features/audio_track/domain/services/audio_metadata_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioMetadataService', () {
    late AudioMetadataService service;

    setUp(() {
      service = const AudioMetadataService();
    });

    group('extractDuration', () {
      test('should return failure when file does not exist', () async {
        final nonExistentFile = File('/nonexistent/path/file.mp3');

        final result = await service.extractDuration(nonExistentFile);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, contains('does not exist')),
          (duration) => fail('Should have returned failure'),
        );
      });
    });

    group('validateAudioFile', () {
      test('should return failure when file does not exist', () async {
        final nonExistentFile = File('/nonexistent/path/file.mp3');

        final result = await service.validateAudioFile(nonExistentFile);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, contains('does not exist')),
          (validation) => fail('Should have returned failure'),
        );
      });
    });

    group('AudioProcessingFailure', () {
      test('should have correct message', () {
        const message = 'Test error message';
        const failure = AudioProcessingFailure(message);

        expect(failure.message, equals(message));
      });
    });

    group('AudioFileValidation', () {
      test('should have correct properties', () {
        const validation = AudioFileValidation(
          fileSize: 1024,
          duration: Duration(seconds: 30),
          isValid: true,
        );

        expect(validation.fileSize, equals(1024));
        expect(validation.duration, equals(const Duration(seconds: 30)));
        expect(validation.isValid, isTrue);
      });
    });
  });
}
