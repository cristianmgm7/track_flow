import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:trackflow/core/error/failures.dart';

/// Domain service responsible for extracting metadata from audio files
/// Handles duration calculation, file validation, and other audio analysis
@lazySingleton
class AudioMetadataService {
  const AudioMetadataService();

  /// Extract duration from an audio file (no player initialization)
  /// Returns the duration or a failure if the file cannot be processed
  Future<Either<Failure, Duration>> extractDuration(File audioFile) async {
    try {
      // Validate file exists
      if (!await audioFile.exists()) {
        return Left(AudioProcessingFailure('Audio file does not exist'));
      }

      // Validate file is readable
      if (!await audioFile
          .readAsBytes()
          .then((_) => true)
          .catchError((_) => false)) {
        return Left(AudioProcessingFailure('Cannot read audio file'));
      }

      // Read metadata without initializing audio player
      final metadata = await MetadataGod.readMetadata(file: audioFile.path);
      final durationMs = metadata.durationMs;

      if (durationMs == null || durationMs <= 0) {
        return Left(
          AudioProcessingFailure('Could not determine audio duration'),
        );
      }

      return Right(Duration(milliseconds: durationMs));
    } catch (e) {
      return Left(
        AudioProcessingFailure('Failed to read metadata: ${e.toString()}'),
      );
    }
  }

  /// Validate audio file format and basic properties
  /// Returns success or failure with validation details
  Future<Either<Failure, AudioFileValidation>> validateAudioFile(
    File audioFile,
  ) async {
    try {
      // Check file exists
      if (!await audioFile.exists()) {
        return Left(AudioProcessingFailure('Audio file does not exist'));
      }

      // Check file size (reasonable limits)
      final fileSize = await audioFile.length();
      const maxSize = 500 * 1024 * 1024; // 500MB limit
      if (fileSize > maxSize) {
        return Left(AudioProcessingFailure('Audio file too large (max 500MB)'));
      }

      if (fileSize == 0) {
        return Left(AudioProcessingFailure('Audio file is empty'));
      }

      // Extract duration to validate file is actually audio
      final durationResult = await extractDuration(audioFile);
      return durationResult.fold(
        (failure) => Left(failure),
        (duration) => Right(
          AudioFileValidation(
            fileSize: fileSize,
            duration: duration,
            isValid: true,
          ),
        ),
      );
    } catch (e) {
      return Left(
        AudioProcessingFailure(
          'Failed to validate audio file: ${e.toString()}',
        ),
      );
    }
  }
}

/// Result of audio file validation
class AudioFileValidation {
  final int fileSize;
  final Duration duration;
  final bool isValid;

  const AudioFileValidation({
    required this.fileSize,
    required this.duration,
    required this.isValid,
  });
}

/// Specific failure for audio processing errors
class AudioProcessingFailure extends Failure {
  const AudioProcessingFailure(String message) : super(message);
}
